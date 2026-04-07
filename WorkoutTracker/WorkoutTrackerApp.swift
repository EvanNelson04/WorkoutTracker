import SwiftUI
import Charts

@main
struct WorkoutTrackerApp: App {
    @StateObject private var auth: UserAuth
    @StateObject private var workoutData: WorkoutData
    @StateObject private var awardManager = AwardManager()

    init() {
        let authInstance = UserAuth()
        _auth = StateObject(wrappedValue: authInstance)
        _workoutData = StateObject(wrappedValue: WorkoutData(auth: authInstance))

        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().tintColor = .white

        UITabBar.appearance().backgroundColor = UIColor.systemGray6.withAlphaComponent(0.95)
        UITabBar.appearance().barTintColor = UIColor.systemGray6
    }

    var body: some Scene {
        WindowGroup {
            if auth.isLoggedIn {
                TabView {
                    NavigationStack {
                        WorkoutListView()
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    profileButton()
                                }
                            }
                    }
                    .tabItem {
                        Label("History", systemImage: "list.bullet")
                    }

                    NavigationStack {
                        WorkoutProgressView()
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    profileButton()
                                }
                            }
                    }
                    .tabItem {
                        Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                    }

                    NavigationStack {
                        AwardsView()
                            .onAppear {
                                awardManager.evaluateAwards(for: workoutData.entries)
                            }
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    profileButton()
                                }
                            }
                    }
                    .tabItem {
                        Label("Awards", systemImage: "star.fill")
                    }

                    NavigationStack {
                        SuggestionsView()
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    profileButton()
                                }
                            }
                    }
                    .tabItem {
                        Label("Suggestions", systemImage: "figure.strengthtraining.traditional")
                    }

                    AddWorkoutView()
                        .environmentObject(workoutData)
                        .environmentObject(auth)
                        .environmentObject(awardManager)
                        .tabItem {
                            Label("Add", systemImage: "plus.circle")
                        }
                }
                .environmentObject(workoutData)
                .environmentObject(auth)
                .environmentObject(awardManager)
                .tint(.white)
            } else {
                LoginView()
                    .environmentObject(auth)
                    .environmentObject(workoutData)
                    .environmentObject(awardManager)
            }
        }
    }

    @ViewBuilder
    private func profileButton() -> some View {
        NavigationLink(destination: ProfileView()) {
            Image(systemName: "person.crop.circle")
                .font(.title2)
                .foregroundColor(.white)
        }
    }
}




