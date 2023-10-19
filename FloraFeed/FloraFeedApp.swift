//
//  FloraFeedApp.swift
//  FloraFeed
//
//  Created by Tiphaine Brydniak on 20/09/2023.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import UserNotifications


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct FloraFeedApp: App {
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            if Auth.auth().currentUser != nil {
                PlantTableView()
            } else {
                LoginView()
            }
        }
    }
}
