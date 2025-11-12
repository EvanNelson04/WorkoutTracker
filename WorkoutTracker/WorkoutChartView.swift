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
        ZStack {
            AppColors.gradient
                .ignoresSafeArea()
            
            VStack {
                // Picker
                Picker(selection: $selectedExercise) {
                    Text("Select Exercise").tag(String?.none)
                    ForEach(groupedExercises.keys.sorted(), id: \.self) { group in
                        Text("— \(group) —").font(.headline)
                        ForEach(groupedExercises[group] ?? [], id: \.self) { exercise in
                            Text(exercise).tag(String?.some(exercise))
                        }
                    }
                } label: {
                    Text(selectedExercise ?? "Select Exercise")
                        .foregroundColor(.white)
                        .bold()
                }
                .pickerStyle(MenuPickerStyle())
                .accentColor(.white)
                .padding()
                
                // Chart
                if let exercise = selectedExercise {
                    let exerciseEntries = entries(for: exercise)
                    
                    if exerciseEntries.isEmpty {
                        Text("No data available for \(exercise).")
                            .italic()
                            .foregroundColor(.white)
                            .padding()
                    } else {
                        Chart {
                            // Enumerate to give each point an index for even spacing
                            ForEach(Array(exerciseEntries.enumerated()), id: \.offset) { index, entry in
                                // Vertical dashed stem
                                RuleMark(
                                    x: .value("Index", index),
                                    yStart: .value("Start", 0),
                                    yEnd: .value("Weight", entry.weight)
                                )
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                                .foregroundStyle(.white.opacity(0.6))
                                
                                // Line connecting points
                                LineMark(
                                    x: .value("Index", index),
                                    y: .value("Weight", entry.weight)
                                )
                                .interpolationMethod(.linear)
                                .foregroundStyle(.white)
                                .lineStyle(StrokeStyle(lineWidth: 2))
                                
                                // Data point
                                PointMark(
                                    x: .value("Index", index),
                                    y: .value("Weight", entry.weight)
                                )
                                .foregroundStyle(.red)
                                .annotation(position: .top) {
                                    // Avoid overlap: shift every other label slightly
                                    Text("\(entry.weight, specifier: "%.0f")lbs x \(entry.reps) rep\(entry.reps > 1 ? "s" : "")")
                                        .font(.caption2)
                                        .bold()
                                        .foregroundColor(.white)
                                        .offset(y: index % 2 == 0 ? -10 : -25)
                                }
                            }
                        }
                        .frame(height: 350)
                        .padding()
                        .chartXAxis {
                            AxisMarks(values: Array(exerciseEntries.indices)) { value in
                                AxisGridLine()
                                    .foregroundStyle(.white.opacity(0.6))
                                AxisValueLabel {
                                    let index = value.as(Int.self) ?? 0
                                    let date = exerciseEntries[index].date
                                    Text(shortMonthDay(date))
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                        .rotationEffect(.degrees(-45))
                                        .offset(x: -4, y: 4)
                                }
                            }
                        }
                        .chartYAxis {
                            AxisMarks(values: .automatic(desiredCount: 6)) { value in
                                AxisGridLine()
                                    .foregroundStyle(.white.opacity(0.6))
                                AxisValueLabel {
                                    if let weight = value.as(Double.self) {
                                        Text("\(Int(weight))lbs")
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        
                        Text("\(exercise) Progress")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top, 4)
                    }
                } else {
                    Text("Select an exercise to see its chart.")
                        .italic()
                        .foregroundColor(.white)
                        .padding()
                }
                
                Spacer()
            }
            .navigationBarTitle("Exercise Charts", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Exercise Charts")
                        .foregroundColor(.white)
                        .font(.headline)
                }
            }
        }
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
    
    // Short date (e.g., "Oct 14")
    func shortMonthDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}
