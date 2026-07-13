//
//  AppleFlyAroundView.swift
//  MapsDemo
//
//  Created by Sukrit Mehra on 09/07/26.
//

import SwiftUI
import MapKit

struct AppleFlyAroundView: View {
    
    @Environment(\.dismiss) var dismiss // Allows programmatic closing
    
    let location: CLLocationCoordinate2D
    let propertAddress: String?
    /// Bool value whether Flyover is currently started or stopped
    @State
    private var isStarted = true
    
    /// Bool value if options are visible
    @State
    private var isOptionsVisible = true
    
    /// The altitude above the ground, measured in meters
    @State
    private var altitude: Double = 470
    
    /// The viewing angle of the camera, measured in degrees
    @State
    private var pitch: Double = 50
    
    /// The heading step of the camera
    @State
    private var headingStep: Double = 7
    
    /// The map type
    @State
    private var mapType: MKMapType = .hybrid
//    let flyaroundCoordinate: CLLocationCoordinate2D
    var body: some View {
        ZStack {
            FlyoverMap(
                isStarted: self.isStarted,
                coordinate: self.location,
                configuration: .init(
                    altitude: .init(self.altitude),
                    pitch: .init(self.pitch),
                    heading: .increment(by: self.headingStep)
                ),
                mapType: self.mapType,
                address: propertAddress
            )
            .ignoresSafeArea()
            self.actionButtons
            VStack {
                Spacer()
                if self.isOptionsVisible {
                    self.options
                        .transition(
                            .opacity.combined(with: .move(edge: .bottom))
                        )
                }
            }
            .padding(.bottom, 35)
            self.statusBarOverlay
        }
        .animation(
            .spring(),
            value: self.isOptionsVisible
        )
    }
}

// MARK: - StatusBar Overlay

private extension AppleFlyAroundView {
    
    /// A statusbar overlay View
    var statusBarOverlay: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.clear)
                .background(.regularMaterial)
                .frame(height: geometry.safeAreaInsets.top)
                .ignoresSafeArea()
        }
    }
    
}

// MARK: - Action Buttons

private extension AppleFlyAroundView {
    
    /// The action buttons View
    var actionButtons: some View {
        VStack {
            HStack {
                Spacer()
                VStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(
                            systemName: "xmark.circle"
                        )
                        .symbolRenderingMode(.hierarchical)
                        .font(.title)
                        .foregroundColor(.accentColor)
                        .padding(5)
                        .background(.ultraThickMaterial)
                        .cornerRadius(8)
                        .shadow(radius: 0.5)
                    }
                    
                    Button {
                        self.isStarted.toggle()
                    } label: {
                        Image(
                            systemName: self.isStarted ? "pause.circle" : "play.circle"
                        )
                        .symbolRenderingMode(.hierarchical)
                        .font(.title)
                        .foregroundColor(.accentColor)
                        .padding(5)
                        .background(.ultraThickMaterial)
                        .cornerRadius(8)
                        .shadow(radius: 0.5)
                    }
                    Button {
                        self.isOptionsVisible.toggle()
                    } label: {
                        Image(
                            systemName: self.isOptionsVisible ? "gear.circle.fill" : "gear.circle"
                        )
                        .symbolRenderingMode(.hierarchical)
                        .font(.title)
                        .foregroundColor(.accentColor)
                        .padding(5)
                        .background(.ultraThickMaterial)
                        .cornerRadius(8)
                        .shadow(radius: 0.5)
                    }
                }
            }
            Spacer()
        }
        .padding(.trailing, 8)
        .padding(.top, 10)
    }
    
}

// MARK: - Options

private extension AppleFlyAroundView {
    
    /// An options View
    var options: some View {
        ScrollView(
            .horizontal,
            showsIndicators: false
        ) {
            HStack {
                self.optionsCell(
                    title: "Map Type",
                    content: Picker(
                        "Map Type",
                        selection: self.$mapType
                    ) {
                        Text(
                            verbatim: "Standard"
                        )
                        .tag(MKMapType.standard)
                        Text(
                            verbatim: "Satellite"
                        )
                        .tag(MKMapType.satellite)
                        Text(
                            verbatim: "Hybrid"
                        )
                        .tag(MKMapType.hybrid)
                    }
                    .pickerStyle(.menu)
                )
                self.optionsCell(
                    title: "Altitude",
                    content: Slider(
                        value: self.$altitude,
                        in: 0...5000,
                        label: { EmptyView() },
                        minimumValueLabel: { Text(verbatim: "") },
                        maximumValueLabel: {
                            Text(
                                verbatim: "\(Int(self.altitude))m"
                            )
                            .font(.subheadline.monospaced())
                        }
                    )
                    .frame(width: 250)
                )
                self.optionsCell(
                    title: "Pitch",
                    content: Slider(
                        value: self.$pitch,
                        in: 0...90,
                        label: { EmptyView() },
                        minimumValueLabel: { Text(verbatim: "") },
                        maximumValueLabel: {
                            Text(
                                verbatim: "\(Int(self.pitch))"
                            )
                            .font(.subheadline.monospaced())
                        }
                    )
                    .frame(width: 200)
                )
                self.optionsCell(
                    title: "Heading Step",
                    content: Slider(
                        value: self.$headingStep,
                        in: 1...10,
                        label: { EmptyView() },
                        minimumValueLabel: { Text(verbatim: "") },
                        maximumValueLabel: {
                            Text(
                                verbatim: "\(Int(self.headingStep))"
                            )
                            .font(.subheadline.monospaced())
                        }
                    )
                    .frame(width: 200)
                )
            }
            .padding(.horizontal)
        }
    }
    
    /// Options cell View
    /// - Parameters:
    ///   - title: The title
    ///   - content: The Content
    func optionsCell<Content: View>(
        title: String,
        content: Content
    ) -> some View {
        VStack(alignment: .leading) {
            Text(
                verbatim: title
            )
            .font(.title3.weight(.semibold))
            content
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
        .shadow(radius: 0.5)
    }
    
}

#Preview {
    AppleFlyAroundView(location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), propertAddress: "XYZ")
}
