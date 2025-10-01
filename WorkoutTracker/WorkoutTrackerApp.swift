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
    
    var body: some Scene {
        WindowGroup {
            TabView {
                WorkoutListView()
                    .tabItem {
                        Label("History", systemImage: "list.bullet")
                    }
                
                WorkoutChartView()
                    .tabItem {
                        Label("Charts", systemImage: "chart.line.uptrend.xyaxis")
                    }
                
                WorkoutEvaluationView()
                        .tabItem {
                            Label("Evaluation", systemImage: "doc.text.magnifyingglass")
                        }
                AddWorkoutView()
                    .tabItem {
                        Label("Add", systemImage: "plus.circle")
                    }
            }
            .environmentObject(workoutData)
        }
    }
}


