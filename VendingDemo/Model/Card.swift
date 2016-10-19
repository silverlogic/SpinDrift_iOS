//
//  Card.swift
//  VendingDemo
//
//  Created by Muhammad Azeem on 9/23/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

import Foundation
import ObjectMapper

class Card : Mappable {
    var id: String!
    var alias: String!
    var maskedPan: String!
    var type: String!
    var isDefault: Bool!
    var isExpired: Bool!
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        alias <- map["alias"]
        maskedPan <- map["maskedPan"]
        type <- map["type"]
        isDefault <- map["isDefault"]
        isExpired <- map["isExpired"]
    }
}
