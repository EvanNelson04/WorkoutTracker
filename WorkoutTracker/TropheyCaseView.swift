//
//  TropheyCaseView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 2/12/26.
//

import SwiftUI

struct TrophyCaseView: View {
    @ObservedObject var awardManager: AwardManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 16)], spacing: 16) {
                    ForEach(awardManager.awards.filter { $0.achieved }) { award in
                        VStack(spacing: 8) {
                            Text(award.icon)
                                .font(.system(size: 50))
                            Text(award.title)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                    }
                }
                .padding()
            }
            .navigationTitle("Trophy Case")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Preview
struct TrophyCaseView_Previews: PreviewProvider {
    static var previews: some View {
        TrophyCaseView(awardManager: AwardManager())
    }
}
