//
//  FavoritesView.swift
//  mmmovie
//
//  Created by Kristian Emil on 06/11/2024.
//

import SwiftUI

struct FavoritesView: View {
    
    @StateObject private var movieManager = MovieManager.shared
    
    var body: some View {
        NavigationView {
            Text("Favorites")
                .navigationTitle("Favorites")
        }
    }
}

#Preview {
    FavoritesView()
}
