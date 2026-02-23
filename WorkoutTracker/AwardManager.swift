//
//  AwardManager.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 12/20/25.
//

import Foundation
import SwiftUI

// MARK: - Popup Model
struct AwardPopup: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let icon: String
}

// MARK: - Award Manager
@MainActor
class AwardManager: ObservableObject {

    @Published var awards: [Award] = []

    @Published var activePopup: AwardPopup? {
        didSet {
            if let popup = activePopup {
                print("🚨 POPUP TRIGGERED: \(popup.title) - \(popup.message)")
            }
        }
    }

    private var popupQueue: [AwardPopup] = []

    private let baseGoals: [String: Int] = [
        "10-Day Streak":    10,
        "Workouts Logged":  50,
        "Big Three Club":   1000,
        "All-Rounder":      5,
        "Gym Rat":          15,
        "Early Bird":       10,
        "Night Owl":        10,
        "Perfect Week":     1
    ]

    private let defaultAwards: [Award] = [
        Award(title: "10-Day Streak",   description: "Workout 10 days in a row.",   icon: "🔥", achieved: false),
        Award(title: "Workouts Logged", description: "Log workouts to level up.",    icon: "🏆", achieved: false, tier: 1, maxTier: 5, nextTierGoal: 50),
        Award(title: "Bench Press PR",  description: "Increase bench weight.",       icon: "💪", achieved: false, tier: 1, maxTier: 4, nextTierGoal: nil),
        Award(title: "Squat PR",        description: "Increase squat weight.",       icon: "🦵", achieved: false, tier: 1, maxTier: 3, nextTierGoal: nil),
        Award(title: "Big Three Club",  description: "Combine lbs (S+B+D).",         icon: "🦍", achieved: false, tier: 1, maxTier: 4, nextTierGoal: 1000),
        Award(title: "All-Rounder",     description: "Try different exercises.",     icon: "🎯", achieved: false, tier: 1, maxTier: 4, nextTierGoal: 5),
        Award(title: "Gym Rat",         description: "Monthly workout frequency.",   icon: "🐀", achieved: false, tier: 1, maxTier: 3, nextTierGoal: 15),
        Award(title: "Early Bird",      description: "Workout before 7AM.",          icon: "🌅", achieved: false, tier: 1, maxTier: 3, nextTierGoal: 10),
        Award(title: "Night Owl",       description: "Workout after 9PM.",           icon: "🌙", achieved: false, tier: 1, maxTier: 3, nextTierGoal: 10),
        Award(title: "Perfect Week",    description: "Workout 7 days in one week.",  icon: "💯", achieved: false)
    ]

    init() {
        self.awards = loadAwards()
    }

    // MARK: - Goal Derivation
    private func goalForTier(_ tier: Int, title: String) -> Int? {
        if title == "Bench Press PR" || title == "Squat PR" { return nil }
        guard let base = baseGoals[title] else { return nil }
        var goal = Double(base)
        for _ in 1..<tier { goal *= 1.5 }
        return Int(goal)
    }

    // MARK: - Persistence
    private func saveAwards() {
        let states = awards.map { award -> [String: Any] in
            var dict: [String: Any] = [
                "title":            award.title,
                "tier":             award.tier,
                "maxTier":          award.maxTier,
                "lastAwardedTier":  award.lastAwardedTier
            ]
            if let date = award.dateEarned { dict["dateEarned"] = date }
            if let firstWeight = award.firstRecordedWeight { dict["firstRecordedWeight"] = firstWeight }
            return dict
        }
        UserDefaults.standard.set(states, forKey: "savedAwardStates")
    }

    private func loadAwards() -> [Award] {
        guard let saved = UserDefaults.standard.array(forKey: "savedAwardStates") as? [[String: Any]] else {
            return defaultAwards
        }

        return defaultAwards.map { defaultAward in
            guard let savedState = saved.first(where: { $0["title"] as? String == defaultAward.title }) else {
                return defaultAward
            }
            var award = defaultAward
            let tier                  = savedState["tier"] as? Int ?? defaultAward.tier
            award.tier                = tier
            award.maxTier             = savedState["maxTier"] as? Int ?? defaultAward.maxTier
            award.lastAwardedTier     = savedState["lastAwardedTier"] as? Int ?? 0
            award.dateEarned          = savedState["dateEarned"] as? Date
            award.firstRecordedWeight = savedState["firstRecordedWeight"] as? Double
            award.nextTierGoal        = goalForTier(tier, title: award.title)
            award.achieved            = false
            return award
        }
    }

    // MARK: - Main Evaluation
    func evaluateAwards(for entries: [WorkoutEntry]) {
        guard !entries.isEmpty else { return }

        let sorted = entries.sorted { $0.date < $1.date }
        let calendar = Calendar.current

        for i in awards.indices {

            var currentVal: Double = 0

            switch awards[i].title {

            case "10-Day Streak":
                currentVal = Double(longestWorkoutStreak(from: sorted))

            case "Workouts Logged":
                currentVal = Double(entries.count)

            case "Bench Press PR":
                let benchWeights = sorted
                    .filter { $0.exercise.lowercased().contains("bench") }
                    .map { $0.weight }
                if let maxW = benchWeights.max() {
                    // Goal is always current max + 25
                    currentVal = maxW
                    awards[i].nextTierGoal = Int(maxW) + 25
                    awards[i].description = "Current goal: \(Int(maxW) + 25) lbs"
                }

            case "Squat PR":
                let squatWeights = sorted
                    .filter { $0.exercise.lowercased().contains("squat") }
                    .map { $0.weight }
                if let maxW = squatWeights.max() {
                    currentVal = maxW
                    awards[i].nextTierGoal = Int(maxW) + 25
                    awards[i].description = "Current goal: \(Int(maxW) + 25) lbs"
                }

            case "Big Three Club":
                let s = entries.filter { $0.exercise.lowercased().contains("squat") }.map { $0.weight }.max() ?? 0
                let b = entries.filter { $0.exercise.lowercased().contains("bench") }.map { $0.weight }.max() ?? 0
                let d = entries.filter { $0.exercise.lowercased().contains("deadlift") }.map { $0.weight }.max() ?? 0
                currentVal = s + b + d

            case "All-Rounder":
                currentVal = Double(Set(entries.map { $0.exercise.lowercased() }).count)

            case "Gym Rat":
                if let latest = entries.max(by: { $0.date < $1.date }) {
                    let month = calendar.component(.month, from: latest.date)
                    let year  = calendar.component(.year,  from: latest.date)
                    let monthlyDays = Set(
                        entries
                            .filter {
                                calendar.component(.month, from: $0.date) == month &&
                                calendar.component(.year,  from: $0.date) == year
                            }
                            .map { calendar.startOfDay(for: $0.date) }
                    )
                    currentVal = Double(monthlyDays.count)
                }

            case "Early Bird":
                let earlyDays = Set(
                    entries
                        .filter { calendar.component(.hour, from: $0.date) < 7 }
                        .map { calendar.startOfDay(for: $0.date) }
                )
                currentVal = Double(earlyDays.count)

            case "Night Owl":
                let lateDays = Set(
                    entries
                        .filter { calendar.component(.hour, from: $0.date) >= 21 }
                        .map { calendar.startOfDay(for: $0.date) }
                )
                currentVal = Double(lateDays.count)

            case "Perfect Week":
                let weekGroups = Dictionary(grouping: entries) {
                    calendar.component(.weekOfYear, from: $0.date)
                }
                let hasFullWeek = weekGroups.values.contains { weekEntries in
                    let uniqueDays = Set(weekEntries.map { calendar.startOfDay(for: $0.date) })
                    return uniqueDays.count >= 7
                }
                currentVal = hasFullWeek ? 1 : 0

            default:
                break
            }

            // DEMOTE tier if data no longer supports the previous tier's threshold
            while awards[i].tier > 1 {
                let previousGoal = Double(goalForTier(awards[i].tier - 1, title: awards[i].title) ?? 1)
                if currentVal < previousGoal {
                    awards[i].tier -= 1
                } else {
                    break
                }
            }

            // For non-PR awards, recompute goal from tier
            if awards[i].title != "Bench Press PR" && awards[i].title != "Squat PR" {
                awards[i].nextTierGoal = goalForTier(awards[i].tier, title: awards[i].title)
            }

            let goal = Double(awards[i].nextTierGoal ?? 1)

            // Update progress bar
            awards[i].progress = min(currentVal / goal, 1.0)

            if awards[i].title == "Big Three Club" {
                awards[i].progressDescription = "\(Int(currentVal)) / \(Int(goal)) lbs"
            }

            // Skip if maxed out and already awarded at max tier
            if awards[i].tier >= awards[i].maxTier && awards[i].lastAwardedTier >= awards[i].maxTier { continue }

            // Only trigger if this tier hasn't been awarded yet
            if currentVal >= goal && awards[i].lastAwardedTier < awards[i].tier {
                triggerAchievement(for: i)
            }
        }

        saveAwards()
    }

    // MARK: - Trigger Logic
    private func triggerAchievement(for index: Int) {
        awards[index].dateEarned = Date()

        let originalTitle = awards[index].title
        let icon = awards[index].icon
        let isMaxTier = awards[index].tier >= awards[index].maxTier

        // Mark this tier as awarded BEFORE bumping
        awards[index].lastAwardedTier = awards[index].tier

        if awards[index].tier < awards[index].maxTier {
            awards[index].tier += 1
        }

        // For PR awards the next goal is always current max + 25,
        // which will be recomputed on next evaluateAwards call
        if originalTitle != "Bench Press PR" && originalTitle != "Squat PR" {
            awards[index].nextTierGoal = goalForTier(awards[index].tier, title: originalTitle)
        }

        awards[index].achieved = false

        let nextGoalText: String
        if isMaxTier {
            nextGoalText = "Max level reached! 🎉"
        } else if let nextGoal = awards[index].nextTierGoal {
            nextGoalText = "Next goal: \(nextGoal) lbs"
        } else {
            nextGoalText = ""
        }

        enqueuePopup(AwardPopup(
            title: "Achievement Unlocked!",
            message: "\(icon) \(originalTitle)! \(nextGoalText)",
            icon: icon
        ))
    }

    // MARK: - Queue Management
    private func enqueuePopup(_ popup: AwardPopup) {
        if activePopup == nil {
            activePopup = popup
        } else {
            popupQueue.append(popup)
        }
    }

    func dismissCurrentPopup() {
        if popupQueue.isEmpty {
            activePopup = nil
        } else {
            activePopup = popupQueue.removeFirst()
        }
    }

    // MARK: - Streak Helper
    private func longestWorkoutStreak(from entries: [WorkoutEntry]) -> Int {
        let days = Array(
            Set(entries.map { Calendar.current.startOfDay(for: $0.date) })
        ).sorted()

        guard !days.isEmpty else { return 0 }

        var longest = 1
        var current = 1

        for i in 1..<days.count {
            let diff = Calendar.current.dateComponents([.day], from: days[i - 1], to: days[i]).day ?? 0
            if diff == 1 {
                current += 1
                longest = max(longest, current)
            } else if diff > 1 {
                current = 1
            }
        }

        return longest
    }
}





