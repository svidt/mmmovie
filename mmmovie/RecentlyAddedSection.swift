//
//  RecentlyAddedSection.swift
//  mmmovie
//
//  Created by Kristian Emil on 06/11/2024.
//

import SwiftUI

struct RecentlyAddedSection: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recently Added")
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
    RecentlyAddedSection()
}
