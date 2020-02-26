//
//  ATCMapDataSource.swift
//  MultiVendorApp
//
//  Created by Florian Marcu on 11/28/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import MapKit
import UIKit

protocol ATCMapAnnotationViewModel: MKAnnotation {
    var image: UIImage? {get}
    var title: String? {get}
    var subtitle: String? {get}
    var markerTintColor: UIColor? {get}
}

typealias ATCMapViewControllerSelectionBlock = (UIViewController, ATCMapAnnotationViewModel) -> Void

class ATCMapBasicAnnotation: NSObject, ATCMapAnnotationViewModel {
    var image: UIImage?

    let title: String?
    let locationName: String
    let coordinate: CLLocationCoordinate2D

    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate

        super.init()
    }

    var subtitle: String? {
        return locationName
    }

    var markerTintColor: UIColor? {
        return nil
    }
}

class ATCMapAnnotationView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let annotation = newValue as? ATCMapAnnotationViewModel else {return}
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            let detailLabel = UILabel()
            detailLabel.numberOfLines = 0
            detailLabel.font = detailLabel.font.withSize(12)
            detailLabel.text = annotation.subtitle
            detailCalloutAccessoryView = detailLabel
            if let color = annotation.markerTintColor {
                markerTintColor = color
            }

            if let annotationImage = annotation.image {
                image = annotationImage
            } else {
                image = nil
            }
        }
    }
}

protocol ATCMapDataSourceDelegate: class {
    func dataSource(_ dataSource: ATCMapDataSource, didLoadItems items: [ATCMapAnnotationViewModel])
}

protocol ATCMapDataSource: class {
    var delegate: ATCMapDataSourceDelegate? {get set}
    func load()
}

class ATCLocalMapDataSource: ATCMapDataSource {
    var items: [ATCMapAnnotationViewModel]
    weak var delegate: ATCMapDataSourceDelegate?

    init(items: [ATCMapAnnotationViewModel]) {
        self.items = items
    }

    func load() {
        self.delegate?.dataSource(self, didLoadItems: items)
    }
}
