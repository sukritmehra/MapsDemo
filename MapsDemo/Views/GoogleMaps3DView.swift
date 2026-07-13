//
//  GoogleMaps3DView.swift
//  MapsDemo
//
//  Created by Sukrit Mehra on 24/06/26.
//

import SwiftUI

struct GoogleMaps3DView: View {
    let title: String
    var body: some View {
        Text("Hello, \(title)!")
            .navigationTitle(title)
    }
}

#Preview {
    GoogleMaps3DView(title: "Demo Maps")
}
