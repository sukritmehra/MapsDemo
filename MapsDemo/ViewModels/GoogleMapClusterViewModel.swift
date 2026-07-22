//
//  GMapViewModel.swift
//  MapsDemo
//
//  Created by Sukrit Mehra on 16/07/26.
//

import Foundation
import GoogleMaps3D
import Combine
import CoreLocation
import SwiftUI

@MainActor
class GoogleMapClusterViewModel: ObservableObject {
    @Published var visibleElements: [IdentifiableCluster] = []
    @Published var camera: Camera = .defaultHawaiiLocationCamera
    @Published var selectedCluster: IdentifiableCluster? = nil
    @Published var mapType: GoogleMapType = .hybrid
    
    var isLoading = true
    var errorMessage: String? = nil
    private let service = APIService.shared
    
    private var treeRoot = QuadtreeNode(bounds: QuadBounds(minLat: -90, maxLat: 90, minLon: -180, maxLon: 180))
    private var loadedProperties: [Properties] = []
    
    func loadHawaiiData() async {
        isLoading = true
        errorMessage = nil
                
        do {
            updatePropertiesWithAPIResponse( try await service.fetchPosts())
            self.errorMessage = nil
        } catch NetworkError.invalidURL {
            self.errorMessage = "The URL configuration was invalid."
        } catch NetworkError.invalidResponse {
            self.errorMessage = "Server returned an invalid response."
        } catch NetworkError.decodingError {
            self.errorMessage = "Failed to parse data from the server."
        } catch {
            self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
        
        isLoading = false
        
    }
    
    /// ✅ Call this function when your API network response completes execution
    func updatePropertiesWithAPIResponse(_ items: [Properties]) {
        self.loadedProperties = items
        
        // Reset and rebuild tree index
        self.treeRoot = QuadtreeNode(bounds: QuadBounds(minLat: -90, maxLat: 90, minLon: -180, maxLon: 180))
        
        for item in items {
            let _ = treeRoot.insert(item)
        }
        
        clusterVisiblePoints()
    }
    /*
    func clusterVisiblePoints() {
            let currentRange = camera.range
            var queryResults: [Properties] = []
            
            // Dynamic lookup bounding viewport box
            let searchArea = QuadBounds(
                minLat: camera.center.latitude - 1.5,
                maxLat: camera.center.latitude + 1.5,
                minLon: camera.center.longitude - 1.5,
                maxLon: camera.center.longitude + 1.5
            )
            
            treeRoot.query(in: searchArea, into: &queryResults)
            var structuralClusters: [IdentifiableCluster] = []
            
            // =========================================================================
            // ✅ THE CORE SPLITTING MECHANISM
            // Dynamic grid cell sizing collapses to micro-increments as range drops
            // =========================================================================
            let gridSize = determineGridSpacing(for: currentRange)
            var checkedGridCells: Set<String> = []
            
            for item in queryResults {
                guard let latStr = item.Lat, let lat = Double(latStr),
                      let lngStr = item.Lng, let lng = Double(lngStr) else { continue }
                
                let gridX = Int(floor(lng / gridSize))
                let gridY = Int(floor(lat / gridSize))
                let key = "\(gridX)_\(gridY)"
                
                if checkedGridCells.contains(key) { continue }
                checkedGridCells.insert(key)
                
                let bounds = QuadBounds(
                    minLat: Double(gridY) * gridSize,
                    maxLat: Double(gridY + 1) * gridSize,
                    minLon: Double(gridX) * gridSize,
                    maxLon: Double(gridX + 1) * gridSize
                )
                
                var propertiesInCell: [Properties] = []
                treeRoot.query(in: bounds, into: &propertiesInCell)
                
                if !propertiesInCell.isEmpty {
                    var totalLat: Double = 0
                    var totalLng: Double = 0
                    var validCount: Double = 0
                    
                    for p in propertiesInCell {
                        if let pLat = p.Lat, let l = Double(pLat), let pLng = p.Lng, let g = Double(pLng) {
                            totalLat += l
                            totalLng += g
                            validCount += 1
                        }
                    }
                    
                    if validCount > 0 {
                        let averageLat = totalLat / validCount
                        let averageLon = totalLng / validCount
                        
                        structuralClusters.append(
                            IdentifiableCluster(
                                coordinate: CLLocationCoordinate2D(latitude: averageLat, longitude: averageLon),
                                properties: propertiesInCell,
                                bounds: bounds
                            )
                        )
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.visibleElements = structuralClusters
            }
        }
        
        // ✅ Scale spacing dynamically based on range layers to break apart numbers smoothly
        private func determineGridSpacing(for range: Double) -> Double {
            if range > 1000000 { return 0.35 }
            if range > 500000  { return 0.18 }
            if range > 150000  { return 0.08 }
            if range > 50000   { return 0.03 }
            if range > 15000   { return 0.008 }
            if range > 5000    { return 0.002 }
            return 0.0001 // Microscopic grid space: splits down to the individual coordinates
        }
        
        // Programmatic tapping zoom driving camera straight into location focus
        func zoomIntoCluster(_ cluster: IdentifiableCluster) {
            withAnimation(.easeOut(duration: 0.45)) {
                // Cut current height down sharply to unpack the sub-nodes
                let targetRange = max(camera.range * 0.25, 1500)
                camera = Camera(
                    center: LatLngAltitude(latitude: cluster.coordinate.latitude, longitude: cluster.coordinate.longitude),
                    heading: camera.heading,
                    tilt: camera.tilt,
                    roll: camera.roll,
                    range: targetRange,
                    fieldOfView: camera.fieldOfView,
                    altitudeMode: camera.altitudeMode
                )
            }
            
            // Force recalculation frame loop execution pass
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.clusterVisiblePoints()
            }
        }
     */
    
    func clusterVisiblePoints() {
            let currentRange = camera.range
            var queryResults: [Properties] = []
            
            // Dynamic lookup bounding viewport box
            let searchArea = QuadBounds(
                minLat: camera.center.latitude - 1.5,
                maxLat: camera.center.latitude + 1.5,
                minLon: camera.center.longitude - 1.5,
                maxLon: camera.center.longitude + 1.5
            )
            
            treeRoot.query(in: searchArea, into: &queryResults)
            var structuralClusters: [IdentifiableCluster] = []
            
            // =========================================================================
            // ✅ THE CORE SPLITTING MECHANISM
            // Dynamic grid cell sizing collapses to micro-increments as range drops
            // =========================================================================
            let gridSize = determineGridSpacing(for: currentRange)
            var checkedGridCells: Set<String> = []
            
            for item in queryResults {
                guard let latStr = item.Lat, let lat = Double(latStr),
                      let lngStr = item.Lng, let lng = Double(lngStr) else { continue }
                
                let gridX = Int(floor(lng / gridSize))
                let gridY = Int(floor(lat / gridSize))
                let key = "\(gridX)_\(gridY)"
                
                if checkedGridCells.contains(key) { continue }
                checkedGridCells.insert(key)
                
                let bounds = QuadBounds(
                    minLat: Double(gridY) * gridSize,
                    maxLat: Double(gridY + 1) * gridSize,
                    minLon: Double(gridX) * gridSize,
                    maxLon: Double(gridX + 1) * gridSize
                )
                
                var propertiesInCell: [Properties] = []
                treeRoot.query(in: bounds, into: &propertiesInCell)
                
                if !propertiesInCell.isEmpty {
                    var totalLat: Double = 0
                    var totalLng: Double = 0
                    var validCount: Double = 0
                    
                    for p in propertiesInCell {
                        if let pLat = p.Lat, let l = Double(pLat), let pLng = p.Lng, let g = Double(pLng) {
                            totalLat += l
                            totalLng += g
                            validCount += 1
                        }
                    }
                    
                    if validCount > 0 {
                        let averageLat = totalLat / validCount
                        let averageLon = totalLng / validCount
                        
                        structuralClusters.append(
                            IdentifiableCluster(
                                coordinate: CLLocationCoordinate2D(latitude: averageLat, longitude: averageLon),
                                properties: propertiesInCell,
                                bounds: bounds
                            )
                        )
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.visibleElements = structuralClusters
            }
        }
        
        // ✅ Scale spacing dynamically based on range layers to break apart numbers smoothly
        private func determineGridSpacing(for range: Double) -> Double {
            if range > 1000000 { return 0.35 }
            if range > 500000  { return 0.18 }
            if range > 150000  { return 0.08 }
            if range > 50000   { return 0.03 }
            if range > 15000   { return 0.008 }
            if range > 5000    { return 0.002 }
            return 0.0001 // Microscopic grid space: splits down to the individual coordinates
        }
        
        // Programmatic tapping zoom driving camera straight into location focus
        func zoomIntoCluster(_ cluster: IdentifiableCluster) {
            withAnimation(.easeOut(duration: 0.45)) {
                // Cut current height down sharply to unpack the sub-nodes
                let targetRange = max(camera.range * 0.25, 1500)
                camera = Camera(
                    center: LatLngAltitude(
                        latitude: cluster.coordinate.latitude,
                        longitude: cluster.coordinate.longitude),
                    heading: camera.heading,
                    tilt: camera.tilt,
                    roll: camera.roll,
                    range: targetRange,
                    fieldOfView: camera.fieldOfView,
                    altitudeMode: camera.altitudeMode
                )
            }
            
            // Force recalculation frame loop execution pass
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.clusterVisiblePoints()
            }
        }
}
