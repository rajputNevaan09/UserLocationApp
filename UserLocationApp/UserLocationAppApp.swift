//
//  UserLocationAppApp.swift
//  UserLocationApp
//
//  Created by Bhagwan Rajput on 21/03/23.
//

import SwiftUI

@main
struct UserLocationAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(coreDM: CoreDataManager())
        }
    }
}
