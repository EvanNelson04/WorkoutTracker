//
//  WorkoutData.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 9/23/25.
//

import Foundation
import SwiftUI

@MainActor
class WorkoutData: ObservableObject {
    @Published var entries: [WorkoutEntry] = [] {
        didSet {
            saveEntries()
        }
    }
    
    init() {
        loadEntries()
    }
    
    // MARK: - Persistence
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "workouts")
        }
    }
    
    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: "workouts"),
           let decoded = try? JSONDecoder().decode([WorkoutEntry].self, from: data) {
            entries = decoded
        }
    }
    
    // MARK: - Helpers
    func add(entry: WorkoutEntry) {
        entries.append(entry)
    }
    
    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
    }
}

