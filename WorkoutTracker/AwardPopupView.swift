//
//  AwardPopupView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 2/16/26.
//

import SwiftUI

struct AwardPopupView: View {
    let popup: AwardPopup
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(popup.icon)
                .font(.system(size: 70))
                .padding(.top, 10)

            Text(popup.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(popup.message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.85))
                .padding(.horizontal, 24)

            Button(action: onDismiss) {
                Text("Awesome! 🎉")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.green, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .padding(.vertical, 30)
        .background(AppColors.gradient.ignoresSafeArea())
        .presentationDetents([.fraction(0.4)])
        .presentationDragIndicator(.visible)
    }
}
