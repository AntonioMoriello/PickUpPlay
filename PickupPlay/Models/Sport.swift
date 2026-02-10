//
//  Sport.swift
//  PickupPlay
//
import Foundation

struct Sport: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var iconName: String
    var category: SportCategory
    var defaultTeamSize: Int
    var minPlayers: Int
    var maxPlayers: Int
    var positions: [String]
    var trackableStats: [String]
    var requiresVenue: Bool
}

extension Sport {
    static let allSports: [Sport] = [
        Sport(id: "basketball", name: "Basketball", iconName: "basketball.fill", category: .teamSport,
              defaultTeamSize: 5, minPlayers: 6, maxPlayers: 10,
              positions: ["Point Guard", "Shooting Guard", "Small Forward", "Power Forward", "Center"],
              trackableStats: ["Points", "Rebounds", "Assists", "Steals", "Blocks"], requiresVenue: true),
        Sport(id: "soccer", name: "Soccer", iconName: "soccerball", category: .teamSport,
              defaultTeamSize: 11, minPlayers: 6, maxPlayers: 22,
              positions: ["Goalkeeper", "Defender", "Midfielder", "Forward"],
              trackableStats: ["Goals", "Assists", "Saves", "Shots on Target"], requiresVenue: true),
        Sport(id: "football", name: "Football", iconName: "football.fill", category: .teamSport,
              defaultTeamSize: 11, minPlayers: 6, maxPlayers: 22,
              positions: ["Quarterback", "Running Back", "Wide Receiver", "Linebacker", "Defensive Back"],
              trackableStats: ["Touchdowns", "Yards", "Completions", "Interceptions"], requiresVenue: true),
        Sport(id: "baseball", name: "Baseball", iconName: "baseball.fill", category: .teamSport,
              defaultTeamSize: 9, minPlayers: 10, maxPlayers: 18,
              positions: ["Pitcher", "Catcher", "First Base", "Second Base", "Shortstop", "Third Base", "Outfield"],
              trackableStats: ["Hits", "Runs", "RBIs", "Home Runs", "Strikeouts"], requiresVenue: true),
        Sport(id: "volleyball", name: "Volleyball", iconName: "volleyball.fill", category: .teamSport,
              defaultTeamSize: 6, minPlayers: 4, maxPlayers: 12,
              positions: ["Setter", "Outside Hitter", "Middle Blocker", "Libero", "Opposite Hitter"],
              trackableStats: ["Kills", "Assists", "Blocks", "Aces", "Digs"], requiresVenue: true),
        Sport(id: "hockey", name: "Hockey", iconName: "hockey.puck.fill", category: .teamSport,
              defaultTeamSize: 6, minPlayers: 6, maxPlayers: 12,
              positions: ["Center", "Left Wing", "Right Wing", "Defenseman", "Goalie"],
              trackableStats: ["Goals", "Assists", "Saves", "Shots"], requiresVenue: true),
        Sport(id: "rugby", name: "Rugby", iconName: "figure.rugby", category: .teamSport,
              defaultTeamSize: 15, minPlayers: 10, maxPlayers: 30,
              positions: ["Prop", "Hooker", "Lock", "Flanker", "Scrum-half", "Fly-half", "Centre", "Wing", "Fullback"],
              trackableStats: ["Tries", "Conversions", "Tackles", "Penalties"], requiresVenue: true),
        Sport(id: "lacrosse", name: "Lacrosse", iconName: "figure.lacrosse", category: .teamSport,
              defaultTeamSize: 10, minPlayers: 6, maxPlayers: 20,
              positions: ["Attack", "Midfield", "Defense", "Goalie"],
              trackableStats: ["Goals", "Assists", "Ground Balls", "Saves"], requiresVenue: true),
        Sport(id: "cricket", name: "Cricket", iconName: "cricket.ball.fill", category: .teamSport,
              defaultTeamSize: 11, minPlayers: 6, maxPlayers: 22,
              positions: ["Batsman", "Bowler", "All-Rounder", "Wicket-Keeper"],
              trackableStats: ["Runs", "Wickets", "Catches", "Overs"], requiresVenue: true),
        Sport(id: "ultimate_frisbee", name: "Ultimate Frisbee", iconName: "figure.disc.sports", category: .teamSport,
              defaultTeamSize: 7, minPlayers: 6, maxPlayers: 14,
              positions: ["Handler", "Cutter", "Hybrid"],
              trackableStats: ["Goals", "Assists", "Blocks", "Turnovers"], requiresVenue: false),

        Sport(id: "tennis", name: "Tennis", iconName: "tennis.racket", category: .racquetNet,
              defaultTeamSize: 1, minPlayers: 2, maxPlayers: 4,
              positions: ["Singles", "Doubles"],
              trackableStats: ["Aces", "Winners", "Unforced Errors", "Break Points"], requiresVenue: true),
        Sport(id: "badminton", name: "Badminton", iconName: "figure.badminton", category: .racquetNet,
              defaultTeamSize: 1, minPlayers: 2, maxPlayers: 4,
              positions: ["Singles", "Doubles"],
              trackableStats: ["Points", "Smashes", "Drops", "Clears"], requiresVenue: true),
        Sport(id: "pickleball", name: "Pickleball", iconName: "figure.pickleball", category: .racquetNet,
              defaultTeamSize: 2, minPlayers: 2, maxPlayers: 4,
              positions: ["Singles", "Doubles"],
              trackableStats: ["Points", "Aces", "Dinks", "Volleys"], requiresVenue: true),
        Sport(id: "table_tennis", name: "Table Tennis", iconName: "figure.table.tennis", category: .racquetNet,
              defaultTeamSize: 1, minPlayers: 2, maxPlayers: 4,
              positions: ["Singles", "Doubles"],
              trackableStats: ["Points", "Aces", "Winners"], requiresVenue: true),

        Sport(id: "boxing", name: "Boxing", iconName: "figure.boxing", category: .individual,
              defaultTeamSize: 1, minPlayers: 2, maxPlayers: 2,
              positions: ["Fighter"],
              trackableStats: ["Rounds", "Knockdowns", "Points"], requiresVenue: true),
        Sport(id: "wrestling", name: "Wrestling", iconName: "figure.wrestling", category: .individual,
              defaultTeamSize: 1, minPlayers: 2, maxPlayers: 2,
              positions: ["Wrestler"],
              trackableStats: ["Points", "Takedowns", "Pins"], requiresVenue: true),
        Sport(id: "swimming", name: "Swimming", iconName: "figure.pool.swim", category: .individual,
              defaultTeamSize: 1, minPlayers: 1, maxPlayers: 20,
              positions: ["Freestyle", "Backstroke", "Breaststroke", "Butterfly"],
              trackableStats: ["Laps", "Time", "Distance"], requiresVenue: true),
        Sport(id: "golf", name: "Golf", iconName: "figure.golf", category: .individual,
              defaultTeamSize: 1, minPlayers: 1, maxPlayers: 4,
              positions: ["Player"],
              trackableStats: ["Score", "Birdies", "Pars", "Bogeys", "Eagles"], requiresVenue: true),

        Sport(id: "crossfit", name: "CrossFit", iconName: "dumbbell.fill", category: .fitness,
              defaultTeamSize: 1, minPlayers: 2, maxPlayers: 30,
              positions: ["Athlete"],
              trackableStats: ["Reps", "Weight", "Time", "Rounds"], requiresVenue: true),
        Sport(id: "yoga", name: "Yoga", iconName: "figure.yoga", category: .fitness,
              defaultTeamSize: 1, minPlayers: 1, maxPlayers: 30,
              positions: ["Practitioner"],
              trackableStats: ["Duration", "Sessions"], requiresVenue: false),

        Sport(id: "hiking", name: "Hiking", iconName: "figure.hiking", category: .outdoor,
              defaultTeamSize: 1, minPlayers: 1, maxPlayers: 20,
              positions: ["Hiker"],
              trackableStats: ["Distance", "Elevation", "Duration"], requiresVenue: false),
        Sport(id: "cycling", name: "Cycling", iconName: "bicycle", category: .outdoor,
              defaultTeamSize: 1, minPlayers: 1, maxPlayers: 20,
              positions: ["Cyclist"],
              trackableStats: ["Distance", "Speed", "Duration", "Elevation"], requiresVenue: false),
        Sport(id: "skateboarding", name: "Skateboarding", iconName: "figure.skateboarding", category: .outdoor,
              defaultTeamSize: 1, minPlayers: 1, maxPlayers: 10,
              positions: ["Skater"],
              trackableStats: ["Tricks", "Duration"], requiresVenue: false),
    ]
}
