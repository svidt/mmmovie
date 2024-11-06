//
//  CollectionBubble.swift
//  mmmovie
//
//  Created by Kristian Emil on 06/11/2024.
//

import SwiftUI

struct CollectionBubble: View {
    let title: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 100, height: 100)
            
            Text(title)
                .font(.caption)
                .bold()
                .multilineTextAlignment(.center)
        }
    }
}
