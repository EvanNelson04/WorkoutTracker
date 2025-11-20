//
//  Exercise.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 11/20/25.
//


import Foundation

struct Exercise: Identifiable {
    let id = UUID()
    let name: String
    let videoName: String
    let tips: [String]
}
