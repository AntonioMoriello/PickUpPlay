import Foundation
import UIKit

class SocialShareService {
    func shareGame(_ game: Game) -> UIActivityViewController {
        let text = generateShareText(for: game)
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        return activityVC
    }

    func generateShareText(for game: Game) -> String {
        let sportName = Sport.allSports.first(where: { $0.id == game.sportId })?.name ?? game.sportId.capitalized
        let dateStr = game.dateTime.formatted(date: .abbreviated, time: .shortened)
        let spotsLeft = game.spotsLeft

        return """
        Join my \(sportName) pickup game!

        \(game.title)
        \(dateStr)
        \(spotsLeft) spots left

        Download PickupPlay to join!
        """
    }
}
