//
//  TMDBModels.swift
//  mmmovie
//
//  Created by Kristian Emil on 07/11/2024.
//

import Foundation

// MARK: - Base Models
struct TMDBMovie: Codable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String
    let voteAverage: Double
    let genreIds: [Int]
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case genreIds = "genre_ids"
    }
}

struct TMDBResponse: Codable {
    let page: Int
    let results: [TMDBMovie]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// MARK: - Movie Details Models
struct MovieDetails: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String
    let voteAverage: Double
    let runtime: Int?
    let genres: [Genre]
    let credits: Credits?
    let videos: VideoResponse?
    let similar: TMDBResponse?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, runtime, genres, credits, videos, similar
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
    }
    
    struct Genre: Codable {
        let id: Int
        let name: String
    }
}

struct Credits: Codable {
    let cast: [CastMember]
    let crew: [CrewMember]
    
    struct CastMember: Codable {
        let id: Int
        let name: String
        let character: String
        let profilePath: String?
        let order: Int
        
        enum CodingKeys: String, CodingKey {
            case id, name, character, order
            case profilePath = "profile_path"
        }
    }
    
    struct CrewMember: Codable {
        let id: Int
        let name: String
        let job: String
        let department: String
        let profilePath: String?
        
        enum CodingKeys: String, CodingKey {
            case id, name, job, department
            case profilePath = "profile_path"
        }
    }
}

struct VideoResponse: Codable {
    let results: [Video]
    
    struct Video: Codable {
        let id: String
        let key: String
        let name: String
        let site: String
        let type: String
    }
}
