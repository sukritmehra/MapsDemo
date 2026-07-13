//
//  AppleMapsView.swift
//  MapsDemo
//
//  Created by Sukrit Mehra on 24/06/26.
//

import SwiftUI
import MapKit

struct AppleMapsView: View {
    
    let title: String
    
//    @State private var initialCameraPosition: MapCameraPosition = .region(.hawaiiInslandRegion)
    
    @StateObject private var viewModel = AppleMapsViewModel()
    @StateObject private var mapController = AppleMapController()
    
    var body: some View {
        ZStack {
            // Map Background Layer
//            Map(position: $initialCameraPosition)
//                .mapStyle(.hybrid(elevation: .realistic))
//                .mapControls {
//                    MapCompass()
//                    MapScaleView()
//                    
//                }
            if viewModel.isLoading {
                
                VStack {
                    // 1. Spinner with Descriptive Text
                    ProgressView("Loading Apple Mpas with LocationsHawaii data...")
                        .tint(.blue) // Changes the wheel color
                        .foregroundColor(.gray) // Changes the text color
                }
            } else if viewModel.errorMessage != nil {
                VStack {
                    Text(viewModel.errorMessage!)
                }
                
                
            } else {
                AppleClusterMapView(
                    listings: viewModel.listings,
                    selectedListing: $viewModel.selectedListing,
                    selectedCluster: $viewModel.selectedCluster,
                    mapStyle: $viewModel.mapStyle,
                    onSelectListing: { property in
                        viewModel.selectListing(property)
                    },
                    onSelectCluster: { cluster in
                        viewModel.selectCluster(cluster)
                    },
                    mapController: mapController
                )
                .ignoresSafeArea()
                
                // Top + bottom overlay (UI Layer)
                VStack {
    //                topAreaBar
                    Spacer()
                    bottomCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 16)
            }
            
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Map Style Menu
            Menu {
                Picker("Map Style", selection:$viewModel.mapStyle) {
                    ForEach(MapStyleOptions.allCases) { style in
                    Text(style.rawValue)
                            .tag(style)
                    }
                }
            } label: {
                Image(systemName: "map")
                    .font(.title3)
                    .foregroundColor(.black)
                    .frame(width: 42, height: 42)
                    .background(.clear)
                    .clipShape(Circle())
            }
            
        }
        .task {
            await viewModel.loadHawaiiData()
        }
        .animation(.easeInOut, value: viewModel.selectedListing)
        .animation(.easeInOut, value: viewModel.selectedCluster)
        
    }
}

private extension AppleMapsView {
    
    var topAreaBar: some View {
        HStack(spacing: 12) {
            // Map Style Menu
            Menu {
                Picker("Map Style", selection:$viewModel.mapStyle) {
                    ForEach(MapStyleOptions.allCases) { style in
                    Text(style.rawValue)
                            .tag(style)
                    }
                }
            } label: {
                Image(systemName: "map")
                    .font(.title3)
                    .foregroundColor(.black)
                    .frame(width: 42, height: 42)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            Button {
                viewModel.clearSelection()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.black)
                    .frame(width: 42, height: 42)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
    }
}

private extension AppleMapsView {
    
    @ViewBuilder
    var bottomCard: some View {
        if let selectedProperty = viewModel.selectedListing {
            AppleCardView(
                listing: selectedProperty,
                lookAroundScene: viewModel.LookAroundScene,
                isLoaingLookAround: viewModel.isLoadingLookAround
//                mapController: mapController
            )
        }
    }
}

#Preview {
    AppleMapsView(title: "Demo Maps")
}
