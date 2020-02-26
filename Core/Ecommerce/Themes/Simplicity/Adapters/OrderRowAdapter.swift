//
//  OrderRowAdapter.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 5/20/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import UIKit

class OrderRowAdapter: ATCGenericCollectionRowAdapter {

    weak var parentVC: UIViewController?
    weak var cartVC: ATCShoppingCartViewController?

    var VCs = [String: ATCGenericCollectionViewController]()
    let uiConfig: ATCUIGenericConfigurationProtocol
    let uiEcommerceConfig: ATCUIConfigurationProtocol
    init(parentVC: UIViewController,
         uiConfig: ATCUIGenericConfigurationProtocol,
         cartVC: ATCShoppingCartViewController?,
         uiEcommerceConfig: ATCUIConfigurationProtocol) {
        self.parentVC = parentVC
        self.uiConfig = uiConfig
        self.cartVC = cartVC
        self.uiEcommerceConfig = uiEcommerceConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let order = object as? ATCOrder, let cell = cell as? OrderCollectionViewCell else { return }
        cell.delegate = self
        cell.configure(viewModel: order)

        cell.orderImageView.kf.setImage(with: order.headerImageURL())
        cell.orderImageView.contentMode = .scaleAspectFill
        cell.orderImageView.clipsToBounds = true

        if let totalPrice = order.totalPrice() {
            cell.totalPriceLabel.text =  "Total: $".localizedEcommerce + totalPrice.twoDecimalsString()
        } else {
            cell.totalPriceLabel.text = ""
        }
        cell.totalPriceLabel.font = uiEcommerceConfig.ordersScreenFooterPriceFont

        cell.placeOrderButton.setTitle("REORDER".localizedEcommerce, for: .normal)
        cell.placeOrderButton.backgroundColor = uiEcommerceConfig.productDetailsAddToCartButtonBgColor
        cell.placeOrderButton.setTitleColor(.white, for: .normal)
        cell.placeOrderButton.layer.cornerRadius = 3
        cell.placeOrderButton.snp.makeConstraints { (maker) in
            maker.height.equalTo(uiEcommerceConfig.ordersScreenButtonHeight)
        }
        cell.placeOrderButton.titleLabel?.font = uiEcommerceConfig.ordersScreenButtonFont
        cell.containerView.backgroundColor = uiConfig.mainThemeBackgroundColor
        if let containerView = cell.collectionContainerView, let items = order.shoppingCart?.distinctProductItems() {
            containerView.subviews.forEach({ (view) in
                view.removeFromSuperview()
            })
            if VCs[order.id] == nil {
                let dataSource = ATCGenericLocalDataSource(items: items)
                let config = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                             pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
                                                                             collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
                                                                             collectionViewLayout: ATCCollectionViewFlowLayout(),
                                                                             collectionPagingEnabled: false,
                                                                             hideScrollIndicators: false,
                                                                             hidesNavigationBar: false,
                                                                             headerNibName: nil,
                                                                             scrollEnabled: true,
                                                                             uiConfig: uiConfig,
                                                                             emptyViewModel: nil)
                let vc = ATCGenericCollectionViewController(configuration: config)
                vc.genericDataSource = dataSource
                vc.use(adapter: ShoppingCartItemRowAdapter(uiConfig: uiConfig, uiEcommerceConfig: uiEcommerceConfig), for: "ATCShoppingCartItem")
                VCs[order.id] = vc
            }
            let vc = VCs[order.id]!
            vc.view.frame = containerView.bounds
            containerView.addSubview(vc.view)
            cell.setNeedsLayout()
        }
    }

    func cellClass() -> UICollectionViewCell.Type {
        return OrderCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        var h: CGFloat = 95 + 50 + 20 + 30 + 10
        if let order = object as? ATCOrder {
            h += CGFloat(order.totalItems()) * (uiEcommerceConfig.ordersScreenCartItemCellHeight + 5)
        }
        return CGSize(width: containerBounds.width,
                      height: h)
    }
}

extension OrderRowAdapter : OrderCollectionViewCellDelegate {
    func cell(_ cell: OrderCollectionViewCell, didTapReorderOrder order: ATCOrder) {
        if let cart = order.shoppingCart {
            cartVC?.cartManager.ingest(cart, vendorID: order.vendorID)
            if let cartVC = cartVC {
                self.parentVC?.navigationController?.pushViewController(cartVC, animated: true)
            }
        }
    }
}
