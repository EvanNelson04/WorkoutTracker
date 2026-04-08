//
//  UserAuth.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 10/13/25.
//

import Foundation

final class UserAuth: ObservableObject {
    @Published private(set) var loggedInUsername: String = ""
    @Published var isLoggedIn: Bool = false
    @Published private(set) var isGuest: Bool = false

    private let currentUsernameKey = "CurrentUsername"
    private let isLoggedInKey = "IsLoggedIn"
    private let isGuestKey = "IsGuest"

    init() {
        // Keep app launch simple: no automatic login
        loggedInUsername = ""
        isLoggedIn = false
        isGuest = false
    }

    func continueAsGuest(with name: String = "") {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        loggedInUsername = cleanName
        isLoggedIn = true
        isGuest = true

        UserDefaults.standard.set(cleanName, forKey: currentUsernameKey)
        UserDefaults.standard.set(true, forKey: isLoggedInKey)
        UserDefaults.standard.set(true, forKey: isGuestKey)
    }

    func login(username: String, password: String) -> Bool {
        let cleanUsername = cleanedUsername(username)
        let cleanPassword = cleanedPassword(password)

        guard !cleanUsername.isEmpty, !cleanPassword.isEmpty else {
            return false
        }

        let isValid = KeychainManager.shared.validatePassword(cleanPassword, for: cleanUsername)

        if isValid {
            loggedInUsername = cleanUsername
            isLoggedIn = true
            isGuest = false

            UserDefaults.standard.set(cleanUsername, forKey: currentUsernameKey)
            UserDefaults.standard.set(true, forKey: isLoggedInKey)
            UserDefaults.standard.set(false, forKey: isGuestKey)
        }

        return isValid
    }

    func register(username: String, password: String) -> Bool {
        let cleanUsername = cleanedUsername(username)
        let cleanPassword = cleanedPassword(password)

        guard !cleanUsername.isEmpty, !cleanPassword.isEmpty else {
            return false
        }

        guard !KeychainManager.shared.passwordExists(for: cleanUsername) else {
            return false
        }

        do {
            try KeychainManager.shared.savePassword(cleanPassword, for: cleanUsername)

            loggedInUsername = cleanUsername
            isLoggedIn = true
            isGuest = false

            UserDefaults.standard.set(cleanUsername, forKey: currentUsernameKey)
            UserDefaults.standard.set(true, forKey: isLoggedInKey)
            UserDefaults.standard.set(false, forKey: isGuestKey)

            return true
        } catch {
            return false
        }
    }

    func logout() {
        loggedInUsername = ""
        isLoggedIn = false
        isGuest = false

        UserDefaults.standard.removeObject(forKey: currentUsernameKey)
        UserDefaults.standard.set(false, forKey: isLoggedInKey)
        UserDefaults.standard.set(false, forKey: isGuestKey)
    }

    func deleteAccount() {
        let usernameToDelete = loggedInUsername

        guard !usernameToDelete.isEmpty else {
            return
        }

        if !isGuest {
            do {
                try KeychainManager.shared.deletePassword(for: usernameToDelete)
            } catch {
                print("Failed to delete account from Keychain: \(error)")
            }
        }

        loggedInUsername = ""
        isLoggedIn = false
        isGuest = false

        UserDefaults.standard.removeObject(forKey: currentUsernameKey)
        UserDefaults.standard.set(false, forKey: isLoggedInKey)
        UserDefaults.standard.set(false, forKey: isGuestKey)
    }

    var username: String {
        loggedInUsername
    }

    private func cleanedUsername(_ username: String) -> String {
        username
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    private func cleanedPassword(_ password: String) -> String {
        password.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


