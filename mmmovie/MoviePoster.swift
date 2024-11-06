//
//  MoviePoster.swift
//  mmmovie
//
//  Created by Kristian Emil on 06/11/2024.
//

import SwiftUI

struct MoviePoster: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.gray.opacity(0.3))
            .frame(width: 120, height: 180)
            .overlay(
                Image(systemName: "film")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            )
    }
}

#Preview {
    MoviePoster()
}
