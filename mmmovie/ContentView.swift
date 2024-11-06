//
//  ContentView.swift
//  mmmovie
//
//  Created by Kristian Emil on 06/11/2024.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var movieManager = MovieManager.shared
    
    var body: some View {
        TabView {
            MoviesHomeView()
                .tabItem {
                    Label("Movies", systemImage: "film")
                }
            
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
        }
    }
}

#Preview {
    ContentView()
}
