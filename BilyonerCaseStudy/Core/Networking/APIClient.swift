//
//  APIClient.swift
//  BilyonerCaseStudy
//
//  Created by baran kutlu on 7.05.2025.
//

import Foundation
import Alamofire

final class APIClient {
    static let shared = APIClient()
    
    private init() {}
    
    func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void) {
        guard let url = endpoint.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        AF.request(url).validate().responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let decoded):
                completion(.success(decoded))
            case .failure(let error):
                if let data = response.data,
                   let errorMessage = String(data: data, encoding: .utf8) {
                    completion(.failure(.serverError(errorMessage)))
                } else {
                    print("Networking Error: \(error)")
                    completion(.failure(.decodingFailed))
                }
            }
        }
    }
}
