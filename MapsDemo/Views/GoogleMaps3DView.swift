//
//  GoogleMaps3DView.swift
//  MapsDemo
//
//  Created by Sukrit Mehra on 24/06/26.
//

import SwiftUI
import GoogleMaps3D
import GoogleMapsUtils


struct GoogleMaps3DView: View {
    let title: String
    
    @StateObject private var viewModel = GoogleMapClusterViewModel()
    
    init(title: String = "Google Maps 3D") {
        /*
         API Key Setup:
         1. Get an API key using the instructions at: https://developers.google.com/maps/documentation/maps-3d/ios-sdk/setup#create-project
         2. Create a .xcconfig file at the project root level
         3. Add this line: MAPS_API_KEY = your_api_key_here
         4. Replace "your_api_key_here" with the API key obtained in step 3
         
         Note: Never commit your actual API key to source control
         */
        guard let infoDictionary: [String: Any] = Bundle.main.infoDictionary else {
            fatalError("Info.plist not found")
        }
        guard let apiKey: String = infoDictionary["MAPS_API_KEY"] as? String else {
            fatalError("MAPS_API_KEY not set in Info.plist")
        }
        
        Map.apiKey = apiKey
        self.title = title
    }
    
    var body: some View {
        //        ZStack {
        //            Map (
        //                initialCamera: .defaultHawaiiLocationCamera,
        //                mode: viewModel.mapStyle.mapMode
        //            )
        //            .ignoresSafeArea()
        //        }
        //        .navigationTitle(title)
        
        ZStack {
            if viewModel.isLoading {
                
                VStack {
                    // 1. Spinner with Descriptive Text
                    ProgressView("Loading Google Mpas 3D with LocationsHawaii data...")
                        .tint(.blue) // Changes the wheel color
                        .foregroundColor(.gray) // Changes the text color
                }
            } else if viewModel.errorMessage != nil {
                VStack {
                    Text(viewModel.errorMessage!)
                }
            } else {
                
                Map(initialCamera: viewModel.camera, mode: viewModel.mapType.mapMode) {
                    ForEach(viewModel.visibleElements) { item in
                        // GoogleMaps3D 'Marker3D' syntax elements
                        //                        Marker3D(position:
                        //                                    LatLngAltitude(latitude: item.coordinate.latitude,
                        //                                           longitude: item.coordinate.longitude),
                        //                                 // ✅ Renders any standard SwiftUI code directly onto the 3D landscape mesh via view snapshots
                        //                                 style: .viewSnapshot {
                        //                                if item.count > 1 {
                        //                                    // Displays your custom orange cluster graphic bubble
                        //                                    CustomClusterView(count: item.count)
                        //                                } else {
                        //                                    // Displays your custom blue real estate marker pin view layout
                        //                                    CustomSinglePinView()
                        //                                }
                        //                            }
                        //                        )
                        //                        .onTap {
                        //                            if item.count > 1 {
                        ////                                withAnimation(.spring(response: 0.42, dampingFraction: 0.8)) {
                        ////                                    viewModel.selectedCluster = item
                        ////                                }
                        //                                viewModel.zoomIntoCluster(item)
                        //                            }
                        
                        Marker3D ( position:
                                    LatLngAltitude(
                                        latitude: item.coordinate.latitude,
                                        longitude: item.coordinate.longitude),
                            
                                   style: .viewSnapshot {
                                // ✅ If count is greater than one, draw Orange Cluster, else draw Blue Price Badge
                            self.makeSnapshotView(for: item)
                            }
                        )
                        .onTap {
                            self.handleMarkerTap(item)
                            
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
        .onChange(of: viewModel.camera.range) { oldRange, newRange in
            viewModel.clusterVisiblePoints()
        }
        .onChange(of: viewModel.camera.center) { oldCenter, newCenter in
            viewModel.clusterVisiblePoints()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Map Style Menu
            Menu {
                Picker("Map Style", selection:$viewModel.mapType) {
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
    }
    
    /// ✅ Helper 1: Breaks up view hierarchy types for the snapshot engine
    @ViewBuilder
    private func makeSnapshotView(for item: IdentifiableCluster) -> some View {
        if item.count > 1 {
            CustomClusterView(count: item.count)
        } else if let property = item.properties.first {
            CustomSinglePinView(priceLabel: abbreviatedPrice(property.price))
        } else {
            EmptyView()
        }
    }
    
    /// ✅ Helper 2: Strips action logic execution out of the main drawing loop
    private func handleMarkerTap(_ item: IdentifiableCluster) {
        if item.count > 1 {
            viewModel.zoomIntoCluster(item)
        }
    }
    
    private func abbreviatedPrice(_ value: Int) -> String {
        if value >= 1_000_000_000 {
            return String(format: "$%.1fB", Double(value) / 1_000_000_000.0)
        } else if value >= 1_000_000 {
            return String(format: "$%.1fM", Double(value) / 1_000_000.0)
        } else if value >= 1_000 {
            return String(format: "$%.1fK", Double(value) / 1_000.0)
        } else {
            return "$\(value)"
        }
    }
    
}

#Preview {
    GoogleMaps3DView()
}
