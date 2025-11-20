//
//  SuggestionsView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 11/20/25.
//

import SwiftUI
import AVKit

struct SuggestionsView: View {
    @State private var selectedExercise: SuggestionExercise? = nil
    
    // Example data
    let suggestions: [SuggestionRegion: [SuggestionMuscle]] = [
        .arms: [
            SuggestionMuscle(name: "Biceps", exercises: [
                SuggestionExercise(name: "Bicep Curl", videoURL: "https://youtu.be/ykJmrZ5v0Oo",
                                   tips: ["Keep elbows close to torso", "Control the motion", "Don't swing"]),
                SuggestionExercise(name: "Hammer Curl", videoURL: "https://youtu.be/zC3nLlEvin4",
                                   tips: ["Neutral grip", "Full range of motion", "Slow eccentric"])
            ]),
            SuggestionMuscle(name: "Triceps", exercises: [
                SuggestionExercise(name: "Tricep Press Machine", videoURL: "https://youtu.be/4W31U8tTVAg",
                                   tips: ["Keep elbows tucked to your sides", "Control the movement with a full range of motion", "Keep shoulders stable and relaxed"]),
                SuggestionExercise(name: "JM Press", videoURL: "https://youtu.be/CNN-LwNM_kQ",
                                   tips: ["Keep your elbows tucked in", "Lower the bar in a controlled fashion", "While the bar is going down, bend at your elbows pushing them towards your hips"])
            ]),
            SuggestionMuscle(name: "Shoulders", exercises: [
                SuggestionExercise(name: "Dumbbell Shoulder Press", videoURL: "https://youtu.be/k6tzKisR3NY",
                                   tips: ["Pick a weight that you can control", "Bring the dumbbells down until your elbows are just below you chest", "Push the dumbells back up over your head and slightly back over your traps"]),
                SuggestionExercise(name: "Dumbbell Lateral Raise", videoURL: "https://youtu.be/JIhbYYA1Q90",
                                   tips: ["Lift the dumbbells while leading with your elbows, don't allow your wrists to get higher than your elbows", "Keep your core engaged and back straight throughout the lift", "Use a weight that allows for control and full   range of motion"]),
                SuggestionExercise(name: "Dumbbell Rear Delt Fly", videoURL: "https://youtu.be/KoRDmXocJII",
                                   tips: ["Lift the dumbells up and out", "Squeeze with your rear delt getting the full range of motion", "Control the speed of your repetitions to allow for full rear delt activation"])
            ])
        ]
    ]
    
    var body: some View {
        let sortedRegions = suggestions.keys.sorted { $0.rawValue < $1.rawValue }
        
        NavigationStack {
            List {
                ForEach(sortedRegions, id: \.self) { region in
                    let muscles = suggestions[region] ?? []
                    Section(header: Text(region.rawValue.capitalized).font(.headline).foregroundColor(.blue)) {
                        ForEach(muscles) { muscle in
                            NavigationLink(muscle.name) {
                                MuscleExercisesView(muscle: muscle, selectedExercise: $selectedExercise)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Exercise Suggestions")
            .listStyle(.insetGrouped)
            .sheet(item: $selectedExercise) { exercise in
                ExercisePopupView(exercise: exercise)
            }
        }
    }
}

// MARK: - Exercises List for a Muscle
struct MuscleExercisesView: View {
    let muscle: SuggestionMuscle
    @Binding var selectedExercise: SuggestionExercise?
    
    var body: some View {
        List(muscle.exercises) { exercise in
            Button(action: {
                selectedExercise = exercise
            }) {
                Text(exercise.name)
            }
        }
        .navigationTitle(muscle.name)
        .listStyle(.insetGrouped)
    }
}

// MARK: - Exercise Popup
struct ExercisePopupView: View {
    let exercise: SuggestionExercise
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(exercise.name)
                    .font(.largeTitle.bold())
                
                // Video player
                if let url = URL(string: exercise.videoURL) {
                    Link(destination: url) {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "play.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.white)
                            )
                    }
                }
                
                // Numbered tips
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(exercise.tips.enumerated()), id: \.offset) { index, tip in
                        Text("\(index + 1). \(tip)")
                            .font(.body)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Models
enum SuggestionRegion: String, CaseIterable {
    case arms, legs, chest, back, shoulders, core
}

struct SuggestionMuscle: Identifiable {
    let id = UUID()
    let name: String
    let exercises: [SuggestionExercise]
}

struct SuggestionExercise: Identifiable {
    let id = UUID()
    let name: String
    let videoURL: String
    let tips: [String]
}

// MARK: - Preview
struct SuggestionsView_Previews: PreviewProvider {
    static var previews: some View {
        SuggestionsView()
    }
}
