//
//  ATCAdminOrdersViewController.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 11/26/19.
//  Copyright © 2019 iOS App Templates. All rights reserved.
//

import UIKit

class ATCAdminOrdersViewController: ATCGenericCollectionViewController {
    static func adminOrdersVC(uiConfig: ATCUIGenericConfigurationProtocol,
                              dsProvider: ATCEcommerceDataSourceProvider,
                              viewer: ATCUser,
                              uiEcommerceConfig: ATCUIConfigurationProtocol) -> ATCAdminOrdersViewController {
        let emptyViewModel = CPKEmptyViewModel(image: nil,
                                               title: "No Orders".localizedEcommerce,
                                               description: "No customer ordered any products yet. All orders will be displayed here.".localizedEcommerce,
                                               callToAction: nil)
        let config = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: true,
                                                                     pullToRefreshTintColor: .white,
                                                                     collectionViewBackgroundColor: UIColor.darkModeColor(hexString: "#f4f6f9"),
                                                                     collectionViewLayout: ATCLiquidCollectionViewLayout(cellPadding: 5),
                                                                     collectionPagingEnabled: false,
                                                                     hideScrollIndicators: true,
                                                                     hidesNavigationBar: false,
                                                                     headerNibName: nil,
                                                                     scrollEnabled: true,
                                                                     uiConfig: uiConfig,
                                                                     emptyViewModel: emptyViewModel)
        let vc = ATCAdminOrdersViewController(configuration: config)
        vc.selectionBlock = {(navController, object, indexPath) in
            if let order = object as? ATCOrder {
                let orderVC = ATCAdminSingleOrderViewController(order: order)
                vc.navigationController?.pushViewController(orderVC, animated: true)
            }
        }
        vc.genericDataSource = dsProvider.adminOrdersDataSource(for: viewer)
        vc.use(adapter: ATCAdminOrderRowAdapter(parentVC: vc,
                                                uiConfig: uiConfig,
                                                dsProvider: dsProvider,
                                                uiEcommerceConfig: uiEcommerceConfig),
               for: "ATCOrder")
        vc.title = "Admin Orders".localizedEcommerce
        return vc
    }
}
