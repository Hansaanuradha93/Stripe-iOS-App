import UIKit
import Stripe
import Firebase

class CheckoutVC: UIViewController {
    
    // MARK: Properties
    public class var storyboardName: String {
        return "Main"
    }
        
    static func create() -> CheckoutVC {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle(for: self))
        let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: CheckoutVC.self)) as? CheckoutVC
        return viewController!
    }
    
    var paymentContext: STPPaymentContext!
    
    
    // MARK: IBOutlets
    @IBOutlet weak var paymentMethodButton: UIButton!
    @IBOutlet weak var shippingMethodButton: UIButton!
    
    
    // MARK: View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStripeConfig()
    }
    
    
    // MARK: IBActions
    @IBAction func paymentMethodClicked(_ sender: Any) {
        paymentContext.pushPaymentOptionsViewController()
    }
    
    
    @IBAction func shippingMethodClicked(_ sender: Any) {
        paymentContext.pushShippingViewController()
    }
    
    
    @IBAction func placeOrderClicked(_ sender: Any) {
        paymentContext.requestPayment()
    }
}


// MARK: - STPPaymentContextDelegate
extension CheckoutVC: STPPaymentContextDelegate {
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        
        // Update selected payment method
        if let paymentMethod = paymentContext.selectedPaymentOption {
            paymentMethodButton.setTitle(paymentMethod.label, for: .normal)
        } else {
            paymentMethodButton.setTitle("Payment Method", for: .normal)
        }
        
        // Update selected shipping method
        if let shippingMethod = paymentContext.selectedShippingMethod {
            shippingMethodButton.setTitle(shippingMethod.label, for: .normal)
            StripeCart.shippingFees = Int(Double(truncating: shippingMethod.amount) * 100)
            // TODO: Update subtotal, total, processing fees, shipping fees
        } else {
            shippingMethodButton.setTitle("Shipping Method", for: .normal)
        }
    }
    
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        
        let retryAction = UIAlertAction(title: "Retry", style: .default) { (action) in
            self.paymentContext.retryLoading()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(retryAction)
        
        self.present(alertController, animated: true)
    }
    
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        
        let idempotency = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let customerId = UserDefaults.standard.string(forKey: "stripeId") ?? ""
        let data: [String: Any] = [
            "customerId": customerId,
            "amount": paymentContext.paymentAmount,
            "idempotency": idempotency
        ]
        
        Functions.functions().httpsCallable("makeCharge").call(data) { (result, error) in
            if let error = error {
                print(error)
                completion(.error, error)
                return
            }
            
            // Clear the shopping cart since the payment is done
            StripeCart.clearCart()
            // tableView.reloadData()
            completion(.success, nil)
        }
    }
    
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        switch status {
        case .error:
            print("Payment Failed: \(String(describing: error?.localizedDescription))")
        case .success:
            print("Payment Successfull")
        case .userCancellation:
            print("User Cancellation")
            return
        }
    }
    
    
    func paymentContext(_ paymentContext: STPPaymentContext, didUpdateShippingAddress address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
        
        let upsGround = PKShippingMethod()
        upsGround.amount = 0
        upsGround.label = "UPS Ground"
        upsGround.detail = "Arrives in 3-5 days"
        upsGround.identifier = "ups_ground"
        
        let fedEx = PKShippingMethod()
        fedEx.amount = 6.99
        fedEx.label = "FedEx"
        fedEx.detail = "Arrives tommorow"
        fedEx.identifier = "fedex"
        
        if address.country == "US" {
            completion(.valid, nil, [upsGround, fedEx], upsGround)
        } else if address.country == "KR" {
            completion(.valid, nil, [upsGround], upsGround)
        } else {
            completion(.invalid, nil, nil, nil)
        }
        
        
    }
}


// MARK: - Methods
extension CheckoutVC {
    
    func setupStripeConfig() {
        let config = STPPaymentConfiguration.shared()
        config.requiredBillingAddressFields = .none
        config.requiredShippingAddressFields = [.postalAddress]
        
        
        let customerContext = STPCustomerContext(keyProvider: StripeAPT)
        paymentContext = STPPaymentContext(customerContext: customerContext, configuration: config, theme: .default())
        
        paymentContext.paymentAmount = 7099 // $10 Change this amount if you add or remove items from cart
        paymentContext.delegate = self
        paymentContext.hostViewController = self
    }
}
