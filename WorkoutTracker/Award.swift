//
//  Award.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 10/20/25.
//

import Foundation
import SwiftUI

struct Award: Identifiable, Codable, Equatable {
    let id = UUID()
    let title: String
    var description: String
    let icon: String
    var achieved: Bool = false
    var progress: Double = 0
    var progressDescription: String? = nil
    var dateEarned: Date? = nil

    // Evolution / tiers
    var tier: Int = 1
    var maxTier: Int = 1
    var nextTierGoal: Int? = nil
    var lastAwardedTier: Int = 0
    var firstRecordedWeight: Double? = nil
}


