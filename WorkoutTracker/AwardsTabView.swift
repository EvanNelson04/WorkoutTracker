//
//  AwardsTabView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 10/20/25.
//

//
//  AwardsTabView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 10/20/25.
//

import SwiftUI

struct AwardsTabView: View {
    var body: some View {
        NavigationStack {
            AwardsView()
        }
        .tabItem {
            Label("Awards", systemImage: "star.fill")
        }
    }
}

