//
//  ContentView.swift
//  mmmovie
//
//  Created by Kristian Emil on 06/11/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "pin")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, Shimoda!")
            Text("What's going on")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
