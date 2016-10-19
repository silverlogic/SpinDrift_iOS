//
//  Response+ObjectMapper.swift
//  VendingDemo
//
//  Created by Muhammad Azeem on 9/23/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

import Foundation
import Moya
import ObjectMapper

extension Response {
    /// Maps data received from the signal into an object which implements the Mappable protocol.
    /// If the conversion fails, the signal errors.
    public func mapObject<T: Mappable>(type: T.Type) throws -> T {
        guard let object = Mapper<T>().map(JSONObject: try mapJSON()) else {
            throw Error.jsonMapping(self)
        }
        return object
    }
    
    /// Maps data received from the signal into an array of objects which implement the Mappable
    /// protocol.
    /// If the conversion fails, the signal errors.
    public func mapArray<T: Mappable>(type: T.Type) throws -> [T] {
        guard let objects = Mapper<T>().mapArray(JSONObject: try mapJSON()) else {
            throw Error.jsonMapping(self)
        }
        return objects
    }
}
