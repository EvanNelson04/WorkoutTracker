//
//  RegisterView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 10/14/25.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var auth: UserAuth
    @Environment(\.dismiss) var dismiss

    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            AppColors.gradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    // Back Button
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    Text("Create Account")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)

                    // MARK: - Input Fields
                    VStack(spacing: 15) {
                        TextField("Username", text: $username)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .textContentType(.username)

                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .textContentType(.newPassword)

                        SecureField("Confirm Password", text: $confirmPassword)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .textContentType(.newPassword)
                    }
                    .padding(.horizontal, 30)

                    // Error Message
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red.opacity(0.9))
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }

                    // MARK: - Register Button
                    Button(action: register) {
                        Text("Register")
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
                            .padding(.horizontal, 30)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
        }
    }

    private func register() {
        let cleanUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanConfirmPassword = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanUsername.isEmpty, !cleanPassword.isEmpty, !cleanConfirmPassword.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        guard cleanPassword == cleanConfirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        guard cleanPassword.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }

        if auth.register(username: cleanUsername, password: cleanPassword) {
            errorMessage = nil
            dismiss()
        } else {
            errorMessage = "That username already exists."
        }
    }
}


