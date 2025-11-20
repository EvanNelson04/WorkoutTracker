//
//  WorkoutProgressView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 9/23/25.
//  Updated for unified progress tab with evaluation + graph
//

import SwiftUI
import Charts

struct WorkoutProgressView: View {
    @EnvironmentObject var workoutData: WorkoutData
    
    @State private var selectedExercise: String? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.gradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .center, spacing: 20) {
                        Text("Exercise Progress")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        // MARK: - Exercise Picker
                        Picker("Select Exercise", selection: $selectedExercise) {
                            Text("Select Exercise").tag(String?.none)
                            ForEach(groupedExercises.keys.sorted(), id: \.self) { group in
                                Text("— \(group) —").font(.headline)
                                ForEach(groupedExercises[group] ?? [], id: \.self) { exercise in
                                    Text(exercise).tag(String?.some(exercise))
                                }
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .accentColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // MARK: - Chart
                        if let exercise = selectedExercise {
                            let exerciseEntries = entries(for: exercise)
                            
                            if exerciseEntries.isEmpty {
                                Text("No data available for \(exercise).")
                                    .italic()
                                    .foregroundColor(.white)
                                    .padding()
                            } else {
                                Chart {
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
                                        
                                        // Data point with annotation
                                        PointMark(
                                            x: .value("Index", index),
                                            y: .value("Weight", entry.weight)
                                        )
                                        .foregroundStyle(.red)
                                        .annotation(position: .top) {
                                            if index % 2 == 0 {
                                                Text("\(entry.weight, specifier: "%.0f")lbs x \(entry.reps)")
                                                    .font(.caption2.bold())
                                                    .foregroundColor(.white)
                                                    .offset(
                                                        x: index % 4 == 0 ? -10 : 10,
                                                        y: index % 2 == 0 ? -15 : -30
                                                    )
                                            }
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
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            
                            // MARK: - Evaluation Box
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Evaluation")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                
                                Text(generateEvaluation(for: exercise))
                                    .foregroundColor(.white.opacity(0.9))
                                    .font(.body)
                            }
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        } else {
                            Text("Select an exercise to see progress and evaluation.")
                                .italic()
                                .foregroundColor(.white.opacity(0.8))
                                .padding()
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Group exercises by muscle group
    var groupedExercises: [String: [String]] {
        let grouped = Dictionary(grouping: workoutData.entries) { entry in
            entry.muscleGroup.isEmpty ? "Other" : entry.muscleGroup
        }
        return grouped.mapValues { entries in
            Array(Set(entries.map { $0.exercise })).sorted()
        }
    }
    
    // MARK: - Filter entries for selected exercise
    func entries(for exercise: String) -> [WorkoutEntry] {
        workoutData.entries
            .filter { $0.exercise == exercise }
            .sorted { $0.date < $1.date }
    }
    
    // MARK: - Short date format
    func shortMonthDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    // MARK: - Detailed Evaluation Logic
    func generateEvaluation(for exercise: String) -> String {
        let entries = workoutData.entries
            .filter { $0.exercise.lowercased() == exercise.lowercased() }
            .sorted { $0.date < $1.date }
        
        guard let latest = entries.last else {
            return "Keep logging workouts to see trends and receive detailed evaluation."
        }
        
        let previousEntries = entries.dropLast()
        
        var feedback = "🏋️ \(exercise.capitalized) Progress Report:\n"
        
        if let prev = previousEntries.last {
            // Weight comparison
            if latest.weight > prev.weight {
                feedback += "• You lifted \(Int(latest.weight - prev.weight)) lbs more than last session.\n"
            } else if latest.weight < prev.weight {
                feedback += "• Slight drop in weight (\(Int(latest.weight)) vs \(Int(prev.weight))).\n"
            } else {
                feedback += "• Weight stayed the same (\(Int(latest.weight)) lbs).\n"
            }
            
            // Reps comparison
            if latest.reps > prev.reps {
                feedback += "• Reps increased (\(latest.reps) vs \(prev.reps)).\n"
            } else if latest.reps < prev.reps {
                feedback += "• Fewer reps (\(latest.reps) vs \(prev.reps)).\n"
            } else {
                feedback += "• Reps stayed the same (\(latest.reps)).\n"
            }
        } else {
            feedback += "🔥 First session logged — strong start!\n"
        }
        
        // Average of last 3 previous sessions
        let lastThree = Array(previousEntries.suffix(3))
        if !lastThree.isEmpty {
            let avgWeight = lastThree.map { $0.weight }.reduce(0, +) / Double(lastThree.count)
            let avgReps = Double(lastThree.map { $0.reps }.reduce(0, +)) / Double(lastThree.count)
            if latest.weight > avgWeight || Double(latest.reps) > avgReps {
                feedback += "📈 Trending above recent 3-session average — progress looks great!\n"
            } else {
                feedback += "⏳ Close to average performance. Stay consistent.\n"
            }
        }
        
        // MARK: - Trend Analysis (recent progression/regression)
        if entries.count >= 4 {
            let recent = entries.suffix(5)  // Last 5 workouts for trend
            
            // Extract weight, reps, and workload series
            let weights = recent.map { $0.weight }
            let repsList = recent.map { Double($0.reps) }
            let workloads = recent.map { $0.weight * Double($0.reps) }
            
            // Helper to compute slope of linear regression
            func slope(_ values: [Double]) -> Double {
                let n = Double(values.count)
                let x = (0..<values.count).map { Double($0) }
                
                let sumX = x.reduce(0, +)
                let sumY = values.reduce(0, +)
                let sumXY = zip(x, values).map(*).reduce(0, +)
                let sumX2 = x.map { $0 * $0 }.reduce(0, +)
                
                return (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)
            }
            
            let weightSlope = slope(weights)
            let repsSlope = slope(repsList)
            let workloadSlope = slope(workloads)
            
            feedback += "\n📈 Trend Analysis (Recent Workouts):\n"
            
            // Weight trend
            if weightSlope > 0.5 {
                feedback += "• Weight is trending up — strong recent progress.\n"
            } else if weightSlope < -0.5 {
                feedback += "• Weight is trending downward — possible fatigue or deload.\n"
            } else {
                feedback += "• Weight is steady with no major change.\n"
            }
            
            // Reps trend
            if repsSlope > 0.5 {
                feedback += "• Reps are trending up — endurance increasing.\n"
            } else if repsSlope < -0.5 {
                feedback += "• Reps are trending downward — monitor recovery.\n"
            } else {
                feedback += "• Reps are stable.\n"
            }
            
            // Workload trend (the best indicator)
            if workloadSlope > 5 {
                feedback += "• Overall workload is increasing — clear strength progression.\n"
            } else if workloadSlope < -5 {
                feedback += "• Workload is declining — could be intentional deload or overtraining.\n"
            } else {
                feedback += "• Workload is plateaued.\n"
            }
        }
    
        
        // Weekly consistency
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let recentCount = entries.filter { $0.date >= oneWeekAgo }.count
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
