//
//  AwardManager.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 10/20/25.
//

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
        Award(title: "Bench +50 lbs", description: "Increase your bench press by 50 lbs.", icon: "💪", achieved: false),
        Award(title: "100 Workouts", description: "Log 100 total workouts.", icon: "🏆", achieved: false),
        Award(title: "All-Rounder", description: "Log 5 different exercises.", icon: "🎯", achieved: false),
        Award(title: "Gym Rat", description: "Log workouts 20 days in a single month.", icon: "🐀", achieved: false),
        Award(title: "1000 Lb Club", description: "Combined total of 1000lbs from Deadlift, Squat and Bench Press", icon:"🦍", achieved: false),
    ]
    
    func evaluateAwards(for entries: [WorkoutEntry]) {
        guard !entries.isEmpty else { return }
        let sorted = entries.sorted(by: { $0.date < $1.date })
        
        for i in awards.indices {
            let award = awards[i]
            var progress: Double = 0
            var achieved = false
            
            switch award.title {
            case "10-Day Streak":
                let streak = longestWorkoutStreak(from: sorted)
                progress = min(Double(streak) / 10.0, 1.0)
                achieved = streak >= 10
                
            case "Bench +50 lbs":
                let benchEntries = sorted.filter { $0.exercise.lowercased().contains("bench") }
                if let first = benchEntries.first, let last = benchEntries.last {
                    let diff = max(0, last.weight - first.weight)
                    progress = min(Double(diff) / 50.0, 1.0)
                    achieved = diff >= 50
                }
                
            case "100 Workouts":
                progress = min(Double(entries.count) / 100.0, 1.0)
                achieved = entries.count >= 100
                
            case "All-Rounder":
                let uniqueExercises = Set(entries.map { $0.exercise.lowercased() })
                progress = min(Double(uniqueExercises.count) / 5.0, 1.0)
                achieved = uniqueExercises.count >= 5
                
            case "Gym Rat":
                let calendar = Calendar.current

                if let latestWorkout = entries.sorted(by: { $0.date > $1.date }).first {
                    let currentMonth = calendar.component(.month, from: latestWorkout.date)
                    let currentYear = calendar.component(.year, from: latestWorkout.date)

                    // Get all unique workout days in this month
                    let monthlyDays = Set(entries.compactMap { entry -> Date? in
                        let components = calendar.dateComponents([.year, .month, .day], from: entry.date)
                        guard components.year == currentYear, components.month == currentMonth else { return nil }
                        return calendar.date(from: components)
                    })

                    let uniqueDayCount = monthlyDays.count
                    progress = min(Double(uniqueDayCount) / 20.0, 1.0)
                    achieved = uniqueDayCount >= 20
                }
                
            case "1000 Lb Club":
                // Calculate best Squat, Bench, and Deadlift PRs
                let squatPR = entries
                    .filter { $0.exercise.lowercased().contains("squat") }
                    .map { $0.weight }
                    .max() ?? 0.0

                let benchPR = entries
                    .filter { $0.exercise.lowercased().contains("bench") }
                    .map { $0.weight }
                    .max() ?? 0.0

                let deadliftPR = entries
                    .filter { $0.exercise.lowercased().contains("deadlift") }
                    .map { $0.weight }
                    .max() ?? 0.0

                let total = squatPR + benchPR + deadliftPR
                    progress = min(total / 1000.0, 1.0)
                    achieved = total >= 1000
                    awards[i].progressDescription = "\(Int(total)) lbs / 1000 lbs"

                
            default:
                break
            }
            
            awards[i].progress = progress
            if achieved && !awards[i].achieved {
                awards[i].achieved = true
                awards[i].dateEarned = Date()
            }
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

