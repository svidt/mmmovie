//
//  CoreDataModels.swift
//  mmmovie
//
//  Created by Kristian Emil on 06/11/2024.
//

import Foundation
import CoreData

// MARK: - Collection Entity
public class CollectionEntity: NSManagedObject, Identifiable {
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
    
    // Thread-safe relationship management
    func addToMovies(_ movie: MovieEntity) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.addToMovies(movie)
            }
            return
        }
        var updatedMovies = movies ?? Set<MovieEntity>()
        updatedMovies.insert(movie)
        movies = updatedMovies
    }
    
    func removeFromMovies(_ movie: MovieEntity) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.removeFromMovies(movie)
            }
            return
        }
        guard var updatedMovies = movies else { return }
        updatedMovies.remove(movie)
        movies = updatedMovies
    }
}

// MARK: - Movie Entity
public class MovieEntity: NSManagedObject, Identifiable {
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
    
    var formattedReleaseDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: releaseDate) {
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: date)
        }
        return releaseDate
    }
    
    var formattedRating: String {
        String(format: "%.1f", voteAverage)
    }
    
    // Thread-safe relationship management
    func addToCollections(_ collection: CollectionEntity) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.addToCollections(collection)
            }
            return
        }
        var updatedCollections = collections ?? Set<CollectionEntity>()
        updatedCollections.insert(collection)
        collections = updatedCollections
    }
    
    func removeFromCollections(_ collection: CollectionEntity) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.removeFromCollections(collection)
            }
            return
        }
        guard var updatedCollections = collections else { return }
        updatedCollections.remove(collection)
        collections = updatedCollections
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
                print("Core Data failed to load: \(error.localizedDescription)")
                debugPrint("Core Data error details: \(error)")
            }
        }
        
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Enable persistent history tracking
        if let description = container.persistentStoreDescriptions.first {
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        }
    }
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Error saving context: \(nsError.localizedDescription)")
                print("Error details: \(nsError.userInfo)")
            }
        }
    }
    
    func resetAllData() {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "MovieEntity", in: context)
        fetchRequest.includesPropertyValues = false
        
        do {
            let movies = try context.fetch(fetchRequest) as! [NSManagedObject]
            for movie in movies {
                context.delete(movie)
            }
            
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: "CollectionEntity", in: context)
            let collections = try context.fetch(fetchRequest) as! [NSManagedObject]
            for collection in collections {
                context.delete(collection)
            }
            
            try context.save()
        } catch {
            print("Error resetting data: \(error)")
        }
    }
}
