//
//  WorkoutEvaluationView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 9/23/25.
//

import SwiftUI

struct WorkoutEvaluationView: View {
    @EnvironmentObject var workoutData: WorkoutData
    
    // Group workouts by muscle group
    private var groupedWorkouts: [String: [WorkoutEntry]] {
        Dictionary(grouping: workoutData.entries) { entry in
            entry.muscleGroup.isEmpty ? "Other" : entry.muscleGroup
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Workout Evaluation")
                        .font(.title)
                        .padding(.bottom, 10)
                    
                    if workoutData.entries.isEmpty {
                        Text("No workouts logged yet.")
                            .italic()
                    } else {
                        // Loop through each muscle group (Back, Chest, etc.)
                        ForEach(groupedWorkouts.keys.sorted(), id: \.self) { muscle in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(muscle)
                                    .font(.title2)
                                    .bold()
                                    .padding(.vertical, 5)
                                
                                // Unique exercises under each muscle group
                                let exercises = Array(Set(groupedWorkouts[muscle, default: []].map { $0.exercise })).sorted()
                                
                                ForEach(exercises, id: \.self) { exercise in
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("\(exercise) Analysis:")
                                            .font(.headline)
                                        
                                        if let latest = latestEntry(for: exercise) {
                                            Text(evaluate(latest: latest, for: exercise))
                                                .padding(.top, 2)
                                        }
                                    }
                                    .padding(.bottom, 8)
                                }
                            }
                            .padding(.bottom, 15)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Evaluation")
        }
    }
    
    // MARK: - Helper Methods
    
    // Get latest entry for a specific exercise
    func latestEntry(for exercise: String) -> WorkoutEntry? {
        workoutData.entries
            .filter { $0.exercise.lowercased() == exercise.lowercased() }
            .sorted { $0.date > $1.date }
            .first
    }
    
    // Evaluate latest entry vs previous entry for the same exercise
    func evaluate(latest: WorkoutEntry, for exercise: String) -> String {
        let matchingEntries = workoutData.entries
            .filter { $0.exercise.lowercased() == exercise.lowercased() && $0.id != latest.id }
            .sorted { $0.date > $1.date }

        guard let prev = matchingEntries.first else {
            return "🔥 First \(exercise) session logged — strong start! Keep it up!"
        }

        // Trend (last 3 sessions)
        let lastThree = Array(matchingEntries.prefix(3))
        let avgWeight = lastThree.map { $0.weight }.reduce(0, +) / Double(max(lastThree.count, 1))
        let avgReps = Double(lastThree.map { $0.reps }.reduce(0, +)) / Double(max(lastThree.count, 1))

        var feedback = "🏋️ \(exercise.capitalized) Progress Report:\n"

        // Weight progress
        if latest.weight > prev.weight {
            let diff = latest.weight - prev.weight
            feedback += "• You lifted \(Int(diff)) lbs more than last time — great strength gains!\n"
        } else if latest.weight < prev.weight {
            feedback += "• Slight drop in weight (\(Int(latest.weight)) vs \(Int(prev.weight))). Smart if you’re focusing on form or recovery.\n"
        } else {
            feedback += "• Maintained the same weight (\(Int(latest.weight)) lbs). Perfect for reinforcing good technique.\n"
        }

        // Reps progress
        if latest.reps > prev.reps {
            feedback += "• You hit \(latest.reps) reps — up from \(prev.reps)! Strong endurance improvement.\n"
        } else if latest.reps < prev.reps {
            feedback += "• Fewer reps (\(latest.reps) vs \(prev.reps)). Rest, nutrition, or warm-up might help next time.\n"
        } else {
            feedback += "• Matched your previous reps (\(latest.reps)). Stay consistent!\n"
        }

        // Trend summary
        if latest.weight > avgWeight || Double(latest.reps) > avgReps {
            feedback += "📈 You’re trending above your recent 3-session average — progress looks great!\n"
        } else {
            feedback += "⏳ You’re close to your average performance. Stay patient and consistent.\n"
        }

        // Frequency check
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let recentCount = workoutData.entries.filter {
            $0.exercise.lowercased() == exercise.lowercased() && $0.date >= oneWeekAgo
        }.count

        if recentCount > 2 {
            feedback += "⚠️ You’ve logged \(exercise) \(recentCount) times this week — try capping it at 2 sessions to optimize recovery.\n"
        } else if recentCount == 2 {
            feedback += "✅ Great weekly consistency — two \(exercise) sessions is ideal for steady progress.\n"
        } else {
            feedback += "💡 Try adding one more \(exercise) session this week for balanced training volume.\n"
        }

        feedback += "\nKeep tracking your data — your progress graph will tell the full story 📊."

        return feedback.trimmingCharacters(in: .whitespacesAndNewlines)
    }

}


