//
//  AddWorkoutView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 9/23/25.
//

import SwiftUI

struct AddWorkoutView: View {
    @EnvironmentObject var workoutData: WorkoutData
    @Environment(\.dismiss) var dismiss
    
    @State private var exercise = ""
    @State private var weight = ""
    @State private var reps = ""
    @State private var heartRate = ""
    
    @State private var showConfirmation = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Exercise Info") {
                    TextField("Exercise", text: $exercise)
                    TextField("Weight (lbs)", text: $weight)
                        .keyboardType(.decimalPad)
                    TextField("Reps", text: $reps)
                        .keyboardType(.numberPad)
                    TextField("Heart Rate (optional)", text: $heartRate)
                        .keyboardType(.decimalPad)
                }
                
                Button("Save") {
                    let entry = WorkoutEntry(
                        date: Date(),
                        exercise: exercise,
                        weight: Double(weight) ?? 0,
                        reps: Int(reps) ?? 0,
                        heartRate: Double(heartRate)
                    )
                    workoutData.add(entry: entry)
                    showConfirmation = true
                }
                .alert("Workout Added!", isPresented: $showConfirmation) {
                    Button("OK") {
                        dismiss()
                    }
                }
            }
            .navigationTitle("Add Workout")
        }
    }
}

