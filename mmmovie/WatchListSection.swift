//
//  WatchListSection.swift
//  mmmovie
//
//  Created by Kristian Emil on 06/11/2024.
//

import SwiftUI

struct WatchListSection: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Watch List")
                .font(.title2)
                .bold()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(0..<3) { _ in
                        MoviePoster()
                    }
                }
            }
        }
    }
}

#Preview {
    WatchListSection()
}
