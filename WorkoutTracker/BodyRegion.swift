//
//  BodyRegion.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 11/20/25.
//

import Foundation

enum BodyRegion: String, Identifiable, CaseIterable {
    case arms, chest, shoulders, back, core, legs
    
    var id: String { rawValue }
    
    var muscleGroups: [String] {
        switch self {
        case .arms: return ["Biceps", "Triceps", "Forearms"]
        case .chest: return ["Upper Chest", "Mid Chest", "Lower Chest"]
        case .shoulders: return ["Front Delts", "Side Delts", "Rear Delts"]
        case .back: return ["Lats", "Upper Back", "Lower Back"]
        case .core: return ["Abs", "Obliques", "Lower Core"]
        case .legs: return ["Quads", "Hamstrings", "Calves", "Glutes"]
        }
    }
}
