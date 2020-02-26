//
//  ShopertinoServerConfig.swift
//  Shopertino
//
//  Created by Florian Marcu on 4/27/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ShopertinoServerConfig: ATCOnboardingServerConfigurationProtocol {
    
    var isInstagramIntegrationEnabled: Bool = true
    var appIdentifier: String = "shopertino-swift-ios"
    var isFirebaseAuthEnabled: Bool = true
    var isFirebaseDatabaseEnabled: Bool = true
    var isStripeEnabled: Bool = true
    var isShopifyEnabled:Bool = false
    var shopifyShopDomain = "iosapptemplates.myshopify.com"
    var shopifyApiKey = "0cfb7301c219271d2d3eed6fe149b84b"
    var isWooCommerceEnabled: Bool = false
    var wooCommerceStoreURL = "https://couturebycapo.com/"
    var wooCommerceStoreConsumerPublic = "ck_3d89cd54b9c72c9e1deed52b0c0983cc02b3d5e1" //ck_139a326ad306fb0f82dfa2b767dcc4225eb169d2"
    var wooCommerceStoreConsumerSecret = "cs_2ea814d2906d1b8f6d6dce5a509ba7088aab6e28" // cs_356958bd8d2add5e21d3edca49400b43a384f1b5"
}
