//
//  GoogleQuadBouds.swift
//  MapsDemo
//
//  Created by Sukrit Mehra on 20/07/26.
//

import Foundation
import CoreLocation

// A precise bounding region for the map coordinates
struct QuadBounds {
    let minLat: Double
    let maxLat: Double
    let minLon: Double
    let maxLon: Double
    
    func contains(_ coord: CLLocationCoordinate2D) -> Bool {
        return coord.latitude >= minLat && coord.latitude <= maxLat &&
               coord.longitude >= minLon && coord.longitude <= maxLon
    }
    
    func intersects(_ other: QuadBounds) -> Bool {
        return !(other.minLat > maxLat || other.maxLat < minLat ||
                 other.minLon > maxLon || other.maxLon < minLon)
    }
}

// Node representing data buckets inside the Map structure
class QuadtreeNode {
    private let capacity = 32
    // ✅ Safe Maximum Depth: Prevents identical coordinates from creating infinite recursion loops
    private let maxDepth = 20
    
    let bounds: QuadBounds
    let depth: Int // ✅ Track current depth layer
    var properties: [Properties] = []
    
    var northWest: QuadtreeNode?
    var northEast: QuadtreeNode?
    var southWest: QuadtreeNode?
    var southEast: QuadtreeNode?
    
    // ✅ Add designated initializer with depth tracking
    init(bounds: QuadBounds, depth: Int = 0) {
        self.bounds = bounds
        self.depth = depth
    }
    
    func insert(_ property: Properties) -> Bool {
        guard let latString = property.Lat, let lat = Double(latString),
              let lngString = property.Lng, let lng = Double(lngString) else { return false }
        
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        guard bounds.contains(coord) else { return false }
        
        // ✅ Rule: If we already have children, forward directly down to them
        if let nw = northWest {
            return nw.insert(property) || northEast!.insert(property) ||
                   southWest!.insert(property) || southEast!.insert(property)
        }
        
        // ✅ Rule: Keep appending if under capacity OR if we've reached max depth safety limit
        if properties.count < capacity || depth >= maxDepth {
            properties.append(property)
            return true
        }
        
        // Otherwise, split this node structure safely
        subdivide()
        
        // Forward the new element down to the freshly spawned child nodes
        if northWest!.insert(property) || northEast!.insert(property) ||
           southWest!.insert(property) || southEast!.insert(property) {
            return true
        }
        
        // Fallback: If edge rounding boundary fails, keep it safely in the parent bucket
        properties.append(property)
        return true
    }
    
    private func subdivide() {
        let midLat = (bounds.minLat + bounds.maxLat) / 2.0
        let midLon = (bounds.minLon + bounds.maxLon) / 2.0
        let nextDepth = depth + 1 // ✅ Track depth increments
        
        northWest = QuadtreeNode(bounds: QuadBounds(minLat: midLat, maxLat: bounds.maxLat, minLon: bounds.minLon, maxLon: midLon), depth: nextDepth)
        northEast = QuadtreeNode(bounds: QuadBounds(minLat: midLat, maxLat: bounds.maxLat, minLon: midLon, maxLon: bounds.maxLon), depth: nextDepth)
        southWest = QuadtreeNode(bounds: QuadBounds(minLat: bounds.minLat, maxLat: midLat, minLon: bounds.minLon, maxLon: midLon), depth: nextDepth)
        southEast = QuadtreeNode(bounds: QuadBounds(minLat: bounds.minLat, maxLat: midLat, minLon: midLon, maxLon: bounds.maxLon), depth: nextDepth)
        
        // Move current elements down to the children
        let itemsToMove = properties
        properties.removeAll()
        
        for item in itemsToMove {
            let _ = northWest!.insert(item) || northEast!.insert(item) ||
                    southWest!.insert(item) || southEast!.insert(item)
        }
    }
    
    func query(in region: QuadBounds, into result: inout [Properties]) {
        guard bounds.intersects(region) else { return }
        
        for item in properties {
            if let latStr = item.Lat, let lat = Double(latStr),
               let lngStr = item.Lng, let lng = Double(lngStr) {
                let coord = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                if region.contains(coord) { result.append(item) }
            }
        }
        
        northWest?.query(in: region, into: &result)
        northEast?.query(in: region, into: &result)
        southWest?.query(in: region, into: &result)
        southEast?.query(in: region, into: &result)
    }
}
