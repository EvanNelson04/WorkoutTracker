//
//  UserAuth.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 10/13/25.
//

import Foundation

class UserAuth: ObservableObject {
    @Published private(set) var loggedInUsername: String = ""
    @Published var isLoggedIn: Bool = false

    private let userKey = "SavedUser"

    init() {
        // Do not auto-login
    }

    func login(username: String, password: String) -> Bool {
        if let saved = UserDefaults.standard.dictionary(forKey: userKey) as? [String: String],
           saved["username"] == username,
           saved["password"] == password {
            loggedInUsername = username
            isLoggedIn = true
            return true
        }
        return false
    }

    func register(username: String, password: String) {
        let credentials = ["username": username, "password": password]
        UserDefaults.standard.set(credentials, forKey: userKey)
    }

    func logout() {
        loggedInUsername = ""
        isLoggedIn = false
    }

    // Safe getter for username
    var username: String {
        loggedInUsername
    }
}


