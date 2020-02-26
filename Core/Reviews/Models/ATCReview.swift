//
//  ATCReview.swift
//  ClassifiedsApp
//
//  Created by Florian Marcu on 10/18/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCReview: ATCGenericBaseModel {
    var description: String {
        return id
    }

    var text: String
    var id: String
    var rating: Int
    var authorID: String
    var authorName: String
    var authorProfilePic: String
    var entityID: String // the ID of the entity being reviewed
    var date: Date

    init(id: String, text: String, rating: Int, authorID: String, authorName: String, authorProfilePic: String, entityID: String, date: Date) {
        self.id = id
        self.text = text
        self.rating = rating
        self.authorID = authorID
        self.authorName = authorName
        self.authorProfilePic = authorProfilePic
        self.entityID = entityID
        self.date = date
    }

    required init(jsonDict: [String: Any]) {
        self.id = jsonDict["id"] as? String ?? ""
        self.text = jsonDict["text"] as? String ?? ""
        self.rating = jsonDict["rating"] as? Int ?? 5
        self.authorID = jsonDict["user"] as? String ?? ""
        self.authorName = jsonDict["authorName"] as? String ?? ""
        self.authorProfilePic = jsonDict["authorProfilePic"] as? String ?? ""
        self.entityID = jsonDict["entityID"] as? String ?? ""
        self.date = jsonDict["date"] as? Date ?? Date()
    }
}
