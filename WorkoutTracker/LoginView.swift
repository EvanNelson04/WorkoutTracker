//
//  LoginView.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 10/13/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: UserAuth
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showRegister = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.95), Color.indigo]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 25) {
                // MARK: - Logo at the top
                VStack(spacing: 8) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .shadow(radius: 10)
                    
                    Text("WorkoutTracker")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.top, 60) // pushes logo down

                Spacer(minLength: 20)

                // MARK: - Login Fields
                VStack(spacing: 16) {
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .autocapitalization(.none)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 40)

                // MARK: - Error Message
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red.opacity(0.9))
                        .font(.caption)
                        .padding(.top, 4)
                }

                // MARK: - Login Button
                Button(action: login) {
                    Text("Login")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                }

                // MARK: - Register Option
                Button(action: { showRegister.toggle() }) {
                    Text("Create Account")
                        .foregroundColor(.white.opacity(0.9))
                        .underline()
                }
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
                .environmentObject(auth)
        }
    }

    private func login() {
        if auth.login(username: username, password: password) {
            errorMessage = nil
        } else {
            errorMessage = "Invalid username or password."
        }
    }
}


