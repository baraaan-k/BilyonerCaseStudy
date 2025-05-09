//
//  Endpoint.swift
//  BilyonerCaseStudy
//
//  Created by baran kutlu on 7.05.2025.
//

import Foundation

enum Endpoint {
    static let baseURL = "https://api.the-odds-api.com/v4/sports"
    
    case upcomingEvents(sport: String, region: String)
    
    var url: URL? {
        switch self {
        case .upcomingEvents(let sport, let region):
            let apiKey = "6188c93c0663817ebd20a5e19365ced1"
            var components = URLComponents(string: "\(Endpoint.baseURL)/\(sport)/odds")
            components?.queryItems = [
                URLQueryItem(name: "regions", value: region),
                URLQueryItem(name: "markets", value: "h2h"),
                URLQueryItem(name: "apiKey", value: apiKey)
            ]
            return components?.url
        }
    }
}
