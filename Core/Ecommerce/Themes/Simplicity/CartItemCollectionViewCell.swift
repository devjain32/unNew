//
//  CartItemCollectionViewCell.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 11/8/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import Kingfisher
import UIKit

class CartItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet var cartPriceLabel: UILabel!
    @IBOutlet var cartItemTitleLabel: UILabel!
    @IBOutlet var countLabel: UILabel!

    func configure(item: ATCShoppingCartItem, uiEcommerceConfig: ATCUIConfigurationProtocol) {
        cartPriceLabel.text = "$" + item.product.cartPrice.twoDecimalsString()
        cartItemTitleLabel.text = item.product.cartTitle
        countLabel.text = "  " + String(item.quantity) + "  "

        cartPriceLabel.font = uiEcommerceConfig.cartScreenPriceFont

        cartItemTitleLabel.font = uiEcommerceConfig.cartScreenTitleFont

        countLabel.font = uiEcommerceConfig.cartScreenCountFont
        countLabel.layer.borderColor = uiEcommerceConfig.cartScreenCountBorderColor.cgColor
        countLabel.layer.borderWidth = 1.0
    }
}
