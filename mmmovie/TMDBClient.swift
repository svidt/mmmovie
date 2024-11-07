//
//  TMDB.swift
//  mmmovie
//
//  Created by Kristian Emil on 07/11/2024.
//

import Foundation

enum TMDBError: Error {
    case invalidURL
    case invalidResponse
    case requestFailed(String)
}

class TMDBClient {
    static let shared = TMDBClient()
    private let baseURL = "https://api.themoviedb.org/3"
    private let apiKey = "9d702fdc5b6e0206e3e9d491593621d3"
    
    private init() {}
    
    // MARK: - Helper Methods
    private func createURL(endpoint: String, queryItems: [URLQueryItem] = []) -> URL? {
        var components = URLComponents(string: baseURL + endpoint)
        var allQueryItems = queryItems
        allQueryItems.append(URLQueryItem(name: "api_key", value: apiKey))
        components?.queryItems = allQueryItems
        return components?.url
    }
    
    private func createRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "accept")
        return request
    }
    
    // MARK: - API Methods
    func searchMovies(query: String, page: Int = 1) async throws -> TMDBResponse {
        guard let url = createURL(
            endpoint: "/search/movie",
            queryItems: [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "include_adult", value: "false"),
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "page", value: String(page))
            ]
        ) else {
            throw TMDBError.invalidURL
        }
        
        let request = createRequest(url: url)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw TMDBError.invalidResponse
            }
            
            if httpResponse.statusCode != 200 {
                throw TMDBError.requestFailed("Status code: \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(TMDBResponse.self, from: data)
        } catch {
            throw TMDBError.requestFailed(error.localizedDescription)
        }
    }
    
    func fetchTrendingMovies() async throws -> TMDBResponse {
        guard let url = createURL(
            endpoint: "/trending/movie/week",
            queryItems: [
                URLQueryItem(name: "language", value: "en-US")
            ]
        ) else {
            throw TMDBError.invalidURL
        }
        
        let request = createRequest(url: url)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw TMDBError.invalidResponse
            }
            
            if httpResponse.statusCode != 200 {
                throw TMDBError.requestFailed("Status code: \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(TMDBResponse.self, from: data)
        } catch {
            throw TMDBError.requestFailed(error.localizedDescription)
        }
    }
    
    func fetchMovieDetails(id: Int) async throws -> MovieDetails {
        guard let url = createURL(
            endpoint: "/movie/\(id)",
            queryItems: [
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "append_to_response", value: "credits,videos,similar")
            ]
        ) else {
            throw TMDBError.invalidURL
        }
        
        let request = createRequest(url: url)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw TMDBError.invalidResponse
            }
            
            if httpResponse.statusCode != 200 {
                throw TMDBError.requestFailed("Status code: \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(MovieDetails.self, from: data)
        } catch {
            throw TMDBError.requestFailed(error.localizedDescription)
        }
    }
}
