import UIKit
import Firebase

class ViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: Properties
    public class var storyboardName: String {
        return "Main"
    }
        
    static func create() -> ViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle(for: self))
        let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: ViewController.self)) as? ViewController
        return viewController!
    }
    
    lazy var functions = Functions.functions()

    // MARK: View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: IBActions
    @IBAction func loginTapped(_ sender: UIButton) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error)
                return
            }
            print("Login successfully")
        }
    }
    
    @IBAction func signupTapped(_ sender: UIButton) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error)
                return
            }
            
            let uid = Auth.auth().currentUser?.uid ?? ""

            let documentData = [
                "uid": uid,
                "email": email,
                "firstName": firstName,
                "lastName": lastName
            ]

            Firestore.firestore().collection("users").document(uid).setData(documentData) { error in
                if let error = error {
                    print(error)
                    return
                }
                print("Signup details saved")
            }
        }
    }
}


