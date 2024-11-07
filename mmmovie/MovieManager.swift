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
    
    // Published properties
    @Published private(set) var watchlist: [MovieEntity] = []
    @Published private(set) var favorites: [MovieEntity] = []
    @Published private(set) var collections: [CollectionEntity] = []
    @Published private(set) var searchResults: [TMDBMovie] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Initialization
    private init() {
        self.persistenceController = PersistenceController.shared
        self.context = persistenceController.container.viewContext
        // Configure context
        context.mergePolicy = NSMergePolicy(merge: .errorMergePolicyType)
        context.automaticallyMergesChangesFromParent = true
        
        // Initial fetch
        Task { @MainActor in
            await fetchAllData()
        }
    }
    
    // MARK: - Core Data Fetching
    private func fetchAllData() async {
        await fetchWatchlist()
        await fetchFavorites()
        await fetchCollections()
    }
    
    private func fetchWatchlist() async {
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
    
    private func fetchFavorites() async {
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
    
    private func fetchCollections() async {
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
    func createCollection(name: String, colorHex: String) async -> CollectionEntity? {
        let entity = NSEntityDescription.entity(forEntityName: "CollectionEntity", in: context)!
        let collection = CollectionEntity(entity: entity, insertInto: context)
        collection.id = UUID()
        collection.name = name
        collection.colorHex = colorHex
        collection.createdDate = Date()
        
        do {
            try context.save()
            await fetchCollections()
            return collection
        } catch {
            print("Error creating collection: \(error)")
            errorMessage = "Failed to create collection"
            return nil
        }
    }
    
    func deleteCollection(_ collection: CollectionEntity) async {
        context.delete(collection)
        
        do {
            try context.save()
            await fetchCollections()
        } catch {
            print("Error deleting collection: \(error)")
            errorMessage = "Failed to delete collection"
        }
    }
    
    // MARK: - Movie Management
    func addMovie(_ tmdbMovie: TMDBMovie, toWatchlist: Bool = false) async -> MovieEntity? {
        let request = MovieEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", tmdbMovie.id)
        
        do {
            if let existingMovie = try context.fetch(request).first {
                if toWatchlist {
                    existingMovie.isInWatchlist = true
                }
                try context.save()
                await fetchAllData()
                return existingMovie
            }
            
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
            await fetchAllData()
            return movie
        } catch {
            print("Error adding movie: \(error)")
            errorMessage = "Failed to add movie"
            return nil
        }
    }
    
    func toggleWatchlist(_ movie: MovieEntity) async {
        movie.isInWatchlist.toggle()
        
        do {
            try context.save()
            await fetchAllData()
        } catch {
            print("Error toggling watchlist: \(error)")
            errorMessage = "Failed to update watchlist"
        }
    }
    
    func toggleFavorite(_ movie: MovieEntity) async {
        movie.isFavorite.toggle()
        
        do {
            try context.save()
            await fetchAllData()
        } catch {
            print("Error toggling favorite: \(error)")
            errorMessage = "Failed to update favorites"
        }
    }
    
    func updateMovieRating(_ movie: MovieEntity, rating: Int16) async {
        movie.personalRating = rating
        
        do {
            try context.save()
            await fetchAllData()
        } catch {
            print("Error updating movie rating: \(error)")
            errorMessage = "Failed to update movie rating"
        }
    }
    
    func updateMovieNotes(_ movie: MovieEntity, notes: String) async {
        movie.personalNotes = notes
        
        do {
            try context.save()
            await fetchAllData()
        } catch {
            print("Error updating movie notes: \(error)")
            errorMessage = "Failed to update movie notes"
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
        
        do {
            let response = try await TMDBClient.shared.searchMovies(query: query)
            searchResults = response.results
        } catch {
            print("Search error: \(error)")
            errorMessage = "Failed to search movies"
            searchResults = []
        }
    }
    
    func fetchTrendingMovies() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await TMDBClient.shared.fetchTrendingMovies()
            searchResults = response.results
        } catch {
            print("Error fetching trending movies: \(error)")
            errorMessage = "Failed to fetch trending movies"
            searchResults = []
        }
    }
    
    func fetchMovieDetails(id: Int) async -> MovieDetails? {
        isLoading = true
        defer { isLoading = false }
        
        do {
            return try await TMDBClient.shared.fetchMovieDetails(id: id)
        } catch {
            print("Error fetching movie details: \(error)")
            errorMessage = "Failed to fetch movie details"
            return nil
        }
    }
}
