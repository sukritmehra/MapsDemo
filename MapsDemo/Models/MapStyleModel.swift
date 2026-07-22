//
//  MapStyleModel.swift
//  MapsDemo
//
//  Created by Sukrit Mehra on 07/07/26.
//

import GoogleMaps3D

enum MapStyleOptions: String, CaseIterable, Identifiable {
    case standard = "Standard"
    case hybrid = "Hybrid"
    case imagery = "Imagery"
    
    var id: String { rawValue }
}

enum GoogleMapType: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case satellite = "Satellite" // Satellite only.
    case hybrid = "Hybrid" // Satellite with roads and labels.
    case roadmap = "Roadmap"// Roadmap with labels.
    
    var mapMode: MapMode {
        switch self {
        case .satellite: return .satellite
        case .hybrid:    return .hybrid
        case .roadmap:   return .roadmap
            
        }
    }
}
