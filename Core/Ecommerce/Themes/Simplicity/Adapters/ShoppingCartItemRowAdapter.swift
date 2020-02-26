//
//  ShoppingCartItemRowAdapter.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 5/20/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import UIKit

class ShoppingCartItemRowAdapter: ATCGenericCollectionRowAdapter {
    let uiConfig: ATCUIGenericConfigurationProtocol
    private let uiEcommerceConfig: ATCUIConfigurationProtocol
    
    init(uiConfig: ATCUIGenericConfigurationProtocol,
         uiEcommerceConfig: ATCUIConfigurationProtocol) {
        self.uiConfig = uiConfig
        self.uiEcommerceConfig = uiEcommerceConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let item = object as? ATCShoppingCartItem, let cell = cell as? CartItemCollectionViewCell else { return }
        cell.configure(item: item, uiEcommerceConfig: uiEcommerceConfig)
        cell.cartPriceLabel.textColor = uiConfig.mainTextColor
        cell.cartItemTitleLabel.textColor = uiConfig.mainTextColor
        cell.countLabel.textColor = uiConfig.mainThemeForegroundColor
    }

    func cellClass() -> UICollectionViewCell.Type {
        return CartItemCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        return CGSize(width: containerBounds.width,
                      height: uiEcommerceConfig.ordersScreenCartItemCellHeight)
    }
}
