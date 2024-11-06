//
//  CoreDataModels.swift
//  mmmovie
//
//  Created by Kristian Emil on 06/11/2024.
//

import Foundation
import CoreData

// MARK: - Collection Entity
public class CollectionEntity: NSManagedObject {
    public static let entityName = "CollectionEntity"
}

extension CollectionEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CollectionEntity> {
        return NSFetchRequest<CollectionEntity>(entityName: CollectionEntity.entityName)
    }
    
    @NSManaged public var colorHex: String
    @NSManaged public var createdDate: Date
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var movies: Set<MovieEntity>?
    
    // Convenience methods
    var moviesArray: [MovieEntity] {
        let moviesSet = movies ?? Set<MovieEntity>()
        return Array(moviesSet).sorted { $0.title < $1.title }
    }
    
    // Helper method to check if a movie is in this collection
    func contains(_ movie: MovieEntity) -> Bool {
        guard let movies = movies else { return false }
        return movies.contains(movie)
    }
}

// MARK: - Movie Entity
public class MovieEntity: NSManagedObject {
    public static let entityName = "MovieEntity"
}

extension MovieEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieEntity> {
        return NSFetchRequest<MovieEntity>(entityName: MovieEntity.entityName)
    }
    
    @NSManaged public var addedDate: Date
    @NSManaged public var backdropPath: String?
    @NSManaged public var id: Int64
    @NSManaged public var isFavorite: Bool
    @NSManaged public var isInWatchlist: Bool
    @NSManaged public var overview: String
    @NSManaged public var personalNotes: String?
    @NSManaged public var personalRating: Int16
    @NSManaged public var posterPath: String?
    @NSManaged public var releaseDate: String
    @NSManaged public var title: String
    @NSManaged public var voteAverage: Double
    @NSManaged public var collections: Set<CollectionEntity>?
    
    // Convenience methods
    var collectionsArray: [CollectionEntity] {
        let collectionsSet = collections ?? Set<CollectionEntity>()
        return Array(collectionsSet).sorted { $0.name < $1.name }
    }
    
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
    
    var backdropURL: URL? {
        guard let backdropPath = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/original\(backdropPath)")
    }
    
    // Format release date
    var formattedReleaseDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: releaseDate) {
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: date)
        }
        return releaseDate
    }
    
    // Format vote average
    var formattedRating: String {
        String(format: "%.1f", voteAverage)
    }
}

// MARK: - Relationship Management Extensions
extension MovieEntity {
    func addToCollections(_ collection: CollectionEntity) {
        var updatedCollections = collections ?? Set<CollectionEntity>()
        updatedCollections.insert(collection)
        collections = updatedCollections
    }
    
    func removeFromCollections(_ collection: CollectionEntity) {
        guard var updatedCollections = collections else { return }
        updatedCollections.remove(collection)
        collections = updatedCollections
    }
}

extension CollectionEntity {
    func addToMovies(_ movie: MovieEntity) {
        var updatedMovies = movies ?? Set<MovieEntity>()
        updatedMovies.insert(movie)
        movies = updatedMovies
    }
    
    func removeFromMovies(_ movie: MovieEntity) {
        guard var updatedMovies = movies else { return }
        updatedMovies.remove(movie)
        movies = updatedMovies
    }
}

// MARK: - Persistence Controller
class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MmmovieData")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}

// MARK: - TMDB Models
struct TMDBMovie: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String
    let voteAverage: Double
    let genreIds: [Int]
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview
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
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
