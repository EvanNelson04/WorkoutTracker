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

    @State private var showDeleteAccountAlert = false
    @State private var showDeleteSuccessAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.gradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                            .padding(.top, 30)

                        statsCard
                            .padding(.horizontal)

                        actionButtons
                            .padding(.horizontal)
                            .padding(.bottom, 40)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Erase All Data?", isPresented: $showDeleteAccountAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Erase", role: .destructive) {
                    performAccountDeletion()
                }
            } message: {
                Text("This will permanently delete all saved workouts and reset your app data on this device.")
            }
            .alert("Data Erased", isPresented: $showDeleteSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your stored data have been permanently erased.")
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("👋 Welcome, \(auth.username)")
                .font(.title2)
                .bold()
                .foregroundColor(.white)

            Text("Your workout summary")
                .foregroundColor(.white.opacity(0.8))
        }
    }

    private var statsCard: some View {
        let totalWorkouts = workoutData.entries.count
        let uniqueExercises = Set(workoutData.entries.map { $0.exercise }).count

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

        let totalPR = deadliftPR + squatPR + benchPR

        return VStack(alignment: .leading, spacing: 16) {
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

            Divider()
                .background(Color.white.opacity(0.7))

            Text("Personal Records")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 4)

            HStack {
                Text("🏋️‍♂️ Squat:")
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                Text(squatPR == 0 ? "—" : "\(Int(squatPR)) lbs")
                    .bold()
                    .foregroundColor(.white)
            }

            HStack {
                Text("💪 Bench:")
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                Text(benchPR == 0 ? "—" : "\(Int(benchPR)) lbs")
                    .bold()
                    .foregroundColor(.white)
            }

            HStack {
                Text("⚡️ Deadlift:")
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                Text(deadliftPR == 0 ? "—" : "\(Int(deadliftPR)) lbs")
                    .bold()
                    .foregroundColor(.white)
            }

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
    }

    private var actionButtons: some View {
        VStack(spacing: 14) {
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
            }

            Button(action: {
                showDeleteAccountAlert = true
            }) {
                Text("Erase All Data")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
    }

    private func performAccountDeletion() {
        workoutData.clearCurrentUserWorkouts()
        auth.deleteAccount()
        showDeleteSuccessAlert = true
    }
}




