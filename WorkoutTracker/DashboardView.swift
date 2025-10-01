//
//  DashboardView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 9/30/25.
//

import SwiftUI
import Charts

struct DashboardView: View {
    // Dummy workout data for now
    struct WorkoutEntry: Identifiable {
        let id = UUID()
        let exercise: String
        let weight: Double
        let reps: Int
        let date: Date
    }

    let entries: [WorkoutEntry] = [
        WorkoutEntry(exercise: "Bench Press", weight: 185, reps: 5, date: .now),
        WorkoutEntry(exercise: "Squat", weight: 225, reps: 8, date: .now),
        WorkoutEntry(exercise: "Deadlift", weight: 315, reps: 3, date: .now)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: - Logo
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(radius: 8)
                        .padding(.top)

                    // MARK: - Chart Section
                    VStack(alignment: .leading) {
                        Text("Progress Chart")
                            .font(.headline)
                            .padding(.bottom, 8)

                        Chart(entries) { entry in
                            BarMark(
                                x: .value("Exercise", entry.exercise),
                                y: .value("Weight", entry.weight)
                            )
                        }
                        .frame(height: 200)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .shadow(radius: 4)

                    // MARK: - Workout List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Workouts")
                            .font(.headline)

                        ForEach(entries) { entry in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(entry.exercise)
                                    .font(.subheadline)
                                    .bold()
                                Text("\(Int(entry.weight)) lbs x \(entry.reps)")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
