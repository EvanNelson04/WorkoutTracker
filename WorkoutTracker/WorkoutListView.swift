//
//  WorkoutList.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 9/23/25.
//

import SwiftUI

// Shared gradient matching your login page
struct AppColors {
    static let gradient = LinearGradient(
        colors: [
            Color(red: 0.2, green: 0.6, blue: 0.9),
            Color(red: 0.1, green: 0.3, blue: 0.7)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct WorkoutListView: View {
    @EnvironmentObject var workoutData: WorkoutData
    
    var body: some View {
        NavigationView {
            ZStack {
                // Full screen gradient
                AppColors.gradient
                    .ignoresSafeArea()
                
                List {
                    ForEach(workoutData.entries) { entry in
                        WorkoutCard(entry: entry)
                            .listRowBackground(Color.clear) // make row background transparent
                            .listRowSeparator(.hidden)      // hide default separator
                    }
                    .onDelete(perform: workoutData.delete)
                }
                .listStyle(PlainListStyle()) // remove extra padding & default style
            }
            .navigationTitle("Workout History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


// MARK: - Gradient Card
struct WorkoutCard: View {
    var entry: WorkoutEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.exercise)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(entry.weight)) lbs x \(entry.reps)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            HStack(spacing: 12) {
                if let hr = entry.heartRate {
                    Label("\(Int(hr)) bpm", systemImage: "heart.fill")
                        .font(.caption)
                        .foregroundColor(hr > 140 ? .red : .green)
                }
                
                Label(entry.date.formatted(.dateTime.month().day().year()), systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding()
        .background(
            AppColors.gradient
                .mask(RoundedRectangle(cornerRadius: 12))
        )
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}






