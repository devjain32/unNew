//
//  ATCOrderViewControllerFactory.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 5/20/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import UIKit

class ATCOrderViewController: ATCGenericCollectionViewController {
    var user: ATCUser? {
        didSet {
            if let user = user {
                self.genericDataSource = dsProvider.ordersDataSource(for: user)
            }
        }
    }
    let dsProvider: ATCEcommerceDataSourceProvider
    private let uiEcommerceConfig: ATCUIConfigurationProtocol
    
    init(uiConfig: ATCUIGenericConfigurationProtocol,
         cartVC: ATCShoppingCartViewController,
         dsProvider: ATCEcommerceDataSourceProvider,
         uiEcommerceConfig: ATCUIConfigurationProtocol) {
        self.dsProvider = dsProvider
        self.uiEcommerceConfig = uiEcommerceConfig
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
        super.init(configuration: config)
        self.use(adapter: OrderRowAdapter(parentVC: self, uiConfig: uiConfig, cartVC: cartVC, uiEcommerceConfig: uiEcommerceConfig), for: "ATCOrder")
        self.title = "Orders".localizedEcommerce
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.genericDataSource?.loadFirst()
    }
}
