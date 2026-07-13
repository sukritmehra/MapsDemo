//
//  AppleMapsViewModel.swift
//  MapsDemo
//
//  Created by Sukrit Mehra on 07/07/26.
//

import Combine
import Foundation
import MapKit
import SwiftUI

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
}

@MainActor
class AppleMapsViewModel: ObservableObject {
    @Published var listings: [Properties] = []
    @Published var selectedListing: Properties?
    @Published var selectedCluster: ClusterSummary?
    @Published var mapStyle: MapStyleOptions = .imagery
    @Published var LookAroundScene: MKLookAroundScene?
    @Published var isLoadingLookAround: Bool = false
    var isLoading = true
    var errorMessage: String? = nil
    
    private let service = APIService.shared
    
    init () {
        
    }
    
    func loadHawaiiData() async {
        isLoading = true
        errorMessage = nil
                
        do {
            self.listings = try await service.fetchPosts()
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
    
    func selectListing(_ listing: Properties) {
        selectedCluster = nil
        selectedListing = listing
        
        Task {
            await loadLookAround(for: listing)
        }
    }
    
    func selectCluster(_ cluster: ClusterSummary) {
        selectedListing = nil
        LookAroundScene = nil
        selectedCluster = cluster
    }
    
    func clearSelection() {
        selectedListing = nil
        selectedCluster = nil
        LookAroundScene = nil
    }
    
    func loadLookAround(for listing: Properties) async {
        isLoadingLookAround = true
        
       defer {
            isLoadingLookAround = false
        }
        
        do {
            let request = MKLookAroundSceneRequest(coordinate: CLLocationCoordinate2D(latitude: Double(listing.Lat!) ?? 0.0, longitude: Double(listing.Lng!) ?? 0.0))
            LookAroundScene = try await request.scene
        } catch {
            LookAroundScene = nil
        }
    }
}
