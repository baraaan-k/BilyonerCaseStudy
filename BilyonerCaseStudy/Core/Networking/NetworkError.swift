//
//  NetworkError.swift
//  BilyonerCaseStudy
//
//  Created by baran kutlu on 7.05.2025.
//

enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
    case serverError(String)
}
