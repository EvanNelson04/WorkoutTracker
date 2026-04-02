//
//  KeychainManager.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 4/1/26.
//
//

import Foundation
import Security

enum KeychainError: Error {
    case itemNotFound
    case invalidData
    case unexpectedStatus(OSStatus)
}

final class KeychainManager {
    static let shared = KeychainManager()
    private init() {}

    private let service = "com.evannelson.workouttracker.credentials"

    func savePassword(_ password: String, for username: String) throws {
        let data = Data(password.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: username,
            kSecValueData as String: data
        ]

        // Remove old item if it exists so save acts like overwrite
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    func getPassword(for username: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: username,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecItemNotFound {
            throw KeychainError.itemNotFound
        }

        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }

        guard
            let data = item as? Data,
            let password = String(data: data, encoding: .utf8)
        else {
            throw KeychainError.invalidData
        }

        return password
    }

    func passwordExists(for username: String) -> Bool {
        do {
            _ = try getPassword(for: username)
            return true
        } catch {
            return false
        }
    }

    func validatePassword(_ password: String, for username: String) -> Bool {
        do {
            let savedPassword = try getPassword(for: username)
            return savedPassword == password
        } catch {
            return false
        }
    }

    func deletePassword(for username: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: username
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}
