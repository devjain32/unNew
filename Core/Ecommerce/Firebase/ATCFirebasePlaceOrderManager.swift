//
//  FirebasePlaceOrderManager.swift
//  Shopertino
//
//  Created by Florian Marcu on 5/23/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import FirebaseFirestore
import UIKit

class ATCFirebasePlaceOrderManager: ATCPlaceOrderManagerProtocol {
    var tableName: String

    init(tableName: String) {
        self.tableName = tableName
    }

    func placeOrder(user: ATCUser?,
                    address: ATCAddress?,
                    cart: ATCShoppingCart,
                    completion: @escaping (_ success: Bool) -> Void) {
        let firebaseWriter = ATCFirebaseFirestoreWriter(tableName: tableName)
        var representation = cart.representation()
        if let user = user {
            representation["user_id"] = user.uid
            representation["user"] = user.representation
        }
        if let address = address {
            representation["address"] = address.representation
        }
        representation["createdAt"] = Date()
        representation["status"] = "Order Placed"
        firebaseWriter.save(representation) {
            completion(true)
        }
    }

    func updateOrder(order: ATCOrder,
                     newStatus: String,
                     completion: @escaping (_ success: Bool) -> Void) {
        let data: [String: Any] = ["status": newStatus]
        Firestore
            .firestore()
            .collection(self.tableName)
            .document(order.id)
            .setData(data, merge: true, completion: { (error) in
                completion(error == nil)
            })
    }
}
