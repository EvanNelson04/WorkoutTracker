//
//  WorkoutTrackerApp.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 9/23/25.
//

import SwiftUI
import Charts

@main
struct WorkoutTrackerApp: App {
    @StateObject var workoutData = WorkoutData()
    @StateObject var auth = UserAuth()
    @StateObject var awardManager = AwardManager()
    
    init() {
        // Make all navigation elements (titles, back arrows, icons) white
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().tintColor = .white
        
        // Make the tab bar always have a visible background
        UITabBar.appearance().backgroundColor = UIColor.systemGray6.withAlphaComponent(0.95)
        UITabBar.appearance().barTintColor = UIColor.systemGray6
    }
    
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
                    .tabItem {
                        Label("History", systemImage: "list.bullet")
                    }
                    
                    // MARK: - Progress Tab (new combined chart + evaluation)
                    NavigationStack {
                        WorkoutProgressView()
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    profileButton()
                                }
                            }
                    }
                    .tabItem {
                        Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    
                    // MARK: - Awards Tab
                    NavigationStack {
                        AwardsView()
                            .onAppear {
                                awardManager.evaluateAwards(for: workoutData.entries)
                            }
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    profileButton()
                                }
                            }
                    }
                    .tabItem {
                        Label("Awards", systemImage: "star.fill")
                    }
                    
                    // Suggestions Tab
                    NavigationStack {
                        SuggestionsView()
                    }
                    .tabItem {
                        Label("Suggestions", systemImage: "figure.strengthtraining.traditional")
                    }
                    
                    // Add Tab
                    AddWorkoutView()
                        .tabItem {
                            Label("Add", systemImage: "plus.circle")
                        }
                }
                // 🌍 Share data and auth across tabs
                .environmentObject(workoutData)
                .environmentObject(auth)
                .environmentObject(awardManager)
                .tint(.white) // Make selected tab icon white for consistency
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
                .foregroundColor(.white) // ✅ White icon on gradient
        }
    }
}





