//
//  CollectionSection.swift
//  mmmovie
//
//  Created by Kristian Emil on 06/11/2024.
//

import SwiftUI

struct CollectionsSection: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("My Collections")
                .font(.title2)
                .bold()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    // Collection Bubbles
                    ForEach(["Date Night", "Horror", "Foreign"], id: \.self) { collection in
                        CollectionBubble(title: collection)
                    }
                    
                    // Add New Collection Button
                    AddCollectionBubble()
                }
                .padding(.vertical, 5)
            }
        }
    }
}
