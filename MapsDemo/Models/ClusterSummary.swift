//
//  ClusterSummary.swift
//  MapsDemo
//
//  Created by Sukrit Mehra on 08/07/26.
//
import Foundation
import CoreLocation

// MARK:- Apple Cluster
struct ClusterSummary: Identifiable, Equatable {
    let id = UUID()
    let count: Int
    let minPrice: Int
    let maxPrice: Int
    let averagePrice: Int
    let titles: [String]
}

// MARK:- Google Cluster
struct IdentifiableCluster: Identifiable, Equatable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let properties: [Properties] // ✅ Holds the specific real estate elements grouped inside this cell
    let bounds: QuadBounds
    
    var count: Int { properties.count }
    
    var title: String {
        if count > 1 {
            return "\(count) Properties Grouped"
        } else {
            return properties.first?.fullAddress ?? "Single Property Pin"
        }
    }
    
    static func == (lhs: IdentifiableCluster, rhs: IdentifiableCluster) -> Bool {
        lhs.id == rhs.id
    }
}
