//
//  MapAnnotation.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 26/02/2023.
//

import Foundation
import MapKit

class MapAnnotation :NSObject , MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
     init(title: String? , coordinate: CLLocationCoordinate2D) {
         self.title = title
         self.coordinate = coordinate 
    }
    
}
