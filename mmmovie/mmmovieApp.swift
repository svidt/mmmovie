//
//  mmmovieApp.swift
//  mmmovie
//
//  Created by Kristian Emil on 06/11/2024.
//

import SwiftUI

@main
struct mmmovieApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
