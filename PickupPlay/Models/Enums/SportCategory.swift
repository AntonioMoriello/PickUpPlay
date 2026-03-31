import Foundation

enum SportCategory: String, Codable, CaseIterable, Identifiable {
    case teamSport = "TEAM_SPORT"
    case racquetNet = "RACQUET_NET"
    case individual = "INDIVIDUAL"
    case fitness = "FITNESS"
    case outdoor = "OUTDOOR"
    case custom = "CUSTOM"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .teamSport: return "Team Sports"
        case .racquetNet: return "Racquet & Net"
        case .individual: return "Individual"
        case .fitness: return "Fitness"
        case .outdoor: return "Outdoor"
        case .custom: return "Custom"
        }
    }

    var iconName: String {
        switch self {
        case .teamSport: return "person.3.fill"
        case .racquetNet: return "sportscourt.fill"
        case .individual: return "figure.run"
        case .fitness: return "dumbbell.fill"
        case .outdoor: return "mountain.2.fill"
        case .custom: return "plus.circle.fill"
        }
    }
}
