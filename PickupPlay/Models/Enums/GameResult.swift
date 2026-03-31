import Foundation

enum GameResult: String, Codable, CaseIterable {
    case win = "WIN"
    case loss = "LOSS"
    case draw = "DRAW"
    case notRecorded = "NOT_RECORDED"
}
