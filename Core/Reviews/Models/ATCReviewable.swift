//
//  ATCReviewable.swift
//  ClassifiedsApp
//
//  Created by Florian Marcu on 11/28/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol ATCReviewable: class {
    var reviewableEntityID: String {get}
    var reviewsCount: Double {get}
    var reviewsSum: Double {get}
}
