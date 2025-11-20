//
//  ExerciseDetailView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 11/20/25.
//


import SwiftUI
import AVKit

struct ExerciseDetailView: View {
    let ex: Exercise

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                if let url = Bundle.main.url(forResource: ex.videoName, withExtension: "mp4") {
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(height: 250)
                        .cornerRadius(12)
                }

                Text(ex.name)
                    .font(.title.bold())

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(ex.tips, id: \.self) { tip in
                        HStack(alignment: .top) {
                            Text("•")
                            Text(tip)
                        }
                    }
                }
                .padding(.leading, 4)
            }
            .padding()
        }
        .navigationTitle(ex.name)
    }
}
