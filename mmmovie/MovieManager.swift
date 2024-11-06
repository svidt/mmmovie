//
//  MovieManager.swift
//  mmmovie
//
//  Created by Kristian Emil on 06/11/2024.
//

import Foundation
import CoreData
import SwiftUI

@MainActor
class MovieManager: ObservableObject {
    static let shared = MovieManager()
    
    // MARK: - Properties
    private let persistenceController: PersistenceController
    private var context: NSManagedObjectContext
    private let tmdbAPIKey = "9d702fdc5b6e0206e3e9d491593621d3"
    
    // Published properties
    @Published var watchlist: [MovieEntity] = []
    @Published var favorites: [MovieEntity] = []
    @Published var collections: [CollectionEntity] = []
    @Published var searchResults: [TMDBMovie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Initialization
    private init() {
        self.persistenceController = PersistenceController.shared
        self.context = persistenceController.container.viewContext
        fetchAllData()
    }
    
    // MARK: - Data Fetching
    private func fetchAllData() {
        fetchWatchlist()
        fetchFavorites()
        fetchCollections()
    }
    
    private func fetchWatchlist() {
        let request = MovieEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isInWatchlist == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MovieEntity.addedDate, ascending: false)]
        
        do {
            watchlist = try context.fetch(request)
        } catch {
            print("Error fetching watchlist: \(error)")
            errorMessage = "Failed to fetch watchlist"
        }
    }
    
    private func fetchFavorites() {
        let request = MovieEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MovieEntity.title, ascending: true)]
        
        do {
            favorites = try context.fetch(request)
        } catch {
            print("Error fetching favorites: \(error)")
            errorMessage = "Failed to fetch favorites"
        }
    }
    
    private func fetchCollections() {
        let request = CollectionEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CollectionEntity.name, ascending: true)]
        
        do {
            collections = try context.fetch(request)
        } catch {
            print("Error fetching collections: \(error)")
            errorMessage = "Failed to fetch collections"
        }
    }
    
    // MARK: - Collection Management
    func createCollection(name: String, colorHex: String) -> CollectionEntity? {
        let entity = NSEntityDescription.entity(forEntityName: "CollectionEntity", in: context)!
        let collection = CollectionEntity(entity: entity, insertInto: context)
        collection.id = UUID()
        collection.name = name
        collection.colorHex = colorHex
        collection.createdDate = Date()
        
        do {
            try context.save()
            fetchCollections()
            return collection
        } catch {
            print("Error creating collection: \(error)")
            errorMessage = "Failed to create collection"
            return nil
        }
    }
    
    func deleteCollection(_ collection: CollectionEntity) {
        context.delete(collection)
        
        do {
            try context.save()
            fetchCollections()
        } catch {
            print("Error deleting collection: \(error)")
            errorMessage = "Failed to delete collection"
        }
    }
    
    // MARK: - Movie Management
    func addMovie(_ tmdbMovie: TMDBMovie, toWatchlist: Bool = false) -> MovieEntity? {
        // Check if movie already exists
        let request = MovieEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", tmdbMovie.id)
        
        do {
            if let existingMovie = try context.fetch(request).first {
                if toWatchlist {
                    existingMovie.isInWatchlist = true
                }
                try context.save()
                fetchAllData()
                return existingMovie
            }
            
            // Create new movie if it doesn't exist
            let entity = NSEntityDescription.entity(forEntityName: "MovieEntity", in: context)!
            let movie = MovieEntity(entity: entity, insertInto: context)
            
            movie.id = Int64(tmdbMovie.id)
            movie.title = tmdbMovie.title
            movie.overview = tmdbMovie.overview
            movie.posterPath = tmdbMovie.posterPath
            movie.backdropPath = tmdbMovie.backdropPath
            movie.releaseDate = tmdbMovie.releaseDate
            movie.voteAverage = tmdbMovie.voteAverage
            movie.addedDate = Date()
            movie.isInWatchlist = toWatchlist
            movie.isFavorite = false
            movie.personalRating = 0
            
            try context.save()
            fetchAllData()
            return movie
        } catch {
            print("Error adding movie: \(error)")
            errorMessage = "Failed to add movie"
            return nil
        }
    }
    
    func toggleWatchlist(_ movie: MovieEntity) {
        movie.isInWatchlist.toggle()
        
        do {
            try context.save()
            fetchAllData()
        } catch {
            print("Error toggling watchlist: \(error)")
            errorMessage = "Failed to update watchlist"
        }
    }
    
    func toggleFavorite(_ movie: MovieEntity) {
        movie.isFavorite.toggle()
        
        do {
            try context.save()
            fetchAllData()
        } catch {
            print("Error toggling favorite: \(error)")
            errorMessage = "Failed to update favorites"
        }
    }
    
    // MARK: - TMDB API Methods
    func searchMovies(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=\(tmdbAPIKey)&query=\(encodedQuery)") else {
            errorMessage = "Invalid search query"
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(TMDBResponse.self, from: data)
            searchResults = response.results
        } catch {
            print("Error searching movies: \(error)")
            errorMessage = "Failed to search movies"
            searchResults = []
        }
    }
    
    func fetchTrendingMovies() async {
        isLoading = true
        defer { isLoading = false }
        
        guard let url = URL(string: "https://api.themoviedb.org/3/trending/movie/week?api_key=\(tmdbAPIKey)") else {
            errorMessage = "Invalid URL"
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(TMDBResponse.self, from: data)
            searchResults = response.results
        } catch {
            print("Error fetching trending movies: \(error)")
            errorMessage = "Failed to fetch trending movies"
            searchResults = []
        }
    }
    
    // MARK: - Movie Details Management
    func updateMovieRating(_ movie: MovieEntity, rating: Int16) {
        movie.personalRating = rating
        
        do {
            try context.save()
            fetchAllData()
        } catch {
            print("Error updating movie rating: \(error)")
            errorMessage = "Failed to update movie rating"
        }
    }
    
    func updateMovieNotes(_ movie: MovieEntity, notes: String) {
        movie.personalNotes = notes
        
        do {
            try context.save()
            fetchAllData()
        } catch {
            print("Error updating movie notes: \(error)")
            errorMessage = "Failed to update movie notes"
        }
    }
}
