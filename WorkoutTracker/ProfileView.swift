//
//  ProfileView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 10/13/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var auth: UserAuth
    @EnvironmentObject var workoutData: WorkoutData

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("👋 Welcome, \(auth.username)")
                        .font(.title2)
                        .bold()
                    Text("Your workout summary")
                        .foregroundColor(.secondary)
                }
                .padding(.top, 30)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 16) {
                    let totalWorkouts = workoutData.entries.count
                    let uniqueExercises = Set(workoutData.entries.map { $0.exercise }).count

                    HStack {
                        Text("Total Workouts:")
                        Spacer()
                        Text("\(totalWorkouts)")
                            .bold()
                    }

                    HStack {
                        Text("Unique Exercises:")
                        Spacer()
                        Text("\(uniqueExercises)")
                            .bold()
                    }

                    Divider().padding(.vertical, 8)

                    // 💪 Personal Records (PRs)
                    let squatPR = workoutData.entries
                        .filter { $0.exercise.lowercased().contains("squat") }
                        .map { $0.weight }
                        .max() ?? 0.0

                    let benchPR = workoutData.entries
                        .filter { $0.exercise.lowercased().contains("bench") }
                        .map { $0.weight }
                        .max() ?? 0.0

                    let deadliftPR = workoutData.entries
                        .filter { $0.exercise.lowercased().contains("deadlift") }
                        .map { $0.weight }
                        .max() ?? 0.0

                    Text("Personal Records")
                        .font(.headline)
                        .padding(.top, 4)

                    HStack {
                        Text("🏋️‍♂️ Squat:")
                        Spacer()
                        Text("\(squatPR == 0 ? "—" : "\(Int(squatPR)) lbs")")
                            .bold()
                    }

                    HStack {
                        Text("💪 Bench:")
                        Spacer()
                        Text("\(benchPR == 0 ? "—" : "\(Int(benchPR)) lbs")")
                            .bold()
                    }

                    HStack {
                        Text("⚡️ Deadlift:")
                        Spacer()
                        Text("\(deadliftPR == 0 ? "—" : "\(Int(deadliftPR)) lbs")")
                            .bold()
                    }
                    let totalPR = deadliftPR + squatPR + benchPR

                    HStack {
                        Spacer()
                        Text("\(Int(totalPR)) lbs")
                    }
                }

                
                
                
                .padding(.horizontal)
                .font(.headline)
                
                Spacer()
                
                Button(action: {
                    auth.logout()
                }) {
                    Text("Log Out")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("Profile")
        }
    }
}



