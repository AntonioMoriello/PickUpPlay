import Foundation

enum GameStatus: String, Codable, CaseIterable, Identifiable {
    case draft = "DRAFT"
    case upcoming = "UPCOMING"
    case inProgress = "IN_PROGRESS"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .upcoming: return "Upcoming"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }

    var iconName: String {
        switch self {
        case .draft: return "pencil.circle"
        case .upcoming: return "clock.fill"
        case .inProgress: return "play.circle.fill"
        case .completed: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }
}
