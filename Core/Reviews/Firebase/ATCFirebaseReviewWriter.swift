//
//  ATCListingFirebaseReviewWriter.swift
//  ClassifiedsApp
//
//  Created by Florian Marcu on 10/18/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import FirebaseFirestore
import UIKit

class ATCFirebaseReviewWriter {
    let tableName: String
    let entityTableName: String

    init(tableName: String, entityTableName: String) {
        self.tableName = tableName
        self.entityTableName = entityTableName
    }

    func save(_ user: ATCUser,
              rating: Int,
              text: String,
              entity: ATCReviewable,
              completion: @escaping () -> Void) {
        var dictionary: [String: Any] = [
            "text": text,
            "rating": rating,
            "user": user.uid ?? "",
            "author": user.uid ?? "",
            "authorName": user.fullName(),
            "createdAt": Date(),
            "authorProfilePic": user.profilePictureURL ?? "",
            "entityID": entity.reviewableEntityID
        ]

        let newDocRef = Firestore.firestore().collection(self.tableName).document()
        dictionary["id"] = newDocRef.documentID
        newDocRef.setData(dictionary) { [weak self] (error) in
            guard let `self` = self else { return }
            Firestore
                .firestore()
                .collection(self.entityTableName)
                .document(entity.reviewableEntityID)
                .setData(["reviewsCount" : entity.reviewsCount + 1.0,
                          "reviewsSum": entity.reviewsSum + Double(rating)],
                         merge: true)
            NotificationCenter.default.post(name: kATCReviewsListDidUpdate, object: nil)
            completion()
        }
    }
}
