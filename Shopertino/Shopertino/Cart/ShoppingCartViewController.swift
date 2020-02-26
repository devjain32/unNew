//
//  ShoppingCartViewController.swift
//  Shopertino
//
//  Created by Florian Marcu on 5/7/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import Stripe
import UIKit

class ShoppingCartViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var cartItemsView: UIView!
    @IBOutlet var cartFooterView: UIView!
    @IBOutlet var buyButton: UIButton!
    @IBOutlet var totalTitleLabel: UILabel!
    @IBOutlet var totalLabel: UILabel!

    let cartManager: ATCShoppingCartManager
    let uiConfig: ATCUIGenericConfigurationProtocol
    var imageVC: ProductImagesViewController?
    var cartItemsVC: ShoppingCartItemsViewController?
    let placeOrderManager: ATCPlaceOrderManagerProtocol?

    var user: ATCUser? = nil

    var hasBeenLoaded: Bool = false

    init(cartManager: ATCShoppingCartManager,
         placeOrderManager: ATCPlaceOrderManagerProtocol?,
         uiConfig: ATCUIGenericConfigurationProtocol) {

        self.cartManager = cartManager
        self.placeOrderManager = placeOrderManager
        self.uiConfig = uiConfig

        super.init(nibName: "ShoppingCartViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.darkModeColor(hexString: "#fafafa")
        self.hasBeenLoaded = true
        cartItemsView.backgroundColor = UIColor.darkModeColor(hexString: "#fafafa")

        containerView.backgroundColor = uiConfig.mainThemeBackgroundColor
        cartItemsView.backgroundColor = uiConfig.mainThemeBackgroundColor
        cartFooterView.backgroundColor = uiConfig.mainThemeBackgroundColor
        
        cartItemsVC = ShoppingCartItemsViewController(cartManager: cartManager, uiConfig: uiConfig)
        cartItemsVC?.delegate = self
        guard let cartItemsVC = cartItemsVC else { return }
        cartItemsVC.view.frame = cartItemsView.bounds
        self.addChildViewControllerWithView(cartItemsVC, toView: cartItemsView)
        cartItemsVC.update()

        buyButton.configure(color: uiConfig.mainThemeBackgroundColor,
                            font: uiConfig.boldFont(size: 16),
                            cornerRadius: 5,
                            borderColor: nil,
                            backgroundColor: uiConfig.mainThemeForegroundColor.darkModed)
        buyButton.setTitle("CONTINUE".localizedInApp, for: .normal)
        buyButton.addTarget(self, action: #selector(didTapBuyButton), for: .touchUpInside)

        totalTitleLabel.text = "Total".localizedInApp
        totalTitleLabel.textColor = uiConfig.mainThemeForegroundColor.darkModed
        totalTitleLabel.font = uiConfig.regularFont(size: 16)

        totalLabel.text = "$" + cartManager.totalPrice().twoDecimalsString()
        totalLabel.textColor = uiConfig.mainThemeForegroundColor.darkModed
        totalLabel.font = uiConfig.boldFont(size: 18)

        cartFooterView.dropShadow()

        self.updateUI()

        self.title = "Shopping Bag".localizedInApp
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUI()
    }

    @objc private func didTapBuyButton() {
        let serverConfig = ShopertinoServerConfig()
        if (serverConfig.isStripeEnabled) {
            let stripeSettings = Settings(theme: ATCStripeThemeFactory().stripeTheme(for: uiConfig),
                                          additionalPaymentOptions: .all,
                                          requiredBillingAddressFields: .none,
                                          requiredShippingAddressFields: [.emailAddress, .name, .postalAddress], // [.phoneNumber]
                shippingType: .shipping)

            let stripeVC = CheckoutViewController(uiConfig: uiConfig,
                                                  price: Int(cartManager.totalPrice() * 100),
                                                  products: cartManager.distinctProducts(),
                                                  settings: stripeSettings)
            stripeVC.delegate = self
            self.navigationController?.pushViewController(stripeVC, animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func update() {
        cartItemsVC?.update()
        self.updateUI()
    }

    private func updateUI() {
        guard hasBeenLoaded else { return }

        let isEnabled = (cartManager.totalPrice() > 0)
        buyButton.isEnabled = isEnabled
        buyButton.alpha = (isEnabled ? 1 : 0.7)

        totalLabel.text = "$" + cartManager.totalPrice().twoDecimalsString()
    }
}

extension ShoppingCartViewController: ShoppingCartItemsViewControllerDelegate {
    func itemsViewControllerDidUpdateQuantities(_ vc: ShoppingCartItemsViewController) {
        self.updateUI()
    }
}

extension ShoppingCartViewController: CheckoutViewControllerDelegate {
    func checkoutViewController(_ vc: CheckoutViewController, didCompleteCheckout address: ATCAddress) {
        if let placeOrderManager = placeOrderManager {
            placeOrderManager.placeOrder(user: user, address: address, cart: cartManager.cart) {[weak self] (success) in
                guard let `self` = self else { return }
                self.cartManager.clearProducts()
                self.update()
            }
        } else {
            cartManager.clearProducts()
            self.update()
        }
    }
}
