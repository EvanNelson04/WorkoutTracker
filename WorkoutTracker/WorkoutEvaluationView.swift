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
            ZStack {
                // Gradient background
                AppColors.gradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Workout Evaluation")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.bottom, 10)
                        
                        if workoutData.entries.isEmpty {
                            Text("No workouts logged yet.")
                                .italic()
                                .foregroundColor(.white.opacity(0.8))
                        } else {
                            ForEach(groupedWorkouts.keys.sorted(), id: \.self) { muscle in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(muscle)
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.white)
                                        .padding(.vertical, 5)
                                    
                                    let exercises = Array(Set(groupedWorkouts[muscle, default: []].map { $0.exercise })).sorted()
                                    
                                    ForEach(exercises, id: \.self) { exercise in
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("\(exercise) Analysis:")
                                                .font(.headline)
                                                .foregroundColor(.white.opacity(0.9))
                                            
                                            if let latest = latestEntry(for: exercise) {
                                                Text(evaluate(latest: latest, for: exercise))
                                                    .foregroundColor(.white.opacity(0.85))
                                                    .padding(.top, 2)
                                            }
                                        }
                                        .padding()
                                        .background(
                                            AppColors.gradient
                                                .mask(RoundedRectangle(cornerRadius: 12))
                                        )
                                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                                    }
                                }
                                .padding(.bottom, 15)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Evaluation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.gradient, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    // MARK: - Helper Methods
    
    func latestEntry(for exercise: String) -> WorkoutEntry? {
        workoutData.entries
            .filter { $0.exercise.lowercased() == exercise.lowercased() }
            .sorted { $0.date > $1.date }
            .first
    }
    
    func evaluate(latest: WorkoutEntry, for exercise: String) -> String {
        // ... same as your current evaluate() implementation
        let matchingEntries = workoutData.entries
            .filter { $0.exercise.lowercased() == exercise.lowercased() && $0.id != latest.id }
            .sorted { $0.date > $1.date }

        guard let prev = matchingEntries.first else {
            return "🔥 First \(exercise) session logged — strong start! Keep it up!"
        }

        let lastThree = Array(matchingEntries.prefix(3))
        let avgWeight = lastThree.map { $0.weight }.reduce(0, +) / Double(max(lastThree.count, 1))
        let avgReps = Double(lastThree.map { $0.reps }.reduce(0, +)) / Double(max(lastThree.count, 1))

        var feedback = "🏋️ \(exercise.capitalized) Progress Report:\n"

        if latest.weight > prev.weight {
            feedback += "• You lifted \(Int(latest.weight - prev.weight)) lbs more than last time — great strength gains!\n"
        } else if latest.weight < prev.weight {
            feedback += "• Slight drop in weight (\(Int(latest.weight)) vs \(Int(prev.weight))). Smart if focusing on form or recovery.\n"
        } else {
            feedback += "• Maintained the same weight (\(Int(latest.weight)) lbs). Perfect for reinforcing technique.\n"
        }

        if latest.reps > prev.reps {
            feedback += "• You hit \(latest.reps) reps — up from \(prev.reps)! Strong endurance improvement.\n"
        } else if latest.reps < prev.reps {
            feedback += "• Fewer reps (\(latest.reps) vs \(prev.reps)). Rest or warm-up might help next time.\n"
        } else {
            feedback += "• Matched your previous reps (\(latest.reps)). Stay consistent!\n"
        }

        if latest.weight > avgWeight || Double(latest.reps) > avgReps {
            feedback += "📈 Trending above recent 3-session average — progress looks great!\n"
        } else {
            feedback += "⏳ Close to average performance. Stay patient and consistent.\n"
        }

        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let recentCount = workoutData.entries.filter {
            $0.exercise.lowercased() == exercise.lowercased() && $0.date >= oneWeekAgo
        }.count

        if recentCount > 2 {
            feedback += "⚠️ Logged \(exercise) \(recentCount) times this week — optimize recovery.\n"
        } else if recentCount == 2 {
            feedback += "✅ Great weekly consistency — two sessions ideal.\n"
        } else {
            feedback += "💡 Try adding one more \(exercise) session this week.\n"
        }

        feedback += "\nKeep tracking — your progress graph tells the full story 📊."
        return feedback.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}



