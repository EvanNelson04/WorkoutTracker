//
//  AwardsDetailView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 10/21/25.
//

import SwiftUI

struct AwardDetailView: View {
    let award: Award
    
    var body: some View {
        VStack(spacing: 20) {
            Text(award.icon)
                .font(.system(size: 80))
            Text(award.title)
                .font(.largeTitle)
                .bold()
            
            Text(award.description)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            ProgressView(value: award.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .padding()
            
            if award.achieved {
                Text("🏆 You’ve earned this award!")
                    .foregroundColor(.green)
                    .font(.title2)
            } else {
                Text("Progress: \(Int(award.progress * 100))%")
                    .font(.title3)
            }
            
            if let date = award.dateEarned {
                Text("Earned on \(date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
    }
}
