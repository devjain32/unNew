//
//  ATCSearchBarAdapter.swift
//  ChatApp
//
//  Created by Florian Marcu on 8/21/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

protocol ATCSearchBarAdapterDelegate: class {
    func searchAdapterDidFocus(_ adapter: ATCSearchBarAdapter)
}

class ATCSearchBarAdapter: NSObject, ATCGenericCollectionRowAdapter, UISearchBarDelegate {
    let uiConfig: ATCUIGenericConfigurationProtocol
    weak var delegate: ATCSearchBarAdapterDelegate?

    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let viewModel = object as? ATCSearchBar, let cell = cell as? ATCSearchBarCollectionViewCell else { return }
        cell.searchBar.backgroundColor = .clear
        cell.searchBar.tintColor = UIColor.darkModeColor(hexString: "#8e8d93")
        cell.searchBar.searchBarStyle = .minimal
        cell.searchBar.backgroundImage = nil

        cell.searchBar.placeholder = viewModel.placeholder
        cell.searchBar.delegate = self

        cell.containerView.backgroundColor = .clear
        cell.setNeedsLayout()
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ATCSearchBarCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        guard object is ATCSearchBar else { return .zero }
        return CGSize(width: containerBounds.width, height: 50)
    }

    // MARK: - UISearchBarDelegate
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.delegate?.searchAdapterDidFocus(self)
    }
}
