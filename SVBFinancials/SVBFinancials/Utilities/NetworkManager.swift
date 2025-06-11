//
//  NetworkManager.swift
//  SVB-App
//
//  Created by Ali bonagdaran on 9/5/2025.
//
// provides the networking capacity for fetching and decoding data from the Polygon API
import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    // gotta have good error handling
    enum NetworkError: Error {
        case invalidURL
        case requestFailed(Error)
        case invalidResponse
        case decodingError(Error)
        case apiError(String)
    }

    // fetches data from a url and then decodes it into a decodable type
    // returns a decoded object of type T
    // takes the url and an apikey as its paramaters
    func fetchData<T: Decodable>(from url: URL, apiKey: String? = nil) async throws -> T {
        var request = URLRequest(url: url)
        
        if let apiKey = apiKey {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) : (Data, URLResponse)
        
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw NetworkError.requestFailed(error)
        }

        // check the http response in case something happened
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // check if the api key is bad for some reason
        if httpResponse.statusCode == 401 {
            throw NetworkError.apiError("401 unauthorised, check the api key")
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorMessage = (try? JSONDecoder().decode(PolygonErrorResponse.self, from: data))?.message
            throw NetworkError.apiError("API Error!!: \(errorMessage ?? "rare, unknown error") (Status: \(httpResponse.statusCode))")
        }
        
        // decode JSON data
        do {
            let decoder = JSONDecoder()
            // let dateFormatter = DateFormatter()
            // dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Example
            // decoder.dateDecodingStrategy = .formatted(dateFormatter)
            return try decoder.decode(T.self, from: data)
        } catch {
            print("problem decoding json data from api: \(error)")
            throw NetworkError.decodingError(error)
        }
    }
}


// decode error messages from the po
struct PolygonErrorResponse: Decodable {
    let status: String?
    let requestId: String?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case status, message
        case requestId = "request_id"
    }
}
