import SwiftUI
import UIKit

struct ShareToSocialView: UIViewControllerRepresentable {
    let game: Game

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let shareService = SocialShareService()
        return shareService.shareGame(game)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
