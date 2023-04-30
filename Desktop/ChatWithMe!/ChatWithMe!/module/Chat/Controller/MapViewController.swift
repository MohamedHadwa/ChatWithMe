//
//  MapViewController.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 26/02/2023.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    // MARK: - Private Variables.
    var location :CLLocation?
    var mapView : MKMapView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureMapView()
        configureLeftBarButton()
        self.title = "Map View"
        
    }
    
    
    // MARK: - Private Functions.
    
    private func configureMapView (){
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        mapView.showsUserLocation = true
        if location != nil {
            mapView.setCenter(location!.coordinate, animated: false)
            
            mapView.addAnnotation(MapAnnotation(title: "User Location", coordinate: location!.coordinate))
            
        }
        view.addSubview(mapView)

            
    }
    private func configureLeftBarButton (){
        self .navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "left-chevron"), style: .plain, target: self, action: #selector(self.backButtonPressed) )]
    }
    @objc func backButtonPressed(){
        navigationController?.popViewController(animated: true)
        
    }

    
}
