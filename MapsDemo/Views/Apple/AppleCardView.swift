//
//  AppleCardView.swift
//  MapsDemo
//
//  Created by Sukrit Mehra on 10/07/26.
//

import SwiftUI
import MapKit

struct AppleCardView: View {
    let listing: Properties
    let lookAroundScene: MKLookAroundScene?
    let isLoaingLookAround: Bool
//    @ObservedObject var mapController: AppleMapController
    @State private var showFlyAround = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(listing.address!)
                        .font(.headline)
                    
                    Text("$ \(listing.price)")
                        .font(.title3.bold())
                    
                    Text("\(listing.bed) bd, \(listing.bath ?? "0") ba")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "house.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Group {
                if isLoaingLookAround {
                    ProgressView("Losding street preview...")
                        .frame(maxWidth: .infinity, maxHeight: 140)
                } else if let scene = lookAroundScene {
                    LookAroundPreview(initialScene:  scene)
                        .frame(height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    ContentUnavailableView(
                        "No street view available",
                        systemImage: "map",
                        description: Text("Try another location")
                        
                    )
                    .frame(maxWidth: .infinity, maxHeight: 140)
                    .background(.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            
            VStack(spacing: 12) {
//                Button {
//                    mapController.focus(on: listing)
//                
//                } label: {
//                    Label("Focus", systemImage: "scope")
//                        .frame(maxWidth: .infinity)
//                }
//                .buttonStyle(.borderedProminent)
                
                Button {
                    showFlyAround = true
                } label: {
                    Label("Fly Around", systemImage: "airplane")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(radius: 10)
        .sheet(isPresented: $showFlyAround) {
            AppleFlyAroundView(location: CLLocationCoordinate2D(latitude: Double(listing.Lat!) ?? 0.0, longitude: Double(listing.Lng!) ?? 0.0))
        }
    }
}
