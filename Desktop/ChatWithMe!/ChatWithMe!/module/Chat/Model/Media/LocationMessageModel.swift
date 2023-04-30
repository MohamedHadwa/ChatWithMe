//
//  LocationMessageModel.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 26/02/2023.
//

import Foundation
import CoreLocation
import MessageKit

class LocationMessage : NSObject , LocationItem {
    var location: CLLocation
    
    var size: CGSize
    
     init(location:CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
}
