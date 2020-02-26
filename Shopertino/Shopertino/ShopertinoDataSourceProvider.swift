//
//  ShopertinoDataSourceProvider.swift
//  Shopertino
//
//  Created by Florian Marcu on 4/27/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ShopertinoDataSourceProvider: ATCEcommerceDataSourceProvider {
    
    let serverConfig: ShopertinoServerConfig
    init(serverConfig: ShopertinoServerConfig) {
        self.serverConfig = serverConfig
    }

    let walkthroughs = [
        ATCWalkthroughModel(title: "Shopertino".localizedInApp, subtitle: "Welcome to Shopertino! Buy our products easily and get access to app only exclusives.".localizedInApp, icon: "shopertino-logo-tinted"),
        ATCWalkthroughModel(title: "Shopping Bag".localizedInApp, subtitle: "Add products to your shopping cart, and check them out later.".localizedInApp, icon: "shopping-bag"),
        ATCWalkthroughModel(title: "Quick Search".localizedInApp, subtitle: "Quickly find the products you like the most.".localizedInApp, icon: "binoculars-icon"),
        ATCWalkthroughModel(title: "Wishlist".localizedInApp, subtitle: "Build a wishlist with your favorite products to buy them later".localizedInApp, icon: "heart-icon"),
        ATCWalkthroughModel(title: "Order Tracking".localizedInApp, subtitle: "Monitor your orders and get updates when something changes.".localizedInApp, icon: "delivery-icon"),
        ATCWalkthroughModel(title: "Notifications".localizedInApp, subtitle: "Get notifications for new products, promotions and discounts.".localizedInApp, icon: "bell-icon"),
        ATCWalkthroughModel(title: "Stripe Payments".localizedInApp, subtitle: "We support all payment options, thanks to Stripe.".localizedInApp, icon: "coins-icon"),
        ATCWalkthroughModel(title: "Apple Pay".localizedInApp, subtitle: "Pay with a single click with Apple Pay.".localizedInApp, icon: "apple-icon"),
    ]

    func onboardingCoordinator(uiConfig: ATCUIGenericConfigurationProtocol) -> ATCOnboardingCoordinatorProtocol {
        let landingViewModel = ATCLandingScreenViewModel(imageIcon: "shopertino-logo-tinted",
                                                         title: "Welcome to Shopertino".localizedInApp,
                                                         subtitle: "Shop & get updates on new products, promotions and sales with our mobile app.".localizedInApp,
                                                         loginString: "Log In".localizedInApp,
                                                         signUpString: "Sign Up".localizedInApp)
        let loginViewModel = ATCLoginScreenViewModel(contactPointField: "E-mail or phone number".localizedInApp,
                                                     passwordField: "Password".localizedInApp,
                                                     title: "Sign In".localizedInApp,
                                                     loginString: "Log In".localizedInApp,
                                                     facebookString: "Facebook Login".localizedInApp,
                                                     separatorString: "OR".localizedInApp)

        let signUpViewModel = ATCSignUpScreenViewModel(nameField: "Full Name".localizedInApp,
                                                       phoneField: "Phone Number".localizedInApp,
                                                       emailField: "E-mail Address".localizedInApp,
                                                       passwordField: "Password".localizedInApp,
                                                       title: "Create new account".localizedInApp,
                                                       signUpString: "Sign Up".localizedInApp)
        return ATCClassicOnboardingCoordinator(landingViewModel: landingViewModel,
                                               loginViewModel: loginViewModel,
                                               signUpViewModel: signUpViewModel,
                                               uiConfig: ShopertinoOnboardingUIConfiguration(config: uiConfig),
                                               serverConfig: serverConfig,
                                               userManager: ATCSocialFirebaseUserManager())
    }

    func walkthroughVC(uiConfig: ATCUIGenericConfigurationProtocol) -> ATCWalkthroughViewController {
        let viewControllers = walkthroughs.map { ATCClassicWalkthroughViewController(model: $0, uiConfig: uiConfig, nibName: "ATCClassicWalkthroughViewController", bundle: nil) }
        return ATCWalkthroughViewController(nibName: "ATCWalkthroughViewController",
                                            bundle: nil,
                                            viewControllers: viewControllers,
                                            uiConfig: uiConfig)
    }

    var categoriesDataSource: ATCGenericCollectionViewControllerDataSource {
        if serverConfig.isShopifyEnabled {
            return ATCShopifyCategoriesDataSource(shopDomain: serverConfig.shopifyShopDomain,
                                                  apiKey: serverConfig.shopifyApiKey)
        } else if serverConfig.isFirebaseDatabaseEnabled {
            return ATCFirebaseFirestoreDataSource<Category>(tableName: "shopertino_categories")
        } else if serverConfig.isWooCommerceEnabled {
            return WooCommerceCategoriesDataSource(apiManager: WooCommerceAPIManager(baseURL: serverConfig.wooCommerceStoreURL,
                                                                                     key: serverConfig.wooCommerceStoreConsumerPublic,
                                                                                     secret: serverConfig.wooCommerceStoreConsumerSecret))
        }
        return ATCGenericLocalDataSource<Category>(items: MockStore.categories)
    }

    var homeProductsDataSource: ATCGenericCollectionViewControllerDataSource {
        if serverConfig.isShopifyEnabled {
            return ATCShopifyProductsDataSource(shopDomain: serverConfig.shopifyShopDomain,
                                                apiKey: serverConfig.shopifyApiKey,
                                                categoryId: mainCarouselCategory.id)
        } else if serverConfig.isFirebaseDatabaseEnabled {
            return ATCFirebaseFirestoreDataSource<Product>(tableName: "shopertino_products")
        } else if serverConfig.isWooCommerceEnabled {
            return WooCommerceProductsDataSource(apiManager: WooCommerceAPIManager(baseURL: serverConfig.wooCommerceStoreURL,
                                                                                   key: serverConfig.wooCommerceStoreConsumerPublic,
                                                                                   secret: serverConfig.wooCommerceStoreConsumerSecret))
        }
        return ATCGenericLocalDataSource<Product>(items: MockStore.products)
    }

    func productsDataSource(for category: Category) -> ATCGenericCollectionViewControllerDataSource {
        if serverConfig.isShopifyEnabled {
            return ATCShopifyProductsDataSource(shopDomain: serverConfig.shopifyShopDomain,
                                                apiKey: serverConfig.shopifyApiKey,
                                                categoryId: category.id)
        } else if serverConfig.isFirebaseDatabaseEnabled {
            let conditions: [String: Any] = ["category": category.id]
            return ATCFirebaseFirestoreDataSource<Product>(tableName: "shopertino_products", conditions: conditions)
        } else if serverConfig.isWooCommerceEnabled {
            return WooCommerceProductsDataSource(apiManager: WooCommerceAPIManager(baseURL: serverConfig.wooCommerceStoreURL,
                                                                                   key: serverConfig.wooCommerceStoreConsumerPublic,
                                                                                   secret: serverConfig.wooCommerceStoreConsumerSecret),
                                                 categoryId:category.id)
        }
        return ATCGenericLocalDataSource<Product>(items: MockStore.products)
    }

    func ordersDataSource(for user: ATCUser) -> ATCGenericCollectionViewControllerDataSource {
        if serverConfig.isFirebaseDatabaseEnabled {
            let conditions: [String: Any] = ["user_id": user.uid ?? ""]
            return ATCFirebaseFirestoreDataSource<ATCOrder>(tableName: "shopertino_orders",
                                                            conditions: conditions) {(orders: [ATCOrder]) in
                                                                return orders.sorted(by: { (o1, o2) -> Bool in
                                                                    return o1.createdAt < o2.createdAt
                                                                })
            }
        }
        return ATCGenericLocalDataSource<ATCOrder>(items: MockStore.orders)
    }

    var searchDataSource: ATCGenericSearchViewControllerDataSource {
        if serverConfig.isShopifyEnabled {
            return ATCShopifySearchDataSource<Product>(shopDomain: serverConfig.shopifyShopDomain,
                                                       apiKey: serverConfig.shopifyApiKey)
        } else if serverConfig.isFirebaseDatabaseEnabled {
            return ATCFirebaseSearchDataSource<Product>(tableName: "shopertino_products")
        } else if serverConfig.isWooCommerceEnabled {
            return ATCWooCommerceSearchDataSource<Product>(apiManager:
                WooCommerceAPIManager(baseURL: serverConfig.wooCommerceStoreURL,
                                      key: serverConfig.wooCommerceStoreConsumerPublic,
                                      secret: serverConfig.wooCommerceStoreConsumerSecret))
        }
        return ATCGenericLocalSearchDataSource(items: MockStore.products)
    }

    var placeOrderManager: ATCPlaceOrderManagerProtocol? {
        if serverConfig.isFirebaseDatabaseEnabled {
            return ATCFirebasePlaceOrderManager(tableName: "shopertino_orders")
        } else if serverConfig.isWooCommerceEnabled {
            return WooCommerceAPIManager(baseURL: serverConfig.wooCommerceStoreURL,
                                         key: serverConfig.wooCommerceStoreConsumerPublic,
                                         secret: serverConfig.wooCommerceStoreConsumerSecret)
        }
        return nil
    }
    
    var addAuthoredProduct: ATCAddAuthoredProductManagerProtocol? {
        return ATCFirebaseAddAuthoredProductManager(tableName: "shopertino_products")
    }
    
    func authoredProducts(for owner: String?) -> ATCGenericCollectionViewControllerDataSource {
        if serverConfig.isFirebaseDatabaseEnabled {
            let conditions: [String: Any] = ["vendorID": owner ?? ""]
            return ATCFirebaseFirestoreDataSource<Product>(tableName: "shopertino_products",
                                                            conditions: conditions) {(orders: [Product]) in
                                                                return orders.sorted(by: { (o1, o2) -> Bool in
                                                                    return o1.title < o2.title
                                                                })
            }
        }
        return ATCGenericLocalDataSource<Product>(items: [])
    }

    func adminOrdersDataSource(for viewer: ATCUser) -> ATCGenericCollectionViewControllerDataSource {
        if serverConfig.isFirebaseDatabaseEnabled {
            return ATCFirebaseFirestoreDataSource<ATCOrder>(tableName: "shopertino_orders") {(orders: [ATCOrder]) in
                return orders.sorted(by: { (o1, o2) -> Bool in
                    return o1.createdAt < o2.createdAt
                })
            }
        }
        return ATCGenericLocalDataSource<ATCOrder>(items: MockStore.orders)
    }

    var featuredCategory = Category(title: "",
                                    id: "4d215ERXPjNS1RX0Cp5L",//"Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzMyNTM5ODY5MjM2",
                                    imageURLString: "")
    var gridProductsCategory = Category(title: "",
                                    id: "4d215ERXPjNS1RX0Cp5L",// "Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzM1MDQ3NDczMjA0",
                                    imageURLString: "")
    var mainCarouselCategory = Category(title: "",
                                        id: "4d215ERXPjNS1RX0Cp5L",//"Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzMyNTM5ODY5MjM2",
                                        imageURLString: "")
}
