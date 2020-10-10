import Foundation
import Stripe
import Firebase

let StripeAPT = _StripeAPI()

class _StripeAPI: NSObject, STPCustomerEphemeralKeyProvider {
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
      
        let customerId = UserDefaults.standard.string(forKey: "stripeId") ?? ""
        
        let data = [
            "stripe_version": apiVersion,
            "customer_id": customerId
        ]
        
        Functions.functions().httpsCallable("createEphemeralKey").call(data) { (result, error) in
            if let error = error {
                print(error)
                completion(nil, error)
                return
            }
            
            guard let key = result?.data as? [String: Any] else {
                completion(nil, nil)
                return
            }
            
            completion(key, nil)
        }
    }
}
