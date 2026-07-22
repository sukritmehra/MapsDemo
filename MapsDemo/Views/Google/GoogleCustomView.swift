//
//  Untitled.swift
//  MapsDemo
//
//  Created by Sukrit Mehra on 21/07/26.
//

import SwiftUI

// MARK: - Grouped Multi-Listing Component View (Orange Circle Layout)
struct CustomClusterView: View {
    let count: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.orange.opacity(0.25))
                .frame(width: 46, height: 46)
            Circle()
                .fill(Color.orange)
                .frame(width: 34, height: 34)
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
            Text("\(count)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Isolated Real Estate Property Badge View (Blue Text Label Style Layout)
struct CustomSinglePinView: View {
    let priceLabel: String
    
    var body: some View {
        VStack(spacing: 0) {
            Text(priceLabel)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .padding(.vertical, 5)
                .padding(.horizontal, 8)
                .background(Color.blue)
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white, lineWidth: 1))
            
            Image(systemName: "triangle.fill")
                .font(.system(size: 6))
                .foregroundColor(.blue)
                .rotationEffect(.degrees(180))
                .offset(y: -1)
        }
    }
}
