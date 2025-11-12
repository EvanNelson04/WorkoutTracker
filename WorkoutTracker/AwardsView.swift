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
        NavigationView {
            ZStack {
                // Gradient background
                AppColors.gradient
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(awardManager.awards) { award in
                            Button {
                                selectedAward = award
                            } label: {
                                HStack(alignment: .center, spacing: 12) {
                                    Text(award.icon)
                                        .font(.system(size: 40))
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(award.title)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        ProgressView(value: award.progress)
                                            .progressViewStyle(LinearProgressViewStyle(tint: .green))
                                        
                                        if let desc = award.progressDescription {
                                            Text(desc)
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    if award.achieved {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(.yellow)
                                            .font(.title2)
                                    }
                                }
                                .padding()
                                .background(
                                    AppColors.gradient
                                        .mask(RoundedRectangle(cornerRadius: 12))
                                )
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Awards")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedAward) { award in
                AwardDetailView(award: award)
            }
            .onAppear {
                awardManager.evaluateAwards(for: workoutData.entries)
            }
        }
    }
}

