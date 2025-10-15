//
//  WorkoutChartView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 9/23/25.
//

import SwiftUI
import Charts

struct WorkoutChartView: View {
    @EnvironmentObject var workoutData: WorkoutData
    @State private var selectedExercise: String? = nil

    var body: some View {
        VStack {
            // Picker grouped by muscle group
            Picker("Select Exercise", selection: $selectedExercise) {
                Text("Select Exercise").tag(String?.none)
                
                // Group exercises by muscle group
                ForEach(groupedExercises.keys.sorted(), id: \.self) { group in
                    // Group label (e.g., Back, Chest)
                    Text("— \(group) —")
                        .font(.headline)
                    
                    ForEach(groupedExercises[group] ?? [], id: \.self) { exercise in
                        Text(exercise).tag(String?.some(exercise))
                    }
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()

            // Chart for selected exercise
            if let exercise = selectedExercise {
                Chart {
                    ForEach(entries(for: exercise)) { entry in
                        LineMark(
                            x: .value("Date", entry.date),
                            y: .value("Weight", entry.weight)
                        )
                        .interpolationMethod(.linear)
                        .foregroundStyle(.blue)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        
                        PointMark(
                            x: .value("Date", entry.date),
                            y: .value("Weight", entry.weight)
                        )
                        .foregroundStyle(.red)
                        .annotation(position: .top) {
                            VStack(spacing: 2) {
                                Text("\(entry.weight, specifier: "%.0f")lbs x \(entry.reps) rep\(entry.reps > 1 ? "s" : "")")
                                    .font(.caption2)
                                    .bold()
                                Text(shortDate(entry.date))
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .frame(height: 350)
                .padding()
                
                Text("\(exercise) Progress")
                    .font(.headline)
            } else {
                Text("Select an exercise to see its chart.")
                    .italic()
                    .padding()
            }
            
            Spacer()
        }
        .navigationTitle("Exercise Charts")
    }

    // Group exercises by muscle group
    var groupedExercises: [String: [String]] {
        let grouped = Dictionary(grouping: workoutData.entries) { entry in
            entry.muscleGroup.isEmpty ? "Other" : entry.muscleGroup
        }
        return grouped.mapValues { entries in
            Array(Set(entries.map { $0.exercise })).sorted()
        }
    }

    // Filter entries for selected exercise
    func entries(for exercise: String) -> [WorkoutEntry] {
        workoutData.entries
            .filter { $0.exercise == exercise }
            .sorted { $0.date < $1.date }
    }

    // Format date nicely
    func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

