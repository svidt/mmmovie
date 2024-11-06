//
//  AddCollectionBubble.swift
//  mmmovie
//
//  Created by Kristian Emil on 06/11/2024.
//

import SwiftUI

struct AddCollectionBubble: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray, style: StrokeStyle(lineWidth: 2, dash: [5]))
                .frame(width: 100, height: 100)
            
            Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    AddCollectionBubble()
}
