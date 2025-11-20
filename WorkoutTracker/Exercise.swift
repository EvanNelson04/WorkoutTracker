import Foundation

struct Exercise: Identifiable {
    let id = UUID()
    let name: String
    let videoName: String
    let tips: [String]
}
