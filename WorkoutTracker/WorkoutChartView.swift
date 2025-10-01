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
            // Picker to select exercise
            Picker("Select Exercise", selection: $selectedExercise) {
                Text("Select Exercise").tag(String?.none)
                ForEach(uniqueExercises(), id: \.self) { exercise in
                    Text(exercise).tag(String?.some(exercise))
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            
            // Show chart for selected exercise
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
    
    // Get all unique exercises
    func uniqueExercises() -> [String] {
        Array(Set(workoutData.entries.map { $0.exercise })).sorted()
    }
    
    // Filter entries for the selected exercise
    func entries(for exercise: String) -> [WorkoutEntry] {
        workoutData.entries
            .filter { $0.exercise == exercise }
            .sorted { $0.date < $1.date }
    }
    
    // Short date formatter
    func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}
