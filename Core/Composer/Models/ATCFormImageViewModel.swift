//
//  ATCFormImageViewModel.swift
//  ListingApp
//
//  Created by Florian Marcu on 10/6/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCFormImageViewModel: ATCGenericBaseModel {
    var image: UIImage? = nil
    var description: String {
        return "ATCFormImageViewModel"
    }

    init(image: UIImage?) {
        self.image = image
    }

    required init(jsonDict: [String : Any]) {
        fatalError()
    }
}
