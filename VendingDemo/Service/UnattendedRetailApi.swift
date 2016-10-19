//
//  UnattendedRetailApi.swift
//  VendingDemo
//
//  Created by Muhammad Azeem on 9/20/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import UIKit

// MARK: - Provider setup

private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data //fallback to original data if it cant be serialized
    }
}

let stubClosure = { (target: UnattendedRetail) -> StubBehavior in
    if Settings.sharedInstance.useStubbedMachines {
        return StubBehavior.immediate
    }
    
    return StubBehavior.never
}

func manager() -> Manager {
    let configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders
    configuration.httpCookieStorage = HTTPCookieStorage.shared
    configuration.httpShouldSetCookies = false
    configuration.httpCookieAcceptPolicy = .always
    
    let manager = Manager(configuration: configuration)
    manager.startRequestsImmediately = false
    return manager
}

let UnattendedRetailProvider = MoyaProvider<UnattendedRetail>(stubClosure: stubClosure, manager: manager(), plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])

public func url(_ route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}

enum UnattendedRetail {
    case nearbyMachines(latitude: Float, longitude: Float)
}

extension UnattendedRetail: TargetType {
    public var baseURL: URL { return URL(string: Bundle.main.object(forInfoDictionaryKey: "VendingServerURL") as! String)! }
    public var path: String {
        switch self {
        case .nearbyMachines(_, _):
            return "/machines"
        }
    }
    public var method: Moya.Method {
        return .GET
    }
    public var parameters: [String: Any]? {
        switch self {
        case .nearbyMachines(let latitude, let longitude):
            return ["latitude": latitude, "longitude": longitude]
        }
    }
    public var task: Task {
        return .request
    }
    public var sampleData: Data {
        switch self {
        case .nearbyMachines(_, _):
            if let path = Bundle.main.path(forResource: "StubbedMachines", ofType: "json"),
                let data = NSData(contentsOfFile: path) as? Data {
                return data
            } else {
                return "{}".data(using: .utf8)!
            }
        }
    }
}
