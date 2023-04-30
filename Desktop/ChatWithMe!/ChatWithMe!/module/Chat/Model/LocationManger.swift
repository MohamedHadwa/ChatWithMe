//
//  LocationManger.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 26/02/2023.
//

import Foundation
import CoreLocation

class LocationManger : NSObject , CLLocationManagerDelegate {
    static let shared =  LocationManger()
    
    var locationManger : CLLocationManager?
    var currentLocation : CLLocationCoordinate2D?
    
    private override init() {
        super.init()
        self.requestLocationAccess()
    }
    
    func requestLocationAccess(){
        if locationManger == nil {
            locationManger = CLLocationManager()
            locationManger?.delegate = self
            locationManger?.desiredAccuracy = kCLLocationAccuracyBest
            locationManger?.requestWhenInUseAuthorization()
        }
        else {
            print("We Have already Location Manger")
             
        }
    }
    
    func startUpdating(){
        locationManger?.startUpdatingLocation()
    }
    
    func stopUpdating(){
        if locationManger != nil {
            locationManger?.startUpdatingLocation()
            
        }
    }
    
    // MARK: - Delegate Function.

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last?.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location" , error.localizedDescription)
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .notDetermined {
            self.locationManger?.requestWhenInUseAuthorization()
        }
    }
    
}
