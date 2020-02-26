//
//  ATCMapViewController.swift
//  ListingApp
//
//  Created by Florian Marcu on 6/12/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import SwiftUI
import UIKit
import MapKit

class ATCMapViewController: UIViewController, ATCMapDataSourceDelegate {
    let mapView = MKMapView()
    let regionRadius: CLLocationDistance
    var dataSource: ATCMapDataSource
    let hostViewController: UIViewController?
    var displayedAnnotations: [ATCMapAnnotationViewModel]
    let uiConfig: ATCUIGenericConfigurationProtocol
    let localFiltersStore: ATCLocalFiltersStore?
    let dsProvider: ATCFilteredMapDataSourceProvider?
    let categoryID: String?
    var selectionBlock: ATCMapViewControllerSelectionBlock?
    var editMode: Bool
    var myLocationEnabled: Bool
    var myLocationButtonHostVC: UIHostingController<ATCMyLocationButton>? = nil
    var locationManager: ATCLocationManager? = nil

    init(uiConfig: ATCUIGenericConfigurationProtocol,
         regionRadius: CLLocationDistance,
         dataSource: ATCMapDataSource,
         localFiltersStore: ATCLocalFiltersStore? = nil,
         dsProvider: ATCFilteredMapDataSourceProvider? = nil,
         categoryID: String?,
         hostViewController: UIViewController? = nil,
         editMode: Bool = false,
         myLocationEnabled: Bool) {
        self.uiConfig = uiConfig
        self.dataSource = dataSource
        self.categoryID = categoryID
        self.dsProvider = dsProvider
        self.editMode = editMode
        self.regionRadius = regionRadius
        self.localFiltersStore = localFiltersStore
        self.hostViewController = hostViewController
        self.displayedAnnotations = []
        self.myLocationEnabled = myLocationEnabled
        super.init(nibName: nil, bundle: nil)
        self.dataSource.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)

        mapView.register(ATCMapAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.delegate = self
        mapView.showsUserLocation = true
        dataSource.load()

        if myLocationEnabled {
            var button = ATCMyLocationButton(uiConfig: uiConfig)
            button.delegate = self
            let myLocationButtonHostVC = UIHostingController(rootView: button)
            self.addChildViewControllerWithView(myLocationButtonHostVC, toView: mapView)
            myLocationButtonHostVC.view.clipsToBounds = true
            self.myLocationButtonHostVC = myLocationButtonHostVC
        }
        var navButtons = [UIBarButtonItem(customView: self.filtersButton())]
        if hostViewController != nil {
            navButtons.append(UIBarButtonItem(customView: self.listButton()))
        }
        self.navigationItem.rightBarButtonItems = navButtons
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bounds = view.bounds
        myLocationButtonHostVC?.view.frame = CGRect(x: bounds.width - 75, y: bounds.height - 75, width: 50, height: 50)
        myLocationButtonHostVC?.view.layer.cornerRadius = 25
        mapView.frame = bounds
    }

    func dataSource(_ dataSource: ATCMapDataSource, didLoadItems items: [ATCMapAnnotationViewModel]) {
        // remove old annotations
        displayedAnnotations.forEach { (annotation) in
            mapView.removeAnnotation(annotation)
        }
        // add new annotations
        items.forEach { (annotation) in
            mapView.addAnnotation(annotation)
        }
        // center map
        displayedAnnotations = items
        //centerMap()
        myLocationButtonDidTap()

    }

    fileprivate func centerMap() {
        var minLat: CLLocationDegrees = 90.0
        var maxLat: CLLocationDegrees = -90.0
        var minLon: CLLocationDegrees = 180.0
        var maxLon:CLLocationDegrees = -180.0
        displayedAnnotations.forEach { (annotation) in
            if (annotation.coordinate.latitude < minLat) {
                minLat = annotation.coordinate.latitude
            }
            if (annotation.coordinate.longitude < minLon) {
                minLon = annotation.coordinate.longitude
            }
            if (annotation.coordinate.latitude > maxLat) {
                maxLat = annotation.coordinate.latitude
            }
            if (annotation.coordinate.longitude > maxLon) {
                maxLon = annotation.coordinate.longitude
            }
        }
        let span = MKCoordinateSpan(latitudeDelta: maxLat - minLat, longitudeDelta: maxLon - minLon)

        centerMapOnLocation(location: CLLocationCoordinate2DMake((maxLat - span.latitudeDelta / 2), maxLon - span.longitudeDelta / 2))
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
    }

    fileprivate func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegion(center: location,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    fileprivate func listButton() -> UIButton {
        let listButton = UIButton()
        listButton.configure(icon: UIImage.localImage("list-icon", template: true), color: uiConfig.mainThemeForegroundColor)
        listButton.snp.makeConstraints({ (maker) in
            maker.width.equalTo(25)
            maker.height.equalTo(25)
        })
        listButton.addTarget(self, action: #selector(didTapListButton), for: .touchUpInside)
        return listButton
    }

    fileprivate func filtersButton() -> UIButton {
        let filtersButton = UIButton()
        filtersButton.configure(icon: UIImage.localImage("filters-icon", template: true), color: uiConfig.mainThemeForegroundColor)
        filtersButton.snp.makeConstraints({ (maker) in
            maker.width.equalTo(25)
            maker.height.equalTo(25)
        })
        filtersButton.addTarget(self, action: #selector(didTapFiltersButton), for: .touchUpInside)
        return filtersButton
    }

    @objc fileprivate func didTapFiltersButton() {
        if let dsProvider = dsProvider, let localFiltersStore = localFiltersStore {
            let vc = ATCFiltersViewController(uiConfig: uiConfig,
                                              dataSource: dsProvider.filtersDataSource(for: categoryID),
                                              categoryID: categoryID,
                                              localFiltersStore: localFiltersStore)
            vc.delegate = self
            vc.title = "Filters".localizedCore
            let navVC = UINavigationController(rootViewController: vc)
            self.present(navVC, animated: true, completion: nil)
        }
    }

    @objc fileprivate func didTapListButton() {
        if let navController = self.navigationController, let hostViewController = hostViewController {
            self.navigationController?.popViewController(animated: false)
            navController.pushViewController(hostViewController, animated: false)
        }
    }
}

extension ATCMapViewController: ATCFiltersViewControllerDelegate {
    func filtersViewController(_ vc: ATCFiltersViewController, didUpdateTo filters:[ATCSelectFilter]) {
        if let dsProvider = dsProvider {
            self.dataSource = dsProvider.mapDataSource(for: categoryID)
            self.dataSource.delegate = self
            self.dataSource.load()
            if let hostViewController = hostViewController as? ATCFiltersViewControllerDelegate {
                hostViewController.filtersViewController(vc, didUpdateTo: filters)
            }
        }
    }
}

extension ATCMapViewController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let selectionBlock = selectionBlock, let tappedAnnotation = view.annotation as? ATCMapAnnotationViewModel else { return }
        for annotation in displayedAnnotations {
            if (tappedAnnotation.coordinate.latitude == annotation.coordinate.latitude
                && tappedAnnotation.coordinate.longitude == annotation.coordinate.longitude) {
                selectionBlock(self, annotation)
                return
            }
        }
    }

    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (!self.editMode) {
            return nil
        }
        if annotation is MKUserLocation  {
            return nil
        }

        let identifier = "DroppedPin"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            view?.annotation = annotation
        }
        view?.isDraggable = true
        view?.canShowCallout = true
        view?.animatesDrop = true
        return view
    }
}

extension ATCMapViewController: ATCMyLocationButtonDelegate {
    func myLocationButtonDidTap() {
        self.locationManager = ATCLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUsePermission()
    }
}

extension ATCMapViewController: ATCLocationManagerDelegate {
    func locationManager(_ locationManager: ATCLocationManager, didReceive location: ATCLocation) {
        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))
        self.mapView.setRegion(region, animated: true)
    }
}
