import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class FirebaseManager {
    static let shared = FirebaseManager()

    let auth: Auth
    let firestore: Firestore
    let storage: Storage

    private init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        self.storage = Storage.storage()
    }
}
