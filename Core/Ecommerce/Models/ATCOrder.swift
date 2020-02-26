//
//  ATCOrder.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 5/20/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import Firebase
import UIKit

class ATCOrderProduct: NSObject, ATCShoppingCartProduct {
    var cartId: String
    var cartTitle: String
    var cartImageURLString: String
    var cartPrice: Double
    var cartColors: [String]
    var cartSizes: [String]
    var selectedColor: String
    var selectedSize: String

    init(cartId: String,
         cartTitle: String,
         cartImageURLString: String,
         cartPrice: Double,
         cartColors: [String],
         cartSizes: [String],
         selectedColor: String,
         selectedSize: String) {
        self.cartId = cartId
        self.cartTitle = cartTitle
        self.cartImageURLString = cartImageURLString
        self.cartPrice = cartPrice
        self.cartColors = cartColors
        self.cartSizes = cartSizes
        self.selectedColor = selectedColor
        self.selectedSize = selectedSize
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(cartId, forKey: "cartId")
        aCoder.encode(cartTitle, forKey: "cartTitle")
        aCoder.encode(cartImageURLString, forKey: "cartImageURLString")
        aCoder.encode(cartPrice, forKey: "cartPrice")
        aCoder.encode(cartColors, forKey: "cartColors")
        aCoder.encode(cartSizes, forKey: "cartSizes")
        aCoder.encode(selectedColor, forKey: "selectedColor")
        aCoder.encode(selectedSize, forKey: "selectedSize")
    }

    public convenience required init?(coder aDecoder: NSCoder) {
        self.init(cartId: aDecoder.decodeObject(forKey: "cartId") as? String ?? "",
                  cartTitle: aDecoder.decodeObject(forKey: "cartTitle") as? String ?? "",
                  cartImageURLString: aDecoder.decodeObject(forKey: "cartImageURLString") as? String ?? "",
                  cartPrice: aDecoder.decodeDouble(forKey: "cartPrice"),
                  cartColors: aDecoder.decodeObject(forKey: "cartColors") as? [String] ?? [],
                  cartSizes: aDecoder.decodeObject(forKey: "cartSizes") as? [String] ?? [],
                  selectedColor: aDecoder.decodeObject(forKey: "selectedColor") as? String ?? "",
                  selectedSize: aDecoder.decodeObject(forKey: "selectedSize") as? String ?? ""
        )
    }
}

class ATCOrder: ATCGenericBaseModel {
    var shoppingCart: ATCShoppingCart?
    var createdAt: Date
    var id: String
    var status: String
    var customer: ATCUser?
    var address: ATCAddress?
    var vendorID: String?

    required convenience init(jsonDict: [String: Any]) {
        let shoppingCart = ATCShoppingCart()
        if let products = jsonDict["products"] as? [[String: Any]] {
            products.forEach { (productItem) in
                let product = ATCOrderProduct(cartId: (productItem["id"] as? String) ?? "",
                                              cartTitle: (productItem["name"] as? String) ?? "",
                                              cartImageURLString: (productItem["photo"] as? String) ?? "",
                                              cartPrice: (productItem["price"] as? Double) ?? Double((productItem["price"] as? String) ?? "0") ??  0.0,
                                              cartColors: (productItem["cartColors"] as? [String]) ?? [],
                                              cartSizes: (productItem["cartSizes"] as? [String]) ?? [],
                                              selectedColor: (productItem["selectedColor"] as? String) ?? "",
                                              selectedSize: (productItem["selectedSize"] as? String) ?? "")
                let quantity = (productItem["quantity"] as? Int) ?? 0
                shoppingCart.addProduct(product: product,
                                        quantity: quantity,
                                        selectedColor: product.selectedColor,
                                        selectedSize: product.selectedSize)
            }
        }
        var customer: ATCUser? = nil
        if let customerDict = jsonDict["user"] as? [String: Any] {
            customer = ATCUser(representation: customerDict)
        }
        var address: ATCAddress? = nil
        if let addressDict = jsonDict["address"] as? [String: Any] {
            address = ATCAddress(jsonDict: addressDict)
        }
        let vendorID: String? = jsonDict["vendorID"] as? String
        shoppingCart.vendorID = vendorID

        var createdAt: Date? = (jsonDict["createdAt"] as? Date)
        if createdAt == nil {
            if let timestamp = jsonDict["createdAt"] as? Timestamp {
                createdAt = timestamp.dateValue() as Date
            }
        }

        self.init(id: jsonDict["id"] as? String ?? NSUUID().uuidString,
                  shoppingCart: shoppingCart,
                  customer: customer,
                  address: address,
                  status: jsonDict["status"] as? String ?? "In transit".localizedEcommerce,
                  createdAt: createdAt ?? Date(),
                  vendorID: vendorID)
    }

    init(id: String,
         shoppingCart: ATCShoppingCart,
         customer: ATCUser?,
         address: ATCAddress?,
         status: String,
         createdAt: Date,
         vendorID: String? = nil) {
        self.id = id
        self.status = status
        self.shoppingCart = shoppingCart
        self.customer = customer
        self.createdAt = createdAt
        self.address = address
        self.vendorID = vendorID
    }

    func orderOptions() -> [CPKSelectOptionModel] {
        return [
            CPKSelectOptionModel(title: "Order Placed".localizedEcommerce, selected: "Order Placed".localizedEcommerce == status),
            CPKSelectOptionModel(title: "Order Shipped".localizedEcommerce, selected: "Order Shipped".localizedEcommerce == status),
            CPKSelectOptionModel(title: "In transit".localizedEcommerce, selected: "In transit".localizedEcommerce == status),
            CPKSelectOptionModel(title: "Order Completed".localizedEcommerce, selected: "Order Completed".localizedEcommerce == status),
            CPKSelectOptionModel(title: "Order Cancelled".localizedEcommerce, selected: "Order Cancelled".localizedEcommerce == status),
        ]
    }

    func headerImageURL() -> URL? {
        if let firstProductURL = shoppingCart?.distinctProducts().first?.cartImageURLString {
            return URL(string: firstProductURL)
        }
        return nil
    }

    func totalItems() -> Int {
        if let shoppingCart = shoppingCart {
            return shoppingCart.distinctProductItems().count
        }
        return 0
    }

    func totalPrice() -> Double? {
        return shoppingCart?.totalPrice()
    }

    var description: String {
        return ""
    }
}
