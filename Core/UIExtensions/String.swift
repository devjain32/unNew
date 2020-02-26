//
//  String.swift
//  ListingApp
//
//  Created by Florian Marcu on 6/10/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

extension String {

    static func isEmpty(_ str: String?) -> Bool {
        return (str == nil || (str?.count ?? 0) <= 0)
    }

    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }

    func atcTrimmed() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func naturalColorNameToHexString() -> String {
        switch self.lowercased() {
            case "black": return "#000000"
            case "darkGray": return "#333333"
            case "lightGray": return "#cccccc"
            case "white": return "#ffffff"
            case "gray": return "#666666"
            case "red": return "#FF0000"
            case "green": return "#00ff00"
            case "blue": return "#0000FF"
            case "cyan": return "#00FFFF"
            case "yellow": return "#ffff00"
            case "magenta": return "#ff00ff"
            case "orange": return "#ffa500"
            case "purple": return "#800080"
            case "brown": return "#654321"
            default: return "#666666"
        }
    }
}
