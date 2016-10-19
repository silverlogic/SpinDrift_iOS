//
//  Approval.swift
//  VendingDemo
//
//  Created by Muhammad Azeem on 9/28/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

import Foundation
import ObjectMapper

class Approval : Mappable {
    var id: String!
    var payload: String!
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        payload <- map["payload"]
    }
}
