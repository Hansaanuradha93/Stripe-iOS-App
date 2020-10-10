import UIKit
import Firebase
import Stripe

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Properties
    lazy var functions = Functions.functions()
    
    
    // MARK: AppDelegate Methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Stripe.setDefaultPublishableKey("pk_test_Zx9wyJW7pcgyCyKX1WcGTHC500SSAmfxMG")
        fetchUserDetails()
        return true
    }
    
    
    func fetchUserDetails() {
        let uid = Auth.auth().currentUser?.uid ?? ""
        
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
            if let error = error {
                print(error)
                return
            }
            
            if let data = snapshot?.data(), let stripeId = data["stripeId"] {
                UserDefaults.standard.set(stripeId, forKey: "stripeId")
            }
        }
        
    }
}

