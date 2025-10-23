//
//  AwardsView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 10/20/25.
//

//
//  AwardsView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 10/20/25.
//

import SwiftUI

struct AwardsView: View {
    @EnvironmentObject var awardManager: AwardManager
    @EnvironmentObject var workoutData: WorkoutData
    @State private var selectedAward: Award? = nil
    
    var body: some View {
        List(awardManager.awards) { award in
            Button {
                selectedAward = award
            } label: {
                HStack {
                    Text(award.icon)
                        .font(.largeTitle)
                    VStack(alignment: .leading) {
                        Text(award.title)
                            .font(.headline)
                        
                        ProgressView(value: award.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        
                        if let desc = award.progressDescription {
                            Text(desc)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if award.achieved {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("Awards")
            .sheet(item: $selectedAward) { award in
                AwardDetailView(award: award)
            }
            .onAppear {
                awardManager.evaluateAwards(for: workoutData.entries)
            }
        }
    }
    
    
}
