//
//  LoginView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 10/13/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: UserAuth
    @AppStorage("DisplayName") private var displayName: String = ""
    @AppStorage("HasLaunchedBefore") private var hasLaunchedBefore: Bool = false

    @State private var enteredName: String = ""

    var body: some View {
        ZStack {
            AppColors.gradient
                .ignoresSafeArea()

            VStack(spacing: 25) {
                Spacer()

                VStack(spacing: 12) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .shadow(radius: 10)

                    Text("WorkoutEvaluator")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(hasLaunchedBefore ? "Welcome Back" : "Welcome")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    if hasLaunchedBefore {
                        if displayName.isEmpty {
                            Text("Ready to get back to your workouts?")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                        } else {
                            Text("Welcome back, \(displayName)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                        }
                    } else {
                        Text("Enter a name to personalize your experience")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                }

                VStack(spacing: 16) {
                    if !hasLaunchedBefore {
                        TextField("Your name (optional)", text: $enteredName)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                    }

                    Button(action: continueIntoApp) {
                        Text("Continue")
                            .font(.headline)
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
                            .cornerRadius(12)
                    }

                    if !hasLaunchedBefore {
                        Button(action: skipForNow) {
                            Text("Skip for Now")
                                .foregroundColor(.white.opacity(0.9))
                                .underline()
                        }
                    } else {
                        Button(action: editName) {
                            Text("Edit Name")
                                .foregroundColor(.white.opacity(0.9))
                                .underline()
                        }
                    }
                }
                .padding(.horizontal, 40)

                Spacer()
            }
            .padding(.vertical, 40)
        }
        .onAppear {
            enteredName = displayName
        }
    }

    private func continueIntoApp() {
        let cleanName = enteredName.trimmingCharacters(in: .whitespacesAndNewlines)
        displayName = cleanName
        hasLaunchedBefore = true
        auth.continueAsGuest(with: cleanName)
    }

    private func skipForNow() {
        displayName = ""
        hasLaunchedBefore = true
        auth.continueAsGuest(with: "")
    }

    private func editName() {
        hasLaunchedBefore = false
        enteredName = displayName
    }
}



