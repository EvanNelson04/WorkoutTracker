//
//  WorkoutList.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 9/23/25.
//

import SwiftUI

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
                AppColors.gradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Text("Workout History")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    List {
                        let sortedIndices = workoutData.entries.indices.sorted {
                            workoutData.entries[$0].date > workoutData.entries[$1].date
                        }
                        
                        ForEach(sortedIndices, id: \.self) { sortedIndex in
                            let entry = workoutData.entries[sortedIndex]
                            WorkoutCard(entry: entry)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                        .onDelete { offsets in
                            let indicesToDelete = offsets.map { sortedIndices[$0] }
                            workoutData.delete(at: IndexSet(indicesToDelete))
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

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







