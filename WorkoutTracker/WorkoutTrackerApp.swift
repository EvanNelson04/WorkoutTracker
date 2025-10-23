//
//  WorkoutTrackerApp.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 9/23/25.
//

import SwiftUI

@main
struct WorkoutTrackerApp: App {
    @StateObject var workoutData = WorkoutData()
    @StateObject var auth = UserAuth()
    @StateObject var awardManager = AwardManager()
    
    var body: some Scene {
        WindowGroup {
            if auth.isLoggedIn {
                TabView {
                    
                    // MARK: - History Tab
                    NavigationStack {
                        WorkoutListView()
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    profileButton()
                                }
                            }
                    }
                    .tabItem { Label("History", systemImage: "list.bullet") }
                    
                    // MARK: - Charts Tab
                    NavigationStack {
                        WorkoutChartView()
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    profileButton()
                                }
                            }
                    }
                    .tabItem { Label("Charts", systemImage: "chart.line.uptrend.xyaxis") }
                    
                    // MARK: - Evaluation Tab
                    NavigationStack {
                        WorkoutEvaluationView()
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    profileButton()
                                }
                            }
                    }
                    .tabItem { Label("Evaluation", systemImage: "doc.text.magnifyingglass") }
                    
                    // MARK: - Awards Tab
                    NavigationStack {
                        AwardsView()
                            .onAppear {
                                // Evaluate awards automatically when viewing the tab
                                awardManager.evaluateAwards(for: workoutData.entries)
                            }
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    profileButton()
                                }
                            }
                    }
                    .tabItem { Label("Awards", systemImage: "star.fill") }
                    
                    // MARK: - Add Tab
                    AddWorkoutView()
                        .tabItem { Label("Add", systemImage: "plus.circle") }
                    
                }
                // 🌍 Make environment objects available across all tabs
                .environmentObject(workoutData)
                .environmentObject(auth)
                .environmentObject(awardManager) // 👈 Add this line
            } else {
                LoginView()
                    .environmentObject(auth)
            }
        }
    }
    
    // MARK: - Profile Button
    @ViewBuilder
    private func profileButton() -> some View {
        NavigationLink(destination: ProfileView()) {
            Image(systemName: "person.crop.circle")
                .font(.title2)
        }
    }
} 





