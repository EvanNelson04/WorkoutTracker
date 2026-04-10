//
//  AddWorkoutView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 9/23/25
//

import SwiftUI

struct AddWorkoutView: View {
    @EnvironmentObject var workoutData: WorkoutData
    @EnvironmentObject var awardManager: AwardManager
    @Environment(\.dismiss) var dismiss
    
    @State private var muscleGroup = ""
    @State private var exercise = ""
    @State private var weight = ""
    @State private var reps = ""
    
    @State private var showConfirmation = false
    @State private var isPressed = false
    
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case exercise
        case weight
        case reps
    }
    
    private let muscleGroups = ["Chest", "Back", "Legs", "Arms", "Shoulders", "Core"]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.gradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Add Workout")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        VStack(spacing: 15) {
                            HStack {
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .foregroundColor(.white)
                                Picker("Muscle Group", selection: $muscleGroup) {
                                    ForEach(muscleGroups, id: \.self) { group in
                                        Text(group)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                            
                            HStack {
                                Image(systemName: "dumbbell.fill")
                                    .foregroundColor(.purple)
                                TextField("Exercise", text: $exercise)
                                    .foregroundColor(.white)
                                    .focused($focusedField, equals: .exercise)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .weight
                                    }
                            }
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                            
                            HStack {
                                Image(systemName: "scalemass.fill")
                                    .foregroundColor(.green)
                                TextField("Weight (lbs)", text: $weight)
                                    .keyboardType(.decimalPad)
                                    .foregroundColor(.white)
                                    .focused($focusedField, equals: .weight)
                            }
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                            
                            HStack {
                                Image(systemName: "repeat")
                                    .foregroundColor(.orange)
                                TextField("Reps", text: $reps)
                                    .keyboardType(.numberPad)
                                    .foregroundColor(.white)
                                    .focused($focusedField, equals: .reps)
                            }
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            focusedField = nil
                            isPressed = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isPressed = false
                                saveWorkout()
                            }
                        }) {
                            Text("Save")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color.green, Color.blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(15)
                                .scaleEffect(isPressed ? 0.95 : 1)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert("Workout Added!", isPresented: $showConfirmation) {
                Button("OK") {
                    focusedField = nil
                    awardManager.evaluateAwards(for: workoutData.entries)
                    dismiss()
                }
            }
            .sheet(item: $awardManager.activePopup) { popup in
                AwardPopupView(popup: popup) {
                    awardManager.dismissCurrentPopup()
                }
            }
        }
    }
    
    private func saveWorkout() {
        let cleanExercise = exercise.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
        let cleanMuscleGroup = muscleGroup.trimmingCharacters(in: .whitespacesAndNewlines).capitalized

        let entry = WorkoutEntry(
            date: Date(),
            muscleGroup: cleanMuscleGroup,
            exercise: cleanExercise,
            weight: Double(weight) ?? 0,
            reps: Int(reps) ?? 0
        )

        workoutData.add(entry: entry)
        showConfirmation = true
    }
}




