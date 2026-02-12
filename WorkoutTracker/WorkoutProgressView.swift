//
//  WorkoutProgressView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 9/23/25.
//  Updated for dynamic evaluation and trend analysis
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
                                        RuleMark(
                                            x: .value("Index", index),
                                            yStart: .value("Start", 0),
                                            yEnd: .value("Weight", entry.weight)
                                        )
                                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                                        .foregroundStyle(.white.opacity(0.6))
                                        
                                        LineMark(
                                            x: .value("Index", index),
                                            y: .value("Weight", entry.weight)
                                        )
                                        .interpolationMethod(.linear)
                                        .foregroundStyle(.white)
                                        .lineStyle(StrokeStyle(lineWidth: 2))
                                        
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
                                
                                if let latest = latestEntry(for: exercise) {
                                    Text(evaluate(latest: latest, history: history(for: exercise)))
                                        .foregroundColor(.white.opacity(0.9))
                                        .font(.body)
                                } else {
                                    Text("Keep logging workouts to see trends and receive detailed evaluation.")
                                        .foregroundColor(.white.opacity(0.9))
                                        .font(.body)
                                }
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
    
    func history(for exercise: String) -> [WorkoutEntry] {
        workoutData.entries
            .filter { $0.exercise.lowercased() == exercise.lowercased() }
            .sorted { $0.date > $1.date }
    }
    
    func latestEntry(for exercise: String) -> WorkoutEntry? {
        history(for: exercise).first
    }
    
    func shortMonthDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    // MARK: - Advanced Dynamic Evaluation
    // MARK: - Advanced Dynamic Evaluation with Predictions & Fatigue
    func evaluate(latest: WorkoutEntry, history: [WorkoutEntry]) -> String {
        guard history.count > 1 else {
            return "🚀 First \(latest.exercise.capitalized) session logged — future sessions will generate detailed insights!"
        }

        let prev = history[1]
        let recent = Array(history.prefix(5))
        let older = Array(history.dropFirst().prefix(5))

        let latestVolume = latest.weight * Double(latest.reps)
        let prevVolume = prev.weight * Double(prev.reps)

        let recentAvgVolume = recent.map { $0.weight * Double($0.reps) }.reduce(0, +) / Double(recent.count)
        let olderAvgVolume = max(older.map { $0.weight * Double($0.reps) }.reduce(0, +) / Double(max(older.count, 1)), 1)
        let momentum = (recentAvgVolume - olderAvgVolume) / olderAvgVolume

        // --- Dynamic Opening Line ---
        let opening: String
        if latest.weight > prev.weight && latest.reps >= prev.reps {
            opening = "🔥 Crushing it on \(latest.exercise)! Strength and endurance are up!"
        } else if latest.weight > prev.weight {
            opening = "💪 \(latest.exercise.capitalized) strength increased — nice work!"
        } else if latest.reps > prev.reps {
            opening = "🔁 \(latest.exercise.capitalized) endurance improved with more reps!"
        } else if momentum > 0.05 {
            opening = "📈 Steady gains on \(latest.exercise)! Keep building momentum."
        } else if momentum < -0.10 {
            opening = "⚠️ \(latest.exercise.capitalized) performance dipped slightly — check recovery."
        } else {
            opening = "🧠 \(latest.exercise.capitalized) performance steady — perfect for technique focus."
        }

        var feedback = "\(opening)\n\n"

        // --- Strength & Endurance ---
        if latest.weight > prev.weight && latest.reps >= prev.reps {
            feedback += "• Strength AND endurance up — textbook progressive overload.\n"
        } else if latest.weight > prev.weight {
            feedback += "• Weight increased. Neural strength likely improving.\n"
        } else if latest.reps > prev.reps {
            feedback += "• More reps than last session — endurance is improving.\n"
        } else {
            feedback += "• Output held steady — maintain technique and recovery.\n"
        }

        // --- Volume ---
        if latestVolume > prevVolume {
            feedback += "• Training volume increased (+\(Int(latestVolume - prevVolume))) — strong workload tolerance.\n"
        } else if latestVolume < prevVolume {
            feedback += "• Volume slightly decreased — could signal fatigue or planned deload.\n"
        }

        // --- Momentum ---
        if momentum > 0.15 {
            feedback += "• 🚀 Momentum: HIGH — performance accelerating rapidly.\n"
        } else if momentum > 0.05 {
            feedback += "• 📈 Momentum: POSITIVE — steady sustainable progress.\n"
        } else if momentum < -0.10 {
            feedback += "• ⚠️ Momentum: DECLINING — recovery may be needed.\n"
        } else {
            feedback += "• ⏸ Momentum: STABLE — consistent output.\n"
        }

        // --- Personal Record ---
        let bestVolume = history.map { $0.weight * Double($0.reps) }.max() ?? latestVolume
        if latestVolume >= bestVolume {
            feedback += "• 🏆 New personal volume record achieved!\n"
        }

        // --- Weekly Consistency ---
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let weeklyEntries = history.filter { $0.date >= oneWeekAgo }
        let weeklyVolume = weeklyEntries.map { $0.weight * Double($0.reps) }.reduce(0, +)
        let weeklyCount = weeklyEntries.count

        if weeklyCount >= 4 {
            feedback += "• 🛌 High frequency (\(weeklyCount)x this week) — consider prioritizing recovery.\n"
        } else if weeklyCount >= 2 {
            feedback += "• ✅ Weekly frequency optimal for growth and recovery.\n"
        } else {
            feedback += "• 💡 Add another session this week to boost adaptation.\n"
        }

        // --- 1️⃣ Predictive Next Session ---
        if recent.count >= 2 {
            let x = (0..<recent.count).map { Double($0) }
            let yWeight = recent.map { $0.weight }
            let yReps = recent.map { Double($0.reps) }

            func slope(_ values: [Double]) -> Double {
                let n = Double(values.count)
                let sumX = x.reduce(0, +)
                let sumY = values.reduce(0, +)
                let sumXY = zip(x, values).map(*).reduce(0, +)
                let sumX2 = x.map { $0 * $0 }.reduce(0, +)
                return (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)
            }

            let weightSlope = slope(yWeight)
            let repsSlope = slope(yReps)

            // Predicted next session
            var predictedWeight = latest.weight + weightSlope
            var predictedReps = Double(latest.reps) + repsSlope

            // Round to realistic increments
            predictedWeight = round(predictedWeight / 5) * 5 // nearest 5 lbs
            predictedReps = round(predictedReps)               // nearest whole rep

            // Ensure minimums
            predictedWeight = max(predictedWeight, 5)  // minimum 5 lbs
            predictedReps = max(predictedReps, 1)      // minimum 1 rep

            feedback += String(format: "• 🎯 Predicted next session: %.0f lbs × %.0f reps\n", predictedWeight, predictedReps)
        }


        // --- 2️⃣ Fatigue & Recovery Index ---
        // Simple formula: weekly volume normalized by recent momentum
        let fatigueScore = min(max(Int(weeklyVolume / (recentAvgVolume) * 10), 0), 100)
        let fatigueEmoji: String
        switch fatigueScore {
        case 0..<40: fatigueEmoji = "✅"
        case 40..<70: fatigueEmoji = "⚠️"
        default: fatigueEmoji = "🛌"
        }

        feedback += "• \(fatigueEmoji) Fatigue Index: \(fatigueScore)/100 — adjust intensity/recovery accordingly.\n"

        feedback += "\n📌 Data-driven training beats guesswork — stay consistent!"
        return feedback.trimmingCharacters(in: .whitespacesAndNewlines)
    }

}


