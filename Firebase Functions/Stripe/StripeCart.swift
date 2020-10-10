import Foundation

let StripeCart = _StripeCart()

final class _StripeCart {
    
    var items = [Item]()
    private let stripeCreditCardCut = 0.029
    private let flatFeeCents = 30
    var shippingFees = 0
    
    // variables for subtotal, processing fees and total
    var subtotal: Int {
        var amount = 0
        var pricePennies = 0
        
        for item in items {
            pricePennies = Int(item.price * 100)
            amount += pricePennies
        }
        
        return amount
    }
    
    var processingFees: Int {
        if subtotal == 0 {
            return 0
        }
        
        let sub = Double(subtotal)
        let fees = Int((sub * stripeCreditCardCut)) + flatFeeCents
        return fees
    }
    
    var total: Int {
        return  subtotal + processingFees + shippingFees
    }
    
    
    func addItem(_ item: Item) {
        items.append(item)
    }
    
    func clearCart() {
        items.removeAll()
    }
}
