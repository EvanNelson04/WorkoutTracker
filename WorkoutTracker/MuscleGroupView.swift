//
//  MuscleGroupView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 11/20/25.
//

import SwiftUI

struct MuscleGroupView: View {
    let region: BodyRegion
    
    var body: some View {
        List(region.muscleGroups, id: \.self) { group in
            NavigationLink(group) {
                ExerciseListView(muscle: group)
            }
        }
        .navigationTitle(region.rawValue.capitalized)
    }
}
