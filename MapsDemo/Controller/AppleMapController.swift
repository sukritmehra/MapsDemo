//
//  AppleMapController.swift
//  MapsDemo
//
//  Created by Sukrit Mehra on 08/07/26.
//  This gives SwiftUI a way to talk to the underlying MKMapView for camera animation

import Combine
import Foundation
import MapKit
import SwiftUI

@MainActor

final class AppleMapController: ObservableObject {
    weak var mapView: MKMapView?
    
    func focus(on listing: Properties) {
        guard let mapView else { return }
        
        let camera = MKMapCamera(
            lookingAtCenter: CLLocationCoordinate2D(latitude: Double(listing.Lat!)!, longitude: Double(listing.Lng!)!),
            fromDistance: 600,
            pitch: 50,
            heading: 20
        )
        
        mapView.setCamera(camera, animated: true)
    }
}
