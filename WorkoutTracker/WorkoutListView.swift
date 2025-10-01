//
//  WorkoutListView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 9/23/25.
//

import SwiftUI

struct WorkoutListView: View {
    @EnvironmentObject var workoutData: WorkoutData
    
    var body: some View {
        NavigationView {
            List {
                ForEach(workoutData.entries) { entry in
                    VStack(alignment: .leading) {
                        Text("\(entry.exercise) - \(Int(entry.weight)) lbs x \(entry.reps)")
                            .font(.headline)
                        if let hr = entry.heartRate {
                            Text("Heart Rate: \(Int(hr)) bpm")
                                .font(.subheadline)
                        }
                        Text("Date: \(entry.date.formatted(.dateTime.month().day().year()))")
                            .font(.caption)
                    }
                }
                .onDelete(perform: workoutData.delete)
            }
            .navigationTitle("Workout History")
            .toolbar {
                EditButton()
            }
        }
    }
}

