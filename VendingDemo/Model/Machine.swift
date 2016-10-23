/*
 * Copyright 2016 MasterCard International.
 *
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice, this list of
 * conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 * conditions and the following disclaimer in the documentation and/or other materials
 * provided with the distribution.
 * Neither the name of the MasterCard International Incorporated nor the names of its
 * contributors may be used to endorse or promote products derived from this software
 * without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
 * SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
 * IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 */
import Foundation
import ObjectMapper
import MapKit

class Machine : Mappable {
    var name: String!
    var distance: Float!
    var identifier: String!
    var model: String!
    var serial: String!
    var serviceId: String!
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    var address: String!
    var products: [Product]!
    
    let transform = TransformOf<CLLocationDegrees, String>(fromJSON: { CLLocationDegrees($0!) }, toJSON: { $0.map { String($0) } })
    
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
        products <- map["products"]
    }
    
    func formatDistance() -> String {
        return distance < 1000 ? "\(distance!)m" : "\(distance! / 1000)km"
    }
}

class MachineAnnotation: NSObject, MKAnnotation {
    var machine: Machine!
    let coordinate: CLLocationCoordinate2D
    
    init(machine: Machine!) {
        self.machine = machine
        self.coordinate = CLLocationCoordinate2DMake(machine.latitude as CLLocationDegrees, machine.longitude as CLLocationDegrees)
        
        super.init()
    }
    
    var title: String? {
        return machine.name
    }
    var subtitle: String? {
        return machine.address
    }
}
