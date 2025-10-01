//
//  WorkoutEvaluationView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 9/23/25.
//

import SwiftUI

struct WorkoutEvaluationView: View {
    @EnvironmentObject var workoutData: WorkoutData
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Workout Evaluation")
                        .font(.title)
                        .padding(.bottom, 10)
                    
                    if workoutData.entries.isEmpty {
                        Text("No workouts logged yet.")
                            .italic()
                    } else {
                        // Get all unique exercises
                        let exercises = Array(Set(workoutData.entries.map { $0.exercise }))
                        
                        ForEach(exercises, id: \.self) { exercise in
                            VStack(alignment: .leading, spacing: 5) {
                                Text("\(exercise) Analysis:")
                                    .font(.headline)
                                
                                if let latest = latestEntry(for: exercise) {
                                    Text(evaluate(latest: latest, for: exercise))
                                        .padding(.top, 2)
                                }
                            }
                            .padding(.bottom, 10)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Evaluation")
        }
    }
    
    // Get latest entry for a specific exercise
    func latestEntry(for exercise: String) -> WorkoutEntry? {
        workoutData.entries
            .filter { $0.exercise.lowercased() == exercise.lowercased() }
            .sorted { $0.date > $1.date }
            .first
    }
    
    // Evaluate latest entry vs previous entry for the same exercise
    func evaluate(latest: WorkoutEntry, for exercise: String) -> String {
        let previous = workoutData.entries
            .filter { $0.exercise.lowercased() == exercise.lowercased() && $0.id != latest.id }
            .sorted { $0.date > $1.date }
            .first
        
        guard let prev = previous else {
            return "This is your first \(exercise) entry. Keep going!"
        }
        
        var feedback = ""
        
        if latest.reps > prev.reps {
            feedback += "Great job! You did more reps this time (\(latest.reps) vs \(prev.reps)).\n"
        } else if latest.reps < prev.reps {
            feedback += "Fewer reps than last time (\(latest.reps) vs \(prev.reps)). Focus on technique or rest.\n"
        } else {
            feedback += "Same reps as last time (\(latest.reps)). Keep pushing!\n"
        }
        
        if latest.weight > prev.weight {
            feedback += "Increased weight: \(latest.weight) lbs vs \(prev.weight) lbs."
        } else if latest.weight < prev.weight {
            feedback += "Weight decreased: \(latest.weight) lbs vs \(prev.weight) lbs."
        }
        
        return feedback
    }
}

