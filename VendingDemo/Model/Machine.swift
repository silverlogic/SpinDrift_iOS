//
//  Machine.swift
//  VendingDemo
//
//  Created by Muhammad Azeem on 9/20/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

import Foundation
import ObjectMapper

class Machine : Mappable {
    var name: String!
    var distance: Float!
    var identifier: String!
    var model: String!
    var serial: String!
    var serviceId: String!
    var latitude: Float!
    var longitude: Float!
    var address: String!
    
    let transform = TransformOf<Float, String>(fromJSON: { Float($0!) }, toJSON: { $0.map { String($0) } })
    
    required init?(map: Map) {
        
    }
    
    /// This function is where all variable mappings should occur. It is executed by Mapper during the mapping (serialization and deserialization) process.
    func mapping(map: Map) {
        name <- map["name"]
        distance <- map["distance"]
        identifier <- map["identifier"]
        model <- map["model"]
        serial <- map["serial"]
        serviceId <- map["serviceId"]
        latitude <- (map["latitude"], transform)
        longitude <- (map["longitude"], transform)
        address <- map["address"]
    }
    
    func formatDistance() -> String {
        return distance < 1000 ? "\(distance!)m" : "\(distance! / 1000)km"
    }
}
