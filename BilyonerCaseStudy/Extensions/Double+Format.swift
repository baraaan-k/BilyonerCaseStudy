//
//  Double+Format.swift
//  BilyonerCaseStudy
//
//  Created by baran kutlu on 8.05.2025.
//


import Foundation

extension Double {
    func rounded(toPlaces places: Int) -> String {
        String(format: "%.\(places)f", self)
    }
}
