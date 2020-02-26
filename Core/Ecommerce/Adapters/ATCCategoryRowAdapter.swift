//
//  ATCCategoryRowAdapter.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 11/11/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import UIKit

class ATCCategoryRowAdapter : ATCGenericCollectionRowAdapter {

    private let size: (CGRect) -> CGSize
    private let uiEcommerceConfig: ATCUIConfigurationProtocol
    init(uiEcommerceConfig: ATCUIConfigurationProtocol,
         size: @escaping ((CGRect) -> CGSize)) {
        self.size = size
        self.uiEcommerceConfig = uiEcommerceConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let category = object as? ATCStoryViewModel, let cell = cell as? CategoryCollectionViewCell else { return }
        cell.backgroundImageView.kf.setImage(with: URL(string: category.imageURLString))
        cell.backgroundImageView.contentMode = .scaleAspectFill

        cell.categoryTitleLabel.text = category.title
        cell.categoryTitleLabel.textColor = uiEcommerceConfig.categoryScreenTitleLabelColor
        cell.categoryTitleLabel.font = uiEcommerceConfig.categoryScreenTitleFont
        cell.categoryTitleLabel.alpha = uiEcommerceConfig.categoryScreenTitleLabelAlpha
        cell.categoryTitleLabel.backgroundColor = .clear

//        if let colorString = category.colorString {
//            cell.categoryBackgroundView.backgroundColor = UIColor(hexString: colorString, alpha: uiEcommerceConfig.categoryScreenColorAlpha)
//        }
    }

    func cellClass() -> UICollectionViewCell.Type {
        return CategoryCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        return self.size(containerBounds)
    }
}
