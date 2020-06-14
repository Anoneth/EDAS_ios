//
//  MapView.swift
//  EDAS
//
//  Created by Bla bla on 14.06.2020.
//  Copyright © 2020 Bla bla. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    var map = MKMapView()
    var locationManager: CLLocationManager!
    
    init() {
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        map.mapType = .standard
        map.isRotateEnabled = false
        map.showsUserLocation = true
        map.isUserInteractionEnabled = false
        map.delegate = context.coordinator
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator(map: map)
    }
    
}

class MapViewCoordinator: NSObject, MKMapViewDelegate {
    let map: MKMapView
    var coords = [CLLocationCoordinate2D]()
    init(map: MKMapView) {
        self.map = map
    }
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        coords.append(userLocation.coordinate)
        
        let path = self.coords
        let line = MKPolyline(coordinates: path, count: path.count)
        map.addOverlay(line)
        
        let location = userLocation.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
        let region = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let pr = MKPolylineRenderer(overlay: overlay)
            pr.strokeColor = UIColor.red
            pr.lineWidth = 5
            return pr
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
