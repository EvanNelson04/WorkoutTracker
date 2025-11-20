import SwiftUI
import AVKit

struct ExerciseListView: View {
    let muscle: String

    var body: some View {
        List(exercises[muscle] ?? []) { exercise in
            NavigationLink(destination: ExerciseDetailView(ex: exercise)) {
                Text(exercise.name)
            }
        }
        .navigationTitle(muscle)
    }
}
