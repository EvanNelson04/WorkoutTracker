//
//  Award.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 10/20/25.
//

import Foundation
import SwiftUI

struct Award: Identifiable {
    let id = UUID()
    let title: String
    var description: String
    let icon: String
    var achieved: Bool = false
    var progress: Double = 0
    var progressDescription: String? = nil // <-- make optional
    var dateEarned: Date? = nil

    
    // Evolution / tiers
    var tier: Int = 1
    var maxTier: Int = 1
    var nextTierGoal: Int? = nil // for evolving awards

}


