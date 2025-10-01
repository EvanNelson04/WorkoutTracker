//
//  WorkoutData.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 9/23/25.
//

import Foundation

class WorkoutData: ObservableObject {
    @Published var entries: [WorkoutEntry] = []
    
    private let fileName = "workouts.json"
    
    init() {
        load()
    }
    
    func add(entry: WorkoutEntry) {
        entries.append(entry)
        save()
    }
    
    // New delete method
    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }
    
    private func save() {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: url)
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func load() {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([WorkoutEntry].self, from: data) {
            entries = decoded
        }
    }
}
