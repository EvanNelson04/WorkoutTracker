//
//  AwardManager.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 10/20/25.
//

import Foundation
import SwiftUI

@MainActor
class AwardManager: ObservableObject {
    @Published var awards: [Award] = [
        Award(title: "10-Day Streak", description: "Workout 10 days in a row.", icon: "🔥", achieved: false),
        Award(title: "Workouts Logged", description: "Log 100 workouts.", icon: "🏆", achieved: false, tier: 1, maxTier: 4, nextTierGoal: 100),
        Award(title: "Bench Press PR", description: "Increase your bench press by 50 lbs.", icon: "💪", achieved: false, tier: 1, maxTier: 3, nextTierGoal: 50),
        Award(title: "All-Rounder", description: "Log 5 different exercises.", icon: "🎯", achieved: false),
        Award(title: "Gym Rat", description: "Workout 20 days in a month.", icon: "🐀", achieved: false),
        Award(title: "1000 Lb Club", description: "Combine 1000 lbs from Squat, Bench, Deadlift.", icon:"🦍", achieved: false, tier: 1, maxTier: 3, nextTierGoal: 1000),
    ]
    
    func evaluateAwards(for entries: [WorkoutEntry]) {
        guard !entries.isEmpty else { return }
        let sorted = entries.sorted(by: { $0.date < $1.date })
        let calendar = Calendar.current
        
        for i in awards.indices {
            var award = awards[i]  // mutable copy
            var progress: Double = 0
            var achieved = false
            
            switch award.title {
                
            case "10-Day Streak":
                let streak = longestWorkoutStreak(from: sorted)
                progress = min(Double(streak) / 10.0, 1.0)
                achieved = streak >= 10
                
            case "Workouts Logged":
                let totalWorkouts = entries.count
                if let goal = award.nextTierGoal {
                    progress = min(Double(totalWorkouts) / Double(goal), 1.0)
                    achieved = Double(totalWorkouts) >= Double(goal)
                    
                    if achieved && award.tier < award.maxTier {
                        award.tier += 1
                        award.nextTierGoal = award.tier * goal
                        award.description = "Log \(award.nextTierGoal!) workouts."
                        award.achieved = false
                    }
                }
                
            case "Bench Press PR":
                let benchEntries = sorted.filter { $0.exercise.lowercased().contains("bench") }
                if let first = benchEntries.first, let last = benchEntries.last, let goal = award.nextTierGoal {
                    let diff = max(0, last.weight - first.weight)
                    progress = min(Double(diff) / Double(goal), 1.0)
                    achieved = Double(diff) >= Double(goal)
                    
                    if achieved && award.tier < award.maxTier {
                        award.tier += 1
                        award.nextTierGoal = award.tier * goal
                        award.description = "Increase your bench press by \(award.nextTierGoal!) lbs."
                        award.achieved = false
                    }
                }
                
            case "1000 Lb Club":
                let squatPR = entries.filter { $0.exercise.lowercased().contains("squat") }.map { $0.weight }.max() ?? 0
                let benchPR = entries.filter { $0.exercise.lowercased().contains("bench") }.map { $0.weight }.max() ?? 0
                let deadliftPR = entries.filter { $0.exercise.lowercased().contains("deadlift") }.map { $0.weight }.max() ?? 0
                let total = squatPR + benchPR + deadliftPR
                if let goal = award.nextTierGoal {
                    progress = min(Double(total) / Double(goal), 1.0)
                    achieved = Double(total) >= Double(goal)
                    
                    if achieved && award.tier < award.maxTier {
                        award.tier += 1
                        award.nextTierGoal = award.tier * goal
                        award.description = "Combine \(award.nextTierGoal!) lbs from Squat, Bench, Deadlift."
                        award.achieved = false
                    }
                    award.progressDescription = "\(Int(total)) lbs / \(goal) lbs"
                }
                
            case "All-Rounder":
                let uniqueExercises = Set(entries.map { $0.exercise.lowercased() })
                progress = min(Double(uniqueExercises.count) / 5.0, 1.0)
                achieved = uniqueExercises.count >= 5
                
            case "Gym Rat":
                if let latestWorkout = entries.sorted(by: { $0.date > $1.date }).first {
                    let currentMonth = calendar.component(.month, from: latestWorkout.date)
                    let currentYear = calendar.component(.year, from: latestWorkout.date)
                    
                    let monthlyDays = Set(entries.compactMap { entry -> Date? in
                        let components = calendar.dateComponents([.year, .month, .day], from: entry.date)
                        guard components.year == currentYear, components.month == currentMonth else { return nil }
                        return calendar.date(from: components)
                    })
                    
                    let uniqueDayCount = monthlyDays.count
                    progress = min(Double(uniqueDayCount) / 20.0, 1.0)
                    achieved = uniqueDayCount >= 20
                }
                
            default:
                break
            }
            
            // Update award in the published array
            award.progress = progress
            if achieved && !award.achieved {
                award.achieved = true
                award.dateEarned = Date()
            }
            awards[i] = award  // ✅ important: write back the mutated award
        }
    }
    
    private func longestWorkoutStreak(from entries: [WorkoutEntry]) -> Int {
        guard !entries.isEmpty else { return 0 }
        let days = entries.map { Calendar.current.startOfDay(for: $0.date) }
        let sortedDays = Array(Set(days)).sorted()
        
        var longest = 1
        var current = 1
        
        for i in 1..<sortedDays.count {
            let diff = Calendar.current.dateComponents([.day], from: sortedDays[i - 1], to: sortedDays[i]).day ?? 0
            if diff == 1 {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }
        return longest
    }
}



