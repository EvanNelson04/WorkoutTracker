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
    @State private var selectedMuscleGroup: String? = nil
    @State private var selectedExercise: String? = nil
    @State private var showEvaluationGuide = false
    
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
                        
                        // MARK: - Muscle Group Picker
                        Picker("Select Muscle Group", selection: $selectedMuscleGroup) {
                            Text("Select Muscle Group").tag(String?.none)
                            ForEach(groupedExercises.keys.sorted(), id: \.self) { group in
                                Text(group).tag(String?.some(group))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .accentColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .onChange(of: selectedMuscleGroup) { _, _ in
                            selectedExercise = nil
                        }
                        
                        // MARK: - Exercise Picker
                        Picker("Select Exercise", selection: $selectedExercise) {
                            Text("Select Exercise").tag(String?.none)
                            
                            if let selectedMuscleGroup,
                               let exercises = groupedExercises[selectedMuscleGroup] {
                                
                                if exercises.isEmpty {
                                    Text("No exercises logged yet").tag(String?.none)
                                } else {
                                    ForEach(exercises, id: \.self) { exercise in
                                        Text(exercise).tag(String?.some(exercise))
                                    }
                                }
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .accentColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .disabled(selectedMuscleGroup == nil || (groupedExercises[selectedMuscleGroup ?? ""]?.isEmpty ?? true))
                        .opacity(selectedMuscleGroup == nil ? 0.6 : 1.0)
                        
                        // MARK: - Chart + Evaluation
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
                                HStack(spacing: 8) {
                                    Text("Evaluation")
                                        .font(.title2.bold())
                                        .foregroundColor(.white)
                                    
                                    Button {
                                        showEvaluationGuide = true
                                    } label: {
                                        Image(systemName: "info.circle")
                                            .font(.title3)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Spacer()
                                }
                                
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
                            Text("Select a muscle group and exercise to see progress and evaluation.")
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
            .sheet(isPresented: $showEvaluationGuide) {
                EvaluationGuideView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - Group exercises by muscle group
    var groupedExercises: [String: [String]] {
        let allMuscleGroups = ["Chest", "Back", "Legs", "Arms", "Shoulders", "Core"]
        
        var result: [String: [String]] = [:]
        
        for group in allMuscleGroups {
            let exercises = workoutData.entries
                .filter { $0.muscleGroup.caseInsensitiveCompare(group) == .orderedSame }
                .map { $0.exercise.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            result[group] = Array(Set(exercises)).sorted()
        }
        
        return result
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
    func evaluate(latest: WorkoutEntry, history: [WorkoutEntry]) -> String {
        guard history.count > 1 else {
            return """
            🚀 First \(latest.exercise.capitalized) session logged!
            
            🧠 Key Insight:
            More sessions will unlock trend, fatigue, and next-step recommendations.
            
            ➡️ Next Step:
            Repeat this exercise again soon so the app can start detecting progress patterns.
            
            📌 Data-driven training beats guesswork — stay consistent!
            """
        }
        
        let sortedHistory = history.sorted { $0.date > $1.date }
        let prev = sortedHistory[1]
        let recent = Array(sortedHistory.prefix(5))
        let older = Array(sortedHistory.dropFirst().prefix(5))
        
        let latestVolume = latest.weight * Double(latest.reps)
        let prevVolume = prev.weight * Double(prev.reps)
        
        let recentVolumes = recent.map { $0.weight * Double($0.reps) }
        let olderVolumes = older.map { $0.weight * Double($0.reps) }
        
        let recentAvgVolume = max(recentVolumes.reduce(0, +) / Double(max(recentVolumes.count, 1)), 1)
        let olderAvgVolume = max(olderVolumes.reduce(0, +) / Double(max(olderVolumes.count, 1)), 1)
        let momentum = (recentAvgVolume - olderAvgVolume) / olderAvgVolume
        
        let volumeChange = prevVolume > 0 ? (latestVolume - prevVolume) / prevVolume : 0
        let weightChange = prev.weight > 0 ? (latest.weight - prev.weight) / prev.weight : 0
        let repsChange = prev.reps > 0 ? Double(latest.reps - prev.reps) / Double(prev.reps) : 0
        
        // MARK: - Opening line
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
            opening = "🧠 \(latest.exercise.capitalized) performance steady — good time to focus on clean execution."
        }
        
        // MARK: - Weekly consistency
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let weeklyEntries = sortedHistory.filter { $0.date >= oneWeekAgo }
        let weeklyCount = weeklyEntries.count
        
        // MARK: - Prediction
        var predictedWeight: Double? = nil
        var predictedReps: Double? = nil
        
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
                let denominator = (n * sumX2 - sumX * sumX)
                guard denominator != 0 else { return 0 }
                return (n * sumXY - sumX * sumY) / denominator
            }
            
            let weightSlope = slope(yWeight)
            let repsSlope = slope(yReps)
            
            var nextWeight = latest.weight + weightSlope
            var nextReps = Double(latest.reps) + repsSlope
            
            nextWeight = round(nextWeight / 5) * 5
            nextReps = round(nextReps)
            
            predictedWeight = max(nextWeight, 5)
            predictedReps = max(nextReps, 1)
        }
        
        // MARK: - Better fatigue logic
        let performanceDropped = latestVolume < prevVolume && latest.weight <= prev.weight && latest.reps <= prev.reps
        let volumeSpike = weeklyCount >= 3 && latestVolume > recentAvgVolume * 1.15
        
        var fatigueScore = 20
        
        if weeklyCount >= 4 { fatigueScore += 25 }
        else if weeklyCount >= 3 { fatigueScore += 15 }
        else if weeklyCount <= 1 { fatigueScore -= 5 }
        
        if volumeSpike { fatigueScore += 20 }
        if momentum < -0.08 { fatigueScore += 20 }
        if performanceDropped { fatigueScore += 15 }
        if momentum > 0.08 && !performanceDropped { fatigueScore -= 10 }
        
        fatigueScore = min(max(fatigueScore, 0), 100)
        
        let fatigueLabel: String
        let fatigueEmoji: String
        switch fatigueScore {
        case 0..<35:
            fatigueLabel = "LOW"
            fatigueEmoji = "✅"
        case 35..<65:
            fatigueLabel = "MODERATE"
            fatigueEmoji = "⚠️"
        default:
            fatigueLabel = "HIGH"
            fatigueEmoji = "🛌"
        }
        
        // MARK: - Workout score
        var score = 50
        
        if latest.weight > prev.weight { score += 10 }
        if latest.reps > prev.reps { score += 10 }
        if latest.weight > prev.weight && latest.reps >= prev.reps { score += 8 }
        if latestVolume > prevVolume { score += 10 }
        if momentum > 0.15 { score += 10 }
        else if momentum > 0.05 { score += 6 }
        else if momentum < -0.10 { score -= 10 }
        
        if weeklyCount >= 2 && weeklyCount <= 4 { score += 7 }
        else if weeklyCount >= 5 { score -= 4 }
        
        if fatigueScore >= 65 { score -= 8 }
        else if fatigueScore < 35 { score += 5 }
        
        let bestVolume = sortedHistory.map { $0.weight * Double($0.reps) }.max() ?? latestVolume
        let isPR = latestVolume >= bestVolume
        if isPR { score += 10 }
        
        score = min(max(score, 1), 100)
        
        // MARK: - Momentum display
        let momentumPercent = Int(momentum * 100)
        let momentumLine: String
        if momentum > 0.15 {
            momentumLine = "🚀 Trending UP (\(momentumPercent)%)"
        } else if momentum > 0.05 {
            momentumLine = "📈 Trending UP (\(momentumPercent)%)"
        } else if momentum < -0.10 {
            momentumLine = "📉 Trending DOWN (\(momentumPercent)%)"
        } else {
            momentumLine = "⏸ Trending STABLE (\(momentumPercent)%)"
        }
        
        // MARK: - Key insight
        let keyInsight: String
        if latest.weight > prev.weight && latest.reps >= prev.reps {
            keyInsight = "You are improving both strength and endurance at the same time — this is your strongest sign of productive overload."
        } else if latest.weight > prev.weight {
            keyInsight = "Your strength is improving faster than endurance right now — keep reps clean while the weight climbs."
        } else if latest.reps > prev.reps {
            keyInsight = "Your endurance is improving even without more weight — that usually sets up a future weight increase."
        } else if fatigueScore >= 65 {
            keyInsight = "Your recent workload looks high relative to your output — recovery may be limiting performance."
        } else if momentum < -0.10 {
            keyInsight = "Your trend has softened over recent sessions — a small reset or repeat session could help rebuild consistency."
        } else {
            keyInsight = "Your output is stable — this is a good phase to reinforce technique before pushing harder."
        }
        
        // MARK: - Next action
        let nextAction: String
        if fatigueScore >= 65 {
            nextAction = "Take a lighter session or repeat the same weight with perfect form before increasing intensity."
        } else if latest.weight > prev.weight && latest.reps >= prev.reps {
            if let predictedWeight, let predictedReps {
                nextAction = "Increase to \(Int(predictedWeight)) lbs and aim for \(Int(predictedReps)) reps next session."
            } else {
                nextAction = "Increase weight by 5 lbs next session and aim to match your current reps."
            }
        } else if latest.reps > prev.reps {
            nextAction = "Keep the same weight next session and try to add 1–2 more reps before increasing load."
        } else if latestVolume < prevVolume {
            nextAction = "Repeat this weight and aim to beat today’s reps before progressing."
        } else {
            nextAction = "Maintain this load and focus on cleaner reps or a small volume increase next time."
        }
        
        // MARK: - Build feedback
        var feedback = "\(opening)\n\n"
        feedback += "🏅 Workout Score: \(score)/100\n"
        feedback += "\(momentumLine)\n\n"
        
        feedback += "🧠 Key Insight:\n"
        feedback += "\(keyInsight)\n\n"
        
        feedback += "➡️ Next Step:\n"
        feedback += "\(nextAction)\n\n"
        
        feedback += "📋 Breakdown:\n"
        
        if latest.weight > prev.weight && latest.reps >= prev.reps {
            feedback += "• Strength and endurance both improved.\n"
        } else if latest.weight > prev.weight {
            feedback += "• Weight increased since last session.\n"
        } else if latest.reps > prev.reps {
            feedback += "• Reps increased since last session.\n"
        } else {
            feedback += "• Output was steady compared to the last session.\n"
        }
        
        if latestVolume > prevVolume {
            feedback += "• Training volume increased by \(Int(latestVolume - prevVolume)).\n"
        } else if latestVolume < prevVolume {
            feedback += "• Training volume decreased by \(Int(prevVolume - latestVolume)).\n"
        } else {
            feedback += "• Training volume matched the previous session.\n"
        }
        
        if isPR {
            feedback += "• 🏆 New personal volume record achieved.\n"
        }
        
        if weeklyCount >= 4 {
            feedback += "• Frequency is high (\(weeklyCount)x this week) — watch recovery closely.\n"
        } else if weeklyCount >= 2 {
            feedback += "• Weekly frequency looks strong for progress and recovery.\n"
        } else {
            feedback += "• Adding another session this week could improve consistency.\n"
        }
        
        feedback += "• \(fatigueEmoji) Fatigue: \(fatigueLabel) (\(fatigueScore)/100).\n"
        
        if let predictedWeight, let predictedReps {
            feedback += "• 🎯 Predicted next session: \(Int(predictedWeight)) lbs × \(Int(predictedReps)) reps.\n"
        }
        
        let volumePercent = Int(volumeChange * 100)
        let weightPercent = Int(weightChange * 100)
        let repsPercent = Int(repsChange * 100)
        
        feedback += "• Volume change vs last session: \(volumePercent)%.\n"
        feedback += "• Weight change vs last session: \(weightPercent)%.\n"
        feedback += "• Reps change vs last session: \(repsPercent)%.\n"
        
        feedback += "\n📌 Data-driven training beats guesswork — stay consistent!"
        
        return feedback.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct EvaluationGuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.gradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        guideSection(
                            title: "Workout Score",
                            description: "A 1–100 score based on recent progress, training volume, consistency, and recovery signals. Higher scores usually mean your recent sessions are moving in a strong direction."
                        )
                        
                        guideSection(
                            title: "Trending",
                            description: "Shows whether your recent performance is improving, staying steady, or declining compared to earlier sessions. This is based on how your recent average training volume compares to older sessions."
                        )
                        
                        guideSection(
                            title: "Fatigue",
                            description: "Estimates whether your recent training load may be affecting performance and recovery. High frequency, volume spikes, and performance drop-offs can raise fatigue."
                        )
                        
                        guideSection(
                            title: "Key Insight",
                            description: "Highlights the most meaningful takeaway from your recent workout data, such as improving strength, better endurance, or signs that recovery may be needed."
                        )
                        
                        guideSection(
                            title: "Next Step",
                            description: "Suggests what to do in your next session based on your recent trend. This could mean increasing weight, adding reps, repeating a session, or backing off to recover."
                        )
                        
                        guideSection(
                            title: "Predicted Next Session",
                            description: "Estimates what weight and reps you may be ready for next if your current trend continues. This is meant to guide progression, not replace your judgment."
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Evaluation Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    @ViewBuilder
    private func guideSection(title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline.bold())
                .foregroundColor(.white)
            
            Text(description)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.25))
        .cornerRadius(12)
    }
}

