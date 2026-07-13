//
//  ClusterSummary.swift
//  MapsDemo
//
//  Created by Sukrit Mehra on 08/07/26.
//
import Foundation

struct ClusterSummary: Identifiable, Equatable {
    let id = UUID()
    let count: Int
    let minPrice: Int
    let maxPrice: Int
    let averagePrice: Int
    let titles: [String]
}
