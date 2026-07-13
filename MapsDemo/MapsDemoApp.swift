//
//  MapsDemoApp.swift
//  MapsDemo
//
//  Created by Sukrit Mehra on 24/06/26.
//

import SwiftUI

@main
struct MapsDemoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                List {
                    NavigationLink(destination: AppleMapsView(title: "Apple Maps")) {
                        Text("Apple Maps")
                    }
                    NavigationLink(destination: GoogleMaps3DView(title: "Google Maps 3D")) {
                        Text("Google Maps 3D")
                    }
                }
                .navigationTitle("Maps Demo")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
