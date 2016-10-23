//
//  Product.swift
//  VendingDemo
//
//  Created by Cristina Escalante on 10/22/16.
//  Copyright © 2016 Cristina Escalante. All rights reserved.
//

import Foundation
import ObjectMapper

class Product : Mappable {
    var product_identifier: String!
    var name: String!
    var price: String!
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        product_identifier <- map["product_identifier"]
        name <- map["name"]
        price <- map["price"]
    }
}
