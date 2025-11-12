//
//  Award.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 10/20/25.
//

import Foundation

struct Award: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    var achieved: Bool
    var progress: Double = 0.0
    var progressDescription: String? = nil // 👈 Add this
    var dateEarned: Date? = nil   // 👈 Add this line

}


