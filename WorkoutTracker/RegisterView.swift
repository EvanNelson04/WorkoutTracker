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
            // Unified app gradient background
            AppColors.gradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    // 🔹 Back Button
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

                    // Title
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
                            .autocapitalization(.none)

                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                            .foregroundColor(.white)

                        SecureField("Confirm Password", text: $confirmPassword)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 30)

                    // Error Message
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red.opacity(0.9))
                            .font(.caption)
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
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        auth.register(username: username, password: password)
        dismiss()
    }
}


