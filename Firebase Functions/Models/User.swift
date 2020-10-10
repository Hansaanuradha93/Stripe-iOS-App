import Foundation

struct User {
    
    var uid, email, firstName, lastName, stripeId: String?
    
    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String
        self.email = dictionary["email"] as? String
        self.firstName = dictionary["firstName"] as? String
        self.lastName = dictionary["lastName"] as? String
        self.stripeId = dictionary["stripeId"] as? String
    }
}
