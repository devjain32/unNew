//
//  ATCProductRowAdapter.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 10/15/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import UIKit

class ATCProductRowAdapter: ATCGenericCollectionRowAdapter {

    private let uiEcommerceConfig: ATCUIConfigurationProtocol
    
    init(uiEcommerceConfig: ATCUIConfigurationProtocol) {
        self.uiEcommerceConfig = uiEcommerceConfig
    }
    
    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let product = object as? Product, let cell = cell as? ProductCollectionViewCell else { return }
        cell.productImageView.kf.setImage(with: URL(string: product.imageURLString))
        cell.productImageView.contentMode = .scaleToFill
        cell.productImageView.backgroundColor = .white
        cell.containerView.backgroundColor = .clear

        cell.productTitleLabel.text = product.title
        cell.productTitleLabel.font = uiEcommerceConfig.productScreenTitleFont
        cell.productTitleLabel.textColor = uiEcommerceConfig.productScreenTextColor
        cell.priceLabel.text = "$" + product.price
        cell.priceLabel.font = uiEcommerceConfig.productScreenPriceFont
        cell.priceLabel.textColor = uiEcommerceConfig.productScreenTextColor

        cell.descriptionLabel.text = product.productDescription
        cell.descriptionLabel.font = uiEcommerceConfig.productScreenDescriptionFont
        cell.descriptionLabel.textColor = uiEcommerceConfig.productScreenDescriptionColor
        cell.containerView.backgroundColor = .clear
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ProductCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        return CGSize(width: containerBounds.width,
                      height: uiEcommerceConfig.productScreenCellHeight)
    }

}
