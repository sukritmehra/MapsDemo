//
//  APIService.swift
//  MapsDemo
//
//  Created by Sukrit Mehra on 08/07/26.
//

import Foundation

class APIService {
    // Shared singleton instance if needed, or instantiate locally
    static let shared = APIService()
    
    func fetchPosts() async throws -> [Properties] {
        let urlstring = "https://api.locationshawaii.com/api/v1/buy/GetPropertyResults"
        
        guard let url = URL(string: urlstring) else {
            throw NetworkError.invalidURL
        }
        
        // 1. Create a mutable URLRequest object
        var request = URLRequest(url: url)
                
        // 2. Configure HTTP Method
        request.httpMethod = "POST"
                
        // 3. Set standard HTTP Headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let postData: String = "{\"SearchType\":\"Buy\",\"query\":{\"Island\":\"oahu\",\"Region\":[]},\"MinPrice\":\"\",\"MaxPrice\":\"\",\"SortBy\":\"newest\",\"CondoOptions\":null,\"MeasurementUnit\":\"feet\",\"SessionId\":\"0yc2mr3vmuti5rz3p24hpncf\",\"Currency\":\"USD,1.0000,$\",\"CurrencyShortName\":\"USD\",\"Bedrooms\":\"Any - Any\",\"Bathrooms\":\"Any - Any\",\"UserType\":\"Client\",\"SaveSearchStatus\":\"AutoSavedSearchCreated\"}"
        
        request.httpBody = postData.data(using: .utf8)
        
        // Fetch data using modern async/await URLSession
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // PRINT INBOUND DATA
//        if let jsonString = String(data: data, encoding: .utf8) {
//            print("📥 RECEIVED JSON RESPONSE:\n\(jsonString)")
//        }
        
        // Validate HTTP response status code
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        // Decode JSON data into our Post model array
        do {
            let decoder = JSONDecoder()
            
            // This automatically translates user_id from JSON into userId in Swift
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let co = try decoder.decode(LocHawaii.self, from: data)
            
            let propertyListings = co.features
            
            if propertyListings.count != 0 {
                let listings: [Properties] = propertyListings.compactMap(\.properties)
                // Filters listings to only keep properties with valid latitude and longitude
                let validListings = listings.filter { $0.Lat != nil && $0.Lng != nil }
                return validListings
            }
            else {
                return []
            }
        }
        catch let DecodingError.dataCorrupted(context) {
            print("❌ CORRUPTED DATA: The JSON is structurally invalid or unreadable.")
            print("Context: \(context.debugDescription)")
            print("Coding Path: \(context.codingPath)\n")
            throw NetworkError.decodingError
        } catch let DecodingError.keyNotFound(key, context) {
            print("❌ MISSING KEY: The struct expects a key that doesn't exist in the server JSON.")
            print("Missing Key Name: '\(key.stringValue)'")
            print("Coding Path (Where it failed): \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
            print("Debug Info: \(context.debugDescription)\n")
            throw NetworkError.decodingError
        } catch let DecodingError.valueNotFound(type, context) {
            print("❌ NULL VALUE RECEIVED: A property was expected to contain a value, but the server returned null.")
            print("Expected Value Type: \(type)")
            print("Coding Path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
            print("Debug Info: \(context.debugDescription)\n")
            throw NetworkError.decodingError
        } catch let DecodingError.typeMismatch(type, context) {
            print("❌ DATA TYPE MISMATCH: The key exists, but its type does not match your struct definition.")
            print("Expected Swift Type: \(type)")
            print("Coding Path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
            print("Debug Info: \(context.debugDescription)\n")
            throw NetworkError.decodingError
        } catch {
            print("❌ NON-DECODING ERROR: \(error.localizedDescription)\n")
            throw NetworkError.decodingError
        }
    }
}
