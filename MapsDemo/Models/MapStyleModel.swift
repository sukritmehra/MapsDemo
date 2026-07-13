//
//  MapStyleModel.swift
//  MapsDemo
//
//  Created by Sukrit Mehra on 07/07/26.
//


enum MapStyleOptions: String, CaseIterable, Identifiable {
    case standard = "Standard"
    case hybrid = "Hybrid"
    case imagery = "Imagery"
    
    var id: String { rawValue }
}
