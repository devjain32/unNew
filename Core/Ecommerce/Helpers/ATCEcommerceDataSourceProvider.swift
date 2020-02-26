//
//  ATCEcommerceDataSourceProvider.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 11/12/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import UIKit

protocol ATCEcommerceDataSourceProvider: class {
    var categoriesDataSource: ATCGenericCollectionViewControllerDataSource {get}
    func onboardingCoordinator(uiConfig: ATCUIGenericConfigurationProtocol) -> ATCOnboardingCoordinatorProtocol
    func walkthroughVC(uiConfig: ATCUIGenericConfigurationProtocol) -> ATCWalkthroughViewController
    var homeProductsDataSource: ATCGenericCollectionViewControllerDataSource {get}
    func productsDataSource(for category: Category) -> ATCGenericCollectionViewControllerDataSource
    func ordersDataSource(for user: ATCUser) -> ATCGenericCollectionViewControllerDataSource
    func adminOrdersDataSource(for viewer: ATCUser) -> ATCGenericCollectionViewControllerDataSource
    var searchDataSource: ATCGenericSearchViewControllerDataSource {get}
    var placeOrderManager: ATCPlaceOrderManagerProtocol? {get}
    var addAuthoredProduct: ATCAddAuthoredProductManagerProtocol? {get}
    func authoredProducts(for owner: String?) -> ATCGenericCollectionViewControllerDataSource
}
