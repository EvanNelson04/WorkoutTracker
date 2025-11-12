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
            ZStack {
                // Gradient background
                AppColors.gradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Welcome Section
                        VStack(spacing: 8) {
                            Text("👋 Welcome, \(auth.username)")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            Text("Your workout summary")
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 30)
                        
                        // Stats Card
                        VStack(alignment: .leading, spacing: 16) {
                            let totalWorkouts = workoutData.entries.count
                            let uniqueExercises = Set(workoutData.entries.map { $0.exercise }).count

                            HStack {
                                Text("Total Workouts:")
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(totalWorkouts)")
                                    .bold()
                                    .foregroundColor(.white)
                            }

                            HStack {
                                Text("Unique Exercises:")
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(uniqueExercises)")
                                    .bold()
                                    .foregroundColor(.white)
                            }

                            Divider().background(Color.white.opacity(0.7))
                            
                            // Personal Records
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
                                .foregroundColor(.white)
                                .padding(.top, 4)

                            HStack {
                                Text("🏋️‍♂️ Squat:")
                                    .foregroundColor(.white.opacity(0.9))
                                Spacer()
                                Text("\(squatPR == 0 ? "—" : "\(Int(squatPR)) lbs")")
                                    .bold()
                                    .foregroundColor(.white)
                            }

                            HStack {
                                Text("💪 Bench:")
                                    .foregroundColor(.white.opacity(0.9))
                                Spacer()
                                Text("\(benchPR == 0 ? "—" : "\(Int(benchPR)) lbs")")
                                    .bold()
                                    .foregroundColor(.white)
                            }

                            HStack {
                                Text("⚡️ Deadlift:")
                                    .foregroundColor(.white.opacity(0.9))
                                Spacer()
                                Text("\(deadliftPR == 0 ? "—" : "\(Int(deadliftPR)) lbs")")
                                    .bold()
                                    .foregroundColor(.white)
                            }

                            let totalPR = deadliftPR + squatPR + benchPR
                            HStack {
                                Spacer()
                                Text("Total PR: \(Int(totalPR)) lbs")
                                    .bold()
                                    .foregroundColor(.white)
                            }

                        }
                        .padding()
                        .background(
                            AppColors.gradient
                                .mask(RoundedRectangle(cornerRadius: 16))
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                        
                        // Logout Button
                        Button(action: {
                            auth.logout()
                        }) {
                            Text("Log Out")
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
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}




