import MapKit

// MARK: - Flyover

/// A Flyover
public final class Flyover {
    
    // MARK: Properties
    
    /// The property animator
    private let animator = Animator()
    
    /// Bool value whether Flyover is currently started or stopped
    public private(set) var isStarted = false
    
    /// The map view
    public weak var mapView: MKMapView?
    
    /// The Context
    private var context: Context?
    
    private var isMarkerAdded: Bool = false
    
    // MARK: Initializer
    
    /// Creates a new instance of `Flyover`
    /// - Parameters:
    ///   - mapView: The MKMapView (weakly referenced)
    public init(
        mapView: MKMapView
    ) {
        self.mapView = mapView
    }
    
}

// MARK: - Start

public extension Flyover {
    
    /// Start Flyover
    /// - Parameters:
    ///   - coordinate: The Coordinate
    ///   - configuration: The Flyover Configuration. Default value `.default`
    @discardableResult
    func start(
        at coordinate: CLLocationCoordinate2D,
        configuration: Configuration = .default,
        address: String? = nil
    ) -> Bool {
        // Verify the map view is available and the given coordinate is valid
        guard let mapView = self.mapView, CLLocationCoordinate2DIsValid(coordinate) else {
            // Stop
            self.stop()
            // Otherwise return false as Flyover could not be started
            return false
        }
        // Check if coordinate has changed
        if self.context?.matches(with: coordinate) == false {
            // Change camera to new coordinate without animation
            mapView.camera = .init(
                lookingAtCenter: coordinate,
                fromDistance: mapView.camera.centerCoordinateDistance,
                pitch: mapView.camera.pitch,
                heading: mapView.camera.heading
            )
            let pin = MKPointAnnotation()
            pin.coordinate = coordinate
            pin.title = address
                   
            // 3. Add the pin to the map view
            mapView.addAnnotation(pin)
        }
        // Set Context
        self.context = .init(
            coordinate: coordinate,
            configuration: configuration,
            address: address ?? ""
        )
        // Verify is not started
        guard !self.isStarted else {
            // Otherwise return out of function
            return self.isStarted
        }
        // Start animation
        let isStarted = self.startAnimation()
        // Update is started state
        self.isStarted = isStarted
        // Return is started
        return isStarted
    }
    
}

// MARK: - Start Animation

private extension Flyover {
    
    /// Start Animation
    @discardableResult
    func startAnimation() -> Bool {
        // Verify map view and context are available
        guard let mapView = self.mapView,
              let context = self.context else {
            // Otherwise return false as animation could not be started
            return false
        }
        // Start animation
        self.animator.start(
            duration: context.configuration.animationDuration,
            curve: context.configuration.animationCurve,
            animations: { [weak mapView] in
                // Verify map view is available
                guard let mapView = mapView else {
                    // Otherwise return out of function
                    return
                }
                // Update heading
                mapView.camera = .init(
                    lookingAtCenter: context.coordinate,
                    fromDistance: context.configuration.altitude(mapView.camera.centerCoordinateDistance),
                    pitch: context.configuration.pitch(mapView.camera.pitch),
                    heading: fmod(
                        context.configuration.heading(mapView.camera.heading),
                        360
                    )
                )
                
                if !self.isMarkerAdded {
                    let pin = MKPointAnnotation()
                    pin.coordinate = context.coordinate
                    pin.title = context.address
                    pin.
                           
                    // Add the pin to the map view
                    mapView.addAnnotation(pin)
                    
                    // Add create Polygon
                    if (context.address == "55-610 Kamehameha Highway, 3A") {
                        let locationMutiPoint = [
                            CLLocationCoordinate2D(latitude: 21.6503482, longitude: -157.9254184),
                            CLLocationCoordinate2D(latitude: 21.6503881, longitude: -157.9253868),
                            CLLocationCoordinate2D(latitude: 21.6503944, longitude: -157.9253600),
                            CLLocationCoordinate2D(latitude: 21.6504031, longitude: -157.9253124),
                            CLLocationCoordinate2D(latitude: 21.6504074, longitude: -157.9252869),
                            CLLocationCoordinate2D(latitude: 21.6504168, longitude: -157.9252648),
                            CLLocationCoordinate2D(latitude: 21.6504261, longitude: -157.9252635),
                            CLLocationCoordinate2D(latitude: 21.6504324, longitude: -157.9252561),
                            CLLocationCoordinate2D(latitude: 21.6504318, longitude: -157.9252447),
                            CLLocationCoordinate2D(latitude: 21.6504305, longitude: -157.9252299),
                            CLLocationCoordinate2D(latitude: 21.6504305, longitude: -157.9252058),
                            CLLocationCoordinate2D(latitude: 21.6504330, longitude: -157.9251944),
                            CLLocationCoordinate2D(latitude: 21.6504504, longitude: -157.9251837),
                            CLLocationCoordinate2D(latitude: 21.6504583, longitude: -157.9251746),
                            CLLocationCoordinate2D(latitude: 21.6504676, longitude: -157.9251666),
                            CLLocationCoordinate2D(latitude: 21.6504770, longitude: -157.9251592),
                            CLLocationCoordinate2D(latitude: 21.6504863, longitude: -157.9251552),
                            CLLocationCoordinate2D(latitude: 21.6504860, longitude: -157.9251427),
                            CLLocationCoordinate2D(latitude: 21.6504822, longitude: -157.9251266),
                            CLLocationCoordinate2D(latitude: 21.6504760, longitude: -157.9250917),
                            CLLocationCoordinate2D(latitude: 21.6504396, longitude: -157.9250191),
                            CLLocationCoordinate2D(latitude: 21.6504162, longitude: -157.9249965),
                            CLLocationCoordinate2D(latitude: 21.6503950, longitude: -157.9249844),
                            CLLocationCoordinate2D(latitude: 21.6503700, longitude: -157.9249710),
                            CLLocationCoordinate2D(latitude: 21.6503426, longitude: -157.9249683),
                            CLLocationCoordinate2D(latitude: 21.6503227, longitude: -157.9249670),
                            CLLocationCoordinate2D(latitude: 21.6503040, longitude: -157.9249817),
                            CLLocationCoordinate2D(latitude: 21.6502815, longitude: -157.9250327),
                            CLLocationCoordinate2D(latitude: 21.6502616, longitude: -157.9251065),
                            CLLocationCoordinate2D(latitude: 21.6502354, longitude: -157.9251829),
                            CLLocationCoordinate2D(latitude: 21.6502115, longitude: -157.9252752),
                            CLLocationCoordinate2D(latitude: 21.6501865, longitude: -157.9253563),
                            CLLocationCoordinate2D(latitude: 21.6501834, longitude: -157.9253677),
                            CLLocationCoordinate2D(latitude: 21.6502523, longitude: -157.9253937),
                            CLLocationCoordinate2D(latitude: 21.6503389, longitude: -157.9254205),
                            CLLocationCoordinate2D(latitude: 21.6503458, longitude: -157.9254225)
                        ]
                        
                        let rectangleOverlay = MKPolygon(coordinates: locationMutiPoint, count: locationMutiPoint.count)
                        
                        // Add Polygon on Map Overlay
                        mapView.addOverlay(rectangleOverlay, level: MKOverlayLevel.aboveRoads)
                    }
                    
                    self.isMarkerAdded = true
                }
                
            },
            completion: { [weak self] in
                // Restart animation
                self?.startAnimation()
            }
        )
        // Return true as animation was started succesfully
        return true
    }
    
}

// MARK: - Resume

public extension Flyover {
    
    /// Resume Flyover with the latest coordiante and configuration, if available
    /// - Returns: A Bool value if the Flyover could be resumed
    @discardableResult
    func resume() -> Bool {
        // Verify flyover is not started
        guard !self.isStarted else {
            // Otherwise return false as Flyover can not be resumed
            return false
        }
        // Restart animation
        return self.startAnimation()
    }
    
}

// MARK: - Stop

public extension Flyover {
    
    /// Stop Flyover
    func stop() {
        // Disable is started
        self.isStarted = false
        // Verify MapView and PropertyAnimator are available
        guard let fractionComplete = self.animator.stop(),
              let mapView = self.mapView,
              let context = self.context else {
            // Return out of function
            return
        }
        // Switch on map type
        switch mapView.mapType {
        case .standard, .mutedStandard:
            // Set heading
            mapView.camera.heading = fmod(
                {
                    let heading = mapView.camera.heading
                    let headingDelta = (context.configuration.heading(heading) - heading)
                    return (heading - headingDelta) + (fractionComplete * headingDelta)
                }(),
                360
            )
        default:
            // Re-apply the heading to stop any ongoing animations
            mapView.camera.heading = mapView.camera.heading
        }
    }
    
}

// MARK: - Overlay Delegate
//extension FlyoverMap {
//    
////    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
////        
////        if let polygon = overlay as? MKPolygon {
////            return createPolygonRenderer(for: polygon)
////        }
////        return MKOverlayRenderer(overlay: overlay)
////    }
//    func createPolygonRenderer(for polygon: MKPolygon) -> MKPolygonRenderer {
//        let renderer = MKPolygonRenderer(polygon: polygon)
//        renderer.alpha = 0.5
//        renderer.lineWidth = 2
//        renderer.fillColor = .systemBlue
//        
//        // Use a saturated version of the fill color for the border color of the polygon.
//        var hue: CGFloat = 0.0
////        var saturation: CGFloat  = 0.0
//        var brightness: CGFloat  = 0.0
//        var alpha: CGFloat = 0.0
////        var fillColor = UIColor.systemMint
////        fillColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
//        renderer.strokeColor = UIColor(hue: hue, saturation: 1.0, brightness: brightness, alpha: alpha)
//        
//        return renderer
//    }
//}
