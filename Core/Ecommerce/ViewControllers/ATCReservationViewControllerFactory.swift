//
//  ATCReservationViewControllerFactory.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 5/21/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import UIKit

class ATCReservationViewControllerFactory {
    func reservationVC(shop: ATCShop, serverConfig: ATCOnboardingServerConfigurationProtocol, uiEcommerceConfig: ATCUIConfigurationProtocol) -> ReservationViewController {
        return ReservationViewController(shop: shop,
                                         serverConfig: serverConfig,
                                         nibName: "ReservationViewController",
                                         bundle: nil,
                                         uiEcommerceConfig: uiEcommerceConfig)
    }
}
