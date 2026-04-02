//
//  WorkoutData.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 9/23/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class WorkoutData: ObservableObject {
    @Published var entries: [WorkoutEntry] = []

    private let auth: UserAuth
    private var cancellables = Set<AnyCancellable>()

    init(auth: UserAuth) {
        self.auth = auth

        auth.$loggedInUsername
            .sink { [weak self] _ in
                self?.loadEntries()
            }
            .store(in: &cancellables)

        auth.$isLoggedIn
            .sink { [weak self] isLoggedIn in
                guard let self else { return }
                if isLoggedIn {
                    self.loadEntries()
                } else {
                    self.entries = []
                }
            }
            .store(in: &cancellables)

        loadEntries()
    }

    private func normalizedUsername() -> String {
        auth.username
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    private func currentWorkoutsKey() -> String? {
        let username = normalizedUsername()
        guard !username.isEmpty else { return nil }
        return "workouts_\(username)"
    }

    private func saveEntries() {
        guard let key = currentWorkoutsKey() else { return }

        do {
            let encoded = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(encoded, forKey: key)
        } catch {
            return
        }
    }

    private func loadEntries() {
        guard let key = currentWorkoutsKey() else {
            entries = []
            return
        }

        guard let data = UserDefaults.standard.data(forKey: key) else {
            entries = []
            return
        }

        do {
            let decoded = try JSONDecoder().decode([WorkoutEntry].self, from: data)
            entries = decoded
        } catch {
            entries = []
        }
    }

    func add(entry: WorkoutEntry) {
        entries.append(entry)
        saveEntries()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        saveEntries()
    }

    func clearCurrentUserWorkouts() {
        entries = []
        saveEntries()
    }
}

