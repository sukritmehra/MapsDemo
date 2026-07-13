//
//  PropertyModel.swift
//  MapsDemo
//
//  Created by Sukrit Mehra on 05/07/26.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct LocHawaii: Codable {
    let range: Range
    let type: String
    let features: [Feature]
    let header: Header
}

// MARK: - Feature
struct Feature: Codable {
    let type: FeatureType
    let geometry: Geometry
    let properties: Properties
}

// MARK: - Geometry
struct Geometry: Codable {
    let type: String?
    let coordinates: [String?]
}

//enum GeometryType: String, Codable {
//    case point = "Point"
//}

// MARK: - Properties
struct Properties: Codable, Hashable, Identifiable {
    let id: Int
    let mls: String?
    let dist: String?
    let address, fullAddress: String?
    let city: String?
    let state: String?
    let zip: String?
    let bed: Int
    let bath: String?
    let price: Int
//    let reduced: Bool
    let onMarket: Int
    let oh: Bool
    let ohNarration: String?
    let new, fc, ss: Bool
    let photos: [String]
    let sold, lo: Bool
    let SoldPrice: Int?
    let soldpricebase: Int?
    let formattedsoldprice: String?
//    let startTime: Bool
//    let startDate: Bool
    let IslandName: String
    let neighborhood, addressNumber: String?
    let addressStreet: String?
    let dataSource: String?
    let status: String?
    let Lat, Lng: String?
    let propertyURL, formattedListPrice: String?
    let ListPriceBase: Int
    let openHouseType: String?
    let listDate: String?
    let LivingSquareFeet: Int?
    let regionNameForMap: String?
    let addressLotUnit: String?
    let virtualTour: String?

//    enum CodingKeys: String, CodingKey {
//        case id, mls, dist, address
//        case fullAddress = "FullAddress"
//        case city, state, zip, bed, bath, price, reduced, onMarket, oh, ohNarration, new, fc, ss, photos, sold, lo
//        case soldPrice = "SoldPrice"
//        case soldpricebase, formattedsoldprice
//        case startTime = "StartTime"
//        case startDate = "StartDate"
//        case islandName = "IslandName"
//        case neighborhood = "Neighborhood"
//        case addressNumber = "AddressNumber"
//        case addressStreet = "AddressStreet"
//        case dataSource = "DataSource"
//        case status = "Status"
//        case lat = "Lat"
//        case lng = "Lng"
//        case propertyURL = "PropertyUrl"
//        case formattedListPrice = "FormattedListPrice"
//        case listPriceBase = "ListPriceBase"
//        case openHouseType = "OpenHouseType"
//        case listDate = "ListDate"
//        case livingSquareFeet = "LivingSquareFeet"
//        case regionNameForMap = "RegionNameForMap"
//        case addressLotUnit = "AddressLotUnit"
//        case virtualTour
//    }
    
    static func == (lhs: Properties, rhs: Properties) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

//enum DataSource: String, Codable {
//    case hbr = "HBR"
//    case his = "HIS"
//}

//enum IslandName: String, Codable {
//    case oahu = "Oahu"
//}

//enum OpenHouseType: String, Codable {
//    case broker = "BROKER"
//    case openHouseTypePUBLIC = "PUBLIC"
//}


//enum Status: String, Codable {
//    case active = "Active"
//    case activeUnderContract = "Active Under Contract"
//}

enum FeatureType: String, Codable {
    case feature = "Feature"
}

// MARK: - Header
struct Header: Codable {
    let island: [Island]
}

// MARK: - Island
struct Island: Codable {
    let name: String
    let coordinates: Coordinates
    let count: Int
    let region, neighborhood: [Island]?
}

// MARK: - Coordinates
struct Coordinates: Codable {
    let lat, lng: Double
}

// MARK: - Range
struct Range: Codable {
    let total: Total
    let segments: [Segment]
}

// MARK: - Segment
struct Segment: Codable {
    let amount, count: Int
}

// MARK: - Total
struct Total: Codable {
    let minAmount, maxAmount, upperBoundCount: Int
}
