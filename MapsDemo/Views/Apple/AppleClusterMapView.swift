//
//  AppleClusterMapView.swift
//  MapsDemo
//
//  Created by Sukrit Mehra on 08/07/26.
//  This is the core piece: SwiftUI + MKMapView + custom pins + custom clusters

import Combine
import MapKit
import SwiftUI

struct AppleClusterMapView: UIViewRepresentable {
    let listings: [Properties]
    @Binding var selectedListing: Properties?
    @Binding var selectedCluster: ClusterSummary?
    @Binding var mapStyle: MapStyleOptions
    let onSelectListing: (Properties) -> Void
    let onSelectCluster: (ClusterSummary) -> Void
    @ObservedObject var mapController: AppleMapController
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.isPitchEnabled = true
        mapView.showsBuildings = true
        mapView.pointOfInterestFilter = .includingAll
        
        mapView.setRegion(.hawaiiInslandRegion, animated: true)
        
        mapController.mapView = mapView
        DispatchQueue.main.async {
            self.syncAnnotations(on: mapView)
        }
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapController.mapView = mapView
        applyMapStyle(on: mapView)
        
        if !listings.isEmpty {
            syncAnnotations(on: mapView)
        }
    }
    
    private func applyMapStyle(on mapView: MKMapView) {
        switch mapStyle {
        case .standard:
            mapView.mapType = .standard
        case .hybrid:
            mapView.mapType = .hybrid
        case .imagery:
            mapView.mapType = .satellite
        }
    }
    
    private func syncAnnotations(on mapView: MKMapView) {
        
        DispatchQueue.main.async {
            let existing = mapView.annotations.compactMap { $0 as? PropertyAnnotation }
            
            let existingByID = Dictionary(uniqueKeysWithValues: existing.map{ ($0.listing.id, $0) })
            let incomingByID = Dictionary(uniqueKeysWithValues: listings.map{ ($0.id, $0) })
            
            // Remove only missing
            let toRemove = existing.filter { incomingByID[$0.listing.id] == nil }
            if !toRemove.isEmpty {
                mapView.removeAnnotations(toRemove)
            }
            
            //Add only new
            let toAdd = listings
                .filter { existingByID[$0.id] == nil }
                .map(PropertyAnnotation.init)
            
            if !toAdd.isEmpty {
                mapView.addAnnotations(toAdd)
            }
            
            mapView.setNeedsLayout()
            mapView.layoutIfNeeded()
        }
        
    }
    
    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: AppleClusterMapView
        
        init(_ parent: AppleClusterMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            
            if let cluster = annotation as? MKClusterAnnotation {
                let identifier = "cluster-view"
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? ClusterAnnotationView ?? ClusterAnnotationView(annotation: cluster, reuseIdentifier: identifier)
                view.annotation = cluster
                view.configure(count: cluster.memberAnnotations.count)
                return view
            }
            
            if let propertyAnnotation = annotation as? PropertyAnnotation {
                let identifier = "property-view"
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? PropertyAnnotationView ?? PropertyAnnotationView(annotation: propertyAnnotation, reuseIdentifier: identifier)
                view.annotation = propertyAnnotation
                view.clusteringIdentifier = "property-listing"
                view.configure(with: propertyAnnotation.listing)
                return view
            }
            
            return nil
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            
            if let cluster = view.annotation as? MKClusterAnnotation {
                let members = cluster.memberAnnotations.compactMap { ($0 as? PropertyAnnotation)?.listing }
                guard !members.isEmpty else { return }
                
                let price = members.map(\.price)
                let averagePrice = price.reduce(0, +) / price.count
                
                let clusterSummary = ClusterSummary (
                    count: members.count,
                    minPrice: price.min() ?? 0,
                    maxPrice: price.max() ?? 0,
                    averagePrice: averagePrice,
                    titles: members.map { $0.fullAddress ?? ""}
                )
                
                parent.selectedListing = nil
                parent.selectedCluster = clusterSummary
                parent.onSelectCluster(clusterSummary)
                
                let rect = cluster.memberAnnotations.reduce(MKMapRect.null) { partial, annotation in
                    let point = MKMapPoint(annotation.coordinate)
                    let tinyRect = MKMapRect(x: point.x, y: point.y, width: 1, height: 1)
                    return partial.union(tinyRect)
                }
                
                mapView.setVisibleMapRect(
                    rect,
                    edgePadding: UIEdgeInsets(top: 120, left: 60, bottom: 220, right: 60),
                    animated: true)
                return
            }
            
            if let propertyAnnotation = view.annotation as? PropertyAnnotation {
                parent.selectedCluster = nil
                parent.selectedListing = propertyAnnotation.listing
                parent.onSelectListing(propertyAnnotation.listing)
                
                // Define how close you want to zoom (smaller values = closer zoom)
                let zoomSpan = MKCoordinateSpan(latitudeDelta: 0.0001, longitudeDelta: 0.0001)
                let region = MKCoordinateRegion(center: propertyAnnotation.coordinate, span: zoomSpan)
                        
                // Smoothly center and zoom onto the pinned property
                mapView.setRegion(region, animated: true)
            }
            
        }
        
    }
    
    static func dismantleUIview(_ uiView: MKMapView, coordinator: Coordinator) {
        uiView.delegate = nil
    }
    
}

// MARK: - Annotation Model
final class PropertyAnnotation: NSObject, MKAnnotation {
    
    nonisolated let listing: Properties
    
    init(listing: Properties) {
        self.listing = listing
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: Double(listing.Lat!) ?? 0.0, longitude: Double(listing.Lng!) ?? 0.0)
    }
    
    var title: String? {
        listing.fullAddress
    }
}

// MARK: - Custom Pin View
final class PropertyAnnotationView: MKAnnotationView {
    
    private let Label = UILabel()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        frame = CGRect(x: 0, y: 0, width: 72, height: 40)
        centerOffset = CGPoint(x: 0, y: -20)
        canShowCallout = false
        
        let container = UIView(frame: bounds)
        container.backgroundColor = .systemBlue
        container.layer.cornerRadius = 20
        container.layer.borderColor = UIColor.white.cgColor
        container.layer.borderWidth = 2
        container.clipsToBounds = true
        
        Label.frame = container.bounds
        
        Label.font = .systemFont(ofSize: 13, weight: .bold)
        Label.textAlignment = .center
        Label.textColor = .white
        
        container.addSubview(Label)
        addSubview(container)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with listing: Properties) {
        Label.text = abbreviatedPrice(listing.price)
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

// MARK: - Custom Cluster View
final class ClusterAnnotationView: MKAnnotationView {
    
    private let countLabel = UILabel()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        frame = CGRect(x: 0, y: 0, width: 54, height: 54)
        centerOffset = CGPoint(x: 0, y: -27)
        
        backgroundColor = .systemIndigo
        layer.cornerRadius = 27
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 4
        canShowCallout = false
        
        countLabel.frame = bounds
        countLabel.font = .systemFont(ofSize: 16, weight: .heavy)
        countLabel.textAlignment = .center
        countLabel.textColor = .white
        
        addSubview(countLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(count: Int) {
        countLabel.text = "\(count)"
    }

}
