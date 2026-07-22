//
//  GoogleLocationExtension.swift
//  MapsDemo
//
//  Created by Sukrit Mehra on 16/07/26.
//

import GoogleMaps3D
import SwiftUI

extension Camera {
    static let defaultHawaiiLocationCamera: Self = Camera (
        center: .init(
            latitude: 21.340582368694097,
            longitude: -157.5917403117728),
        heading: 5.241423328685722,
        tilt: 0.0,
        roll: 0.0,
        range: 2126978.753488362,
        fieldOfView: Angle(radians: 0.6108652381980153),
        altitudeMode: .relativeToGround
    )
}
