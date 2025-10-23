//
//  ContentView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 9/23/25.
//

import SwiftUI

struct ContentView: View {
    // Example dummy workout data
    struct WorkoutEntry: Identifiable {
        let id = UUID()
        let exercise: String
        let weight: Double
        let reps: Int
    }
    
    let entries: [WorkoutEntry] = [
        WorkoutEntry(exercise: "Bench Press", weight: 185, reps: 5),
        WorkoutEntry(exercise: "Squat", weight: 225, reps: 8),
        WorkoutEntry(exercise: "Deadlift", weight: 315, reps: 3)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: - App Logo
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(radius: 8)
                        .padding(.top)
                    
                    // MARK: - Welcome Text
                    Text("Welcome to WorkoutUploader!")
                        .font(.title)
                        .bold()
                        .padding(.bottom, 10)
                    
                    // MARK: - Chart Placeholder
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 300)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    
                    // MARK: - Recent Workouts
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Workouts")
                            .font(.headline)
                            .padding(.horizontal)
                        
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
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.bottom)
            }
            .navigationTitle("Dashboard")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        AwardsTabView()
    }
}


