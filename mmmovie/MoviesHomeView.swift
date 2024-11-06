//
//  MoviesHomeView.swift
//  mmmovie
//
//  Created by Kristian Emil on 06/11/2024.
//

import SwiftUI

struct MoviesHomeView: View {
    @StateObject private var movieManager = MovieManager.shared
    @State private var showingSearch = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Collections Section
                    CollectionsSection()
                    
                    // Watch List Section
                    WatchListSection()
                    
                    // Recently Added Section
                    RecentlyAddedSection()
                }
                .padding()
            }
            .navigationTitle("mmmovie")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSearch = true
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .sheet(isPresented: $showingSearch) {
                SearchView()
            }
        }
    }
}

#Preview {
    MoviesHomeView()
}
