//
//  WorkoutEntry.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 9/23/25.
//

import Foundation

struct WorkoutEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var exercise: String
    var weight: Double
    var reps: Int
    var heartRate: Double?
}

