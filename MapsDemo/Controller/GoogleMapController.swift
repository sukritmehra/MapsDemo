//
//  GoogleMapController.swift
//  MapsDemo
//
//  Created by Sukrit Mehra on 16/07/26.
//

import Combine
import Foundation
import GoogleMaps
import GoogleMaps3D
import GoogleMapsUtils
import SwiftUI

@MainActor
class GoogleMapController: ObservableObject {
    weak var mapView: GMSMapView?
    
    func focus(on listing: Properties) {
        guard let mapView else { return }
        
        let camera = GMSMapViewOptions()
        
//        mapView.setCamera(camera, animated: true)
    }
}
