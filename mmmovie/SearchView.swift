//
//  SearchView.swift
//  mmmovie
//
//  Created by Kristian Emil on 06/11/2024.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var movieManager = MovieManager.shared
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Results
                if movieManager.isLoading {
                    ProgressView()
                } else if movieManager.searchResults.isEmpty {
                    ContentUnavailableView("Search Movies",
                        systemImage: "film",
                        description: Text("Search for movies to add to your collections"))
                } else {
                    List(movieManager.searchResults, id: \.id) { movie in
                        SearchResultRow(movie: movie)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search movies...")
            .onChange(of: searchText) { _, newValue in
                Task {
                    await movieManager.searchMovies(query: newValue)
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SearchResultRow: View {
    let movie: TMDBMovie
    @StateObject private var movieManager = MovieManager.shared
    @State private var isAdding = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Movie Poster
            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w92\(movie.posterPath ?? "")")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 60, height: 90)
            .cornerRadius(8)
            
            // Movie Info
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                Text(movie.releaseDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(movie.overview)
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Add Button
            Button(action: {
                isAdding = true
                Task {
                    _ = await movieManager.addMovie(movie, toWatchlist: true)
                }
            }) {
                Image(systemName: isAdding ? "checkmark.circle.fill" : "plus.circle.fill")
                    .foregroundColor(isAdding ? .green : .blue)
                    .font(.title2)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    SearchView()
}
