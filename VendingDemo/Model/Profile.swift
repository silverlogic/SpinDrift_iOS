//
//  Profile.swift
//  VendingDemo
//
//  Created by Muhammad Azeem on 9/23/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

import Foundation
import ObjectMapper

class Profile : Mappable {
    var username: String!
    var credential: Credential!
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        username <- map["username"]
        
        credential = Credential()
        credential.isPaired <- map["credential.isPaired"]
        credential.pairedAt <- (map["credential.pairedAt"], DateTransform())
    }
    
    class Credential {
        var isPaired: Bool!
        var pairedAt: Date!
    }
}
