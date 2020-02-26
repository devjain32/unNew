//
//  ATCUser.swift
//  AppTemplatesCore
//
//  Created by Florian Marcu on 2/2/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import Foundation
import Firebase

open class ATCUser: NSObject, ATCGenericBaseModel, NSCoding {

    static let defaultAvatarURL = "https://www.iosapptemplates.com/wp-content/uploads/2019/06/empty-avatar.jpg"
    let kUserOnlinePresenceInterval: Int = 70
    
    var uid: String?
    var username: String?
    var email: String?
    var firstName: String?
    var lastName: String?
    var profilePictureURL: String? {
        didSet {
            hasDefaultAvatar = (profilePictureURL == nil
                || profilePictureURL == ""
                || profilePictureURL == ATCUser.defaultAvatarURL)
        }
    }
    var pushToken: String?
    var isOnline: Bool
    var lastOnlineDateTime: Date?
    var photos: [String]? = nil
    var location: ATCLocation? = nil
    var hasDefaultAvatar: Bool
    var isAdmin: Bool
    var adminVendorID: String? // If set, this user is the admin for this vendorID (e.g. restaurant owner)

    init(uid: String = "",
         firstName: String?,
         lastName: String?,
         avatarURL: String? = nil,
         email: String = "",
         pushToken: String? = nil,
         photos: [String]? = [],
         isOnline: Bool = false,
         lastOnlineDateTime: Date? = nil,
         location: ATCLocation? = nil,
         isAdmin: Bool = false,
         adminVendorID: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.uid = uid
        self.email = email
        self.profilePictureURL = ((avatarURL?.count ?? 0) > 0 ? avatarURL : ATCUser.defaultAvatarURL)
        self.hasDefaultAvatar = (avatarURL == nil || avatarURL == "" || avatarURL == ATCUser.defaultAvatarURL)
        self.pushToken = pushToken
        self.photos = photos
        self.isOnline = isOnline
        self.lastOnlineDateTime = lastOnlineDateTime
        self.location = location
        self.isAdmin = isAdmin
        self.adminVendorID = adminVendorID
    }

    public init(representation: [String: Any]) {
        self.firstName = representation["firstName"] as? String
        self.lastName = representation["lastName"] as? String
        let avatarURL = representation["profilePictureURL"] as? String
        self.profilePictureURL = (avatarURL?.count ?? 0) > 0 ? avatarURL : ATCUser.defaultAvatarURL
        self.hasDefaultAvatar = (avatarURL == nil || avatarURL == "" || avatarURL == ATCUser.defaultAvatarURL)
        self.username = representation["username"] as? String
        self.email = representation["email"] as? String
        self.uid = representation["userID"] as? String
        self.pushToken = representation["fcmToken"] as? String
        self.photos = representation["photos"] as? [String]
        self.isAdmin = (representation["isAdmin"] as? Bool) ?? false
        self.isOnline = (representation["isOnline"] as? Bool) ?? false
        self.lastOnlineDateTime = (representation["lastOnlineTimestamp"] as? Timestamp)?.dateValue()
        self.adminVendorID = representation["adminVendorID"] as? String

        var location: ATCLocation? = nil
        if let locationDict = representation["location"] as? [String: Any] {
            location = ATCLocation(representation: locationDict)
        }
        self.location = location
    }

    required public init(jsonDict: [String: Any]) {
        fatalError()
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(uid, forKey: "uid")
        aCoder.encode(username, forKey: "username")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(firstName, forKey: "firstName")
        aCoder.encode(lastName, forKey: "lastName")
        aCoder.encode(profilePictureURL, forKey: "profilePictureURL")
        aCoder.encode(pushToken, forKey: "pushToken")
        aCoder.encode(isOnline, forKey: "isOnline")
        aCoder.encode(lastOnlineDateTime, forKey: "lastOnlineTimestamp")
        aCoder.encode(photos, forKey: "photos")
        aCoder.encode(location, forKey: "location")
        aCoder.encode(isAdmin, forKey: "isAdmin")
        if let adminVendorID = adminVendorID {
            aCoder.encode(adminVendorID, forKey: "adminVendorID")
        }
    }

    public convenience required init?(coder aDecoder: NSCoder) {
        self.init(uid: aDecoder.decodeObject(forKey: "uid") as? String ?? "unknown",
                  firstName: aDecoder.decodeObject(forKey: "firstName") as? String ?? "",
                  lastName: aDecoder.decodeObject(forKey: "lastName") as? String ?? "",
                  avatarURL: aDecoder.decodeObject(forKey: "profilePictureURL") as? String ?? ATCUser.defaultAvatarURL,
                  email: aDecoder.decodeObject(forKey: "email") as? String ?? "",
                  pushToken: aDecoder.decodeObject(forKey: "pushToken") as? String ?? "",
                  photos: aDecoder.decodeObject(forKey: "photos") as? [String] ?? [],
                  isOnline: aDecoder.decodeBool(forKey: "isOnline"),
                  lastOnlineDateTime: aDecoder.decodeObject(forKey: "lastOnlineTimestamp") as? Date ?? nil,
                  location: aDecoder.decodeObject(forKey: "location") as? ATCLocation,
                  isAdmin: aDecoder.decodeBool(forKey: "isAdmin"),
                  adminVendorID: aDecoder.decodeObject(forKey: "adminVendorID") as? String)
    }

//    public func mapping(map: Map) {
//        username            <- map["username"]
//        email               <- map["email"]
//        firstName           <- map["first_name"]
//        lastName            <- map["last_name"]
//        profilePictureURL   <- map["profile_picture"]
//    }

    public func fullName() -> String {
        guard let firstName = firstName,
            let lastName = lastName else {
                return self.firstName ?? self.lastName ?? ""
        }
        return "\(firstName) \(lastName)"
    }

    public func firstWordFromName() -> String {
        if let firstName = firstName, let first = firstName.components(separatedBy: " ").first {
            return first
        }
        return "No name"
    }

    var initials: String {
        if let f = firstName?.first, let l = lastName?.first {
            return String(f) + String(l)
        }
        return "?"
    }

    var representation: [String : Any] {
        var rep: [String : Any] = [
            "userID": uid ?? "default",
            "profilePictureURL": profilePictureURL ?? ATCUser.defaultAvatarURL,
            "username": username ?? "",
            "email": email ?? "",
            "firstName": firstName ?? "",
            "lastName": lastName ?? "",
            "pushToken": pushToken ?? "",
            "photos": photos ?? "",
            ]
        if let location = location {
            rep["location"] = location.representation
        }
        return rep
    }
    
    public func showOnlineStatus() -> Bool {
        var showOnlineStatus = isOnline
        if showOnlineStatus, let lastOnlineDateTime = lastOnlineDateTime {
            let lastOnlineDateTimeInSeconds: Int = Int(Date().timeIntervalSince(lastOnlineDateTime))
            if lastOnlineDateTimeInSeconds > kUserOnlinePresenceInterval {
                showOnlineStatus = false
            }
        }
        return showOnlineStatus
    }
}
