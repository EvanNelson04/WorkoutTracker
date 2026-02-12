//
//  SuggestionsView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 11/20/25.
//

import SwiftUI
import AVKit
import SwiftUI

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
    let tips: [String]
    
    // Computed property for YouTube search URL
    var videoURL: URL? {
        let query = name.replacingOccurrences(of: " ", with: "+")
        return URL(string: "https://www.youtube.com/results?search_query=\(query)+proper+form")
    }
}

// MARK: - Main View
struct SuggestionsView: View {
    @State private var selectedExercise: SuggestionExercise? = nil

    private var sortedRegions: [SuggestionRegion] {
        SuggestionRegion.allCases.sorted { $0.rawValue < $1.rawValue }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Full-screen gradient background
                AppColors.gradient
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 24, pinnedViews: []) {
                        ForEach(sortedRegions, id: \.self) { region in
                            RegionSectionView(
                                region: region,
                                muscles: SuggestionsData.content[region] ?? [],
                                selectedExercise: $selectedExercise
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Exercise Suggestions")
            .sheet(item: $selectedExercise) { exercise in
                ExercisePopupView(exercise: exercise)
            }
        }
    }
}


// MARK: - Sub-Views
struct RegionSectionView: View {
    let region: SuggestionRegion
    let muscles: [SuggestionMuscle]
    @Binding var selectedExercise: SuggestionExercise?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(region.rawValue.capitalized)
                .font(.headline)
                .fontWeight(needsHighlight(region) ? .bold : .regular)
                .foregroundColor(needsHighlight(region) ? .white : .blue)
                .padding(.bottom, 4)

            ForEach(muscles) { muscle in
                NavigationLink(destination: MuscleExercisesView(muscle: muscle, selectedExercise: $selectedExercise)) {
                    Text(muscle.name)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                }
            }
        }
    }

    private func needsHighlight(_ region: SuggestionRegion) -> Bool {
        // Only highlight these regions
        switch region {
        case .arms, .back, .chest, .core, .legs, .shoulders:
            return true
        }
    }
}


struct MuscleExercisesView: View {
    let muscle: SuggestionMuscle
    @Binding var selectedExercise: SuggestionExercise?

    var body: some View {
        ZStack {
            AppColors.gradient
                .ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(muscle.exercises) { exercise in
                        Button {
                            selectedExercise = exercise
                        } label: {
                            HStack {
                                Text(exercise.name)
                                    .foregroundColor(.white)
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "play.circle.fill")
                                    .foregroundColor(.yellow)
                            }
                            .padding()
                            .background(AppColors.gradient)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle(muscle.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct ExercisePopupView: View {
    let exercise: SuggestionExercise
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(exercise.name)
                    .font(.largeTitle.bold())
                
                if let url = exercise.videoURL {
                    Link(destination: url) {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(height: 200)
                            .cornerRadius(12)
                            .overlay(
                                Image(systemName: "play.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.white)
                            )
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Pro Tips")
                        .font(.headline)
                    
                    ForEach(Array(exercise.tips.enumerated()), id: \.offset) { index, tip in
                        HStack(alignment: .top) {
                            Text("\(index + 1).")
                                .bold()
                            Text(tip)
                        }
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

// MARK: - Data Store
struct SuggestionsData {
    static let content: [SuggestionRegion: [SuggestionMuscle]] = [
        .arms: [
            SuggestionMuscle(name: "Biceps", exercises: [
                SuggestionExercise(name: "Bicep Curl", tips: ["Keep elbows close to torso", "Control the motion", "Don't swing"]),
                SuggestionExercise(name: "Hammer Curl", tips: ["Neutral grip", "Full range of motion", "Slow eccentric"]),
                SuggestionExercise(name: "Preacher Curl", tips: ["Full stretch at bottom", "Squeeze at the top", "Control tempo"]),
                SuggestionExercise(name: "Cable Curl", tips: ["Keep elbows fixed", "Avoid swinging", "Controlled negative"])
            ]),
            SuggestionMuscle(name: "Triceps", exercises: [
                SuggestionExercise(name: "Tricep Press Machine", tips: ["Keep elbows tucked", "Full range of motion", "Control movement"]),
                SuggestionExercise(name: "JM Press", tips: ["Elbows tucked", "Controlled descent", "Push elbows toward hips"]),
                SuggestionExercise(name: "Rope Pushdown", tips: ["Spread rope at bottom", "Full extension", "Slow negative"]),
                SuggestionExercise(name: "Overhead Tricep Extension", tips: ["Keep elbows tight", "Full stretch", "Controlled reps"])
            ])
        ],
        .chest: [
            SuggestionMuscle(name: "Upper Chest", exercises: [
                SuggestionExercise(name: "Incline Dumbbell Press", tips: ["Retract shoulder blades", "Slow descent", "Press up and back"]),
                SuggestionExercise(name: "Incline Barbell Press", tips: ["Don't flare elbows", "Controlled reps", "Drive feet into floor"]),
                SuggestionExercise(name: "Low Cable Fly", tips: ["Soft elbows", "Squeeze at top", "Controlled negative"]),
                SuggestionExercise(name: "Machine Incline Press", tips: ["Chest up", "Full stretch", "Slow tempo"])
            ]),
            SuggestionMuscle(name: "Mid Chest", exercises: [
                SuggestionExercise(name: "Barbell Bench Press", tips: ["Feet planted", "Bar to mid-chest", "No bouncing"]),
                SuggestionExercise(name: "Dumbbell Bench Press", tips: ["Control reps", "Wrists stacked", "Squeeze at top"]),
                SuggestionExercise(name: "Chest Press Machine", tips: ["Back flat on pad", "Full extension", "Controlled movement"]),
                SuggestionExercise(name: "Push-Ups", tips: ["Straight body line", "Chest to floor", "Engage core"])
            ])
        ],
        .back: [
            SuggestionMuscle(name: "Lats", exercises: [
                SuggestionExercise(name: "Lat Pulldown", tips: ["Pull elbows down", "Slight lean back", "Control upward motion"]),
                SuggestionExercise(name: "Pull-Ups", tips: ["Full stretch", "Chest to bar", "No swinging"]),
                SuggestionExercise(name: "Single Arm Dumbbell Row", tips: ["Flat back", "Pull toward hip", "Controlled reps"]),
                SuggestionExercise(name: "Straight Arm Pulldown", tips: ["Soft elbows", "Squeeze lats", "Slow negative"])
            ]),
            SuggestionMuscle(name: "Upper Back", exercises: [
                SuggestionExercise(name: "Barbell Row", tips: ["Neutral spine", "Pull to lower chest", "Controlled tempo"]),
                SuggestionExercise(name: "Seated Cable Row", tips: ["Chest up", "Squeeze shoulder blades", "Slow return"]),
                SuggestionExercise(name: "Face Pull", tips: ["Pull to face level", "External rotation", "Control weight"]),
                SuggestionExercise(name: "T-Bar Row", tips: ["Neutral back", "Full contraction", "Controlled eccentric"])
            ])
        ],
        .legs: [
            SuggestionMuscle(name: "Quads", exercises: [
                SuggestionExercise(name: "Barbell Back Squat", tips: ["Chest up", "Push knees out", "Depth below parallel"]),
                SuggestionExercise(name: "Leg Press", tips: ["Don't lock knees", "Controlled descent", "Full range"]),
                SuggestionExercise(name: "Bulgarian Split Squat", tips: ["Torso upright", "Knee tracks over toes", "Slow eccentric"]),
                SuggestionExercise(name: "Leg Extension", tips: ["Pause at top", "Controlled negative", "No swinging"])
            ]),
            SuggestionMuscle(name: "Hamstrings", exercises: [
                SuggestionExercise(name: "Romanian Deadlift", tips: ["Hinge at hips", "Bar close to legs", "Feel hamstring stretch"]),
                SuggestionExercise(name: "Lying Leg Curl", tips: ["Control both ways", "Squeeze at top", "Avoid hip lift"]),
                SuggestionExercise(name: "Seated Leg Curl", tips: ["Full stretch", "Controlled reps", "Hips down"]),
                SuggestionExercise(name: "Glute Ham Raise", tips: ["Slow eccentric", "Engage glutes", "Neutral spine"])
            ]),
            SuggestionMuscle(name: "Calves", exercises: [
                SuggestionExercise(name: "Standing Calf Raise", tips: ["Full stretch", "Pause at top", "Slow tempo"]),
                SuggestionExercise(name: "Seated Calf Raise", tips: ["Controlled reps", "Deep stretch", "Don't bounce"])
            ])
        ],
        .core: [
            SuggestionMuscle(name: "Abs", exercises: [
                SuggestionExercise(name: "Cable Crunch", tips: ["Flex spine downward", "Control return", "Engage core"]),
                SuggestionExercise(name: "Hanging Leg Raise", tips: ["No swinging", "Raise with abs", "Slow descent"])
            ]),
            SuggestionMuscle(name: "Obliques", exercises: [
                SuggestionExercise(name: "Cable Woodchopper", tips: ["Rotate torso", "Controlled movement", "Engage obliques"]),
                SuggestionExercise(name: "Russian Twist", tips: ["Control rotation", "Chest lifted", "Don't rush"])
            ])
        ],
        .shoulders: [
            SuggestionMuscle(name:"Front Delt", exercises: [
                SuggestionExercise(name: "Dumbbell Shoulder Press", tips: ["Control weight", "Lower to just below chest", "Press overhead slightly back"]),
                SuggestionExercise(name: "Front Dumbbell Raise", tips: ["Lead with elbows", "Keep core tight", "Control the weight"]),
                SuggestionExercise(name: "Barbell Overhead Press", tips: ["Press overhead slowly", "Avoid arching back", "Engage core"]),
            ]),
            SuggestionMuscle(name: "Medial Delt", exercises: [
                SuggestionExercise(name: "Dumbbell Lateral Raise", tips: ["Lead with elbows", "Core tight", "Controlled tempo"]),
                SuggestionExercise(name: "Cable Lateral Raise", tips: ["Slight bend in elbows", "Lift to shoulder height", "Slow negative"]),

            ]),
            SuggestionMuscle(name: "Rear Delt", exercises: [
                SuggestionExercise(name: "Rear Delt Fly", tips: ["Lift out and back", "Squeeze rear delts", "Slow reps"]),
                SuggestionExercise(name: "Face Pull", tips: ["Pull to face level", "External rotation", "Control weight"])
                 
            ])
        ]
    ]
}

// MARK: - Preview
struct SuggestionsView_Previews: PreviewProvider {
    static var previews: some View {
        SuggestionsView()
    }
}

