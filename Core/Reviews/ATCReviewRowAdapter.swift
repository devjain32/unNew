//
//  ATCReviewRowAdapter.swift
//  ClassifiedsApp
//
//  Created by Florian Marcu on 10/18/18.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCReviewRowAdapter: ATCGenericCollectionRowAdapter {
    private let uiConfig: ATCUIGenericConfigurationProtocol

    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let review = object as? ATCReview, let cell = cell as? ATCReviewCollectionViewCell else { return }
        cell.authorImageView.kf.setImage(with: URL(string: review.authorProfilePic))
        cell.authorImageView.contentMode = .scaleAspectFill
        cell.authorImageView.clipsToBounds = true
        cell.authorImageView.layer.cornerRadius = 40.0/2.0

        cell.authorNameLabel.text = review.authorName
        cell.authorNameLabel.font = uiConfig.boldFont(size: 14.0)
        cell.authorNameLabel.textColor = uiConfig.mainTextColor

        cell.dateLabel.text = TimeFormatHelper.timeAgoString(date: review.date)
        cell.dateLabel.font = uiConfig.regularSmallFont
        cell.dateLabel.textColor = uiConfig.mainSubtextColor

        cell.textLabel.text = review.text
        cell.textLabel.textColor = uiConfig.colorGray3
        cell.textLabel.font = uiConfig.regularFont(size: 16.0)

        let stars: [UIImageView] = cell.ratingContainerView.subviews.compactMap({$0 as? UIImageView})
        for index in 0 ..< review.rating {
            stars[index].image = UIImage.localImage("star-filled-icon", template: true)
            stars[index].tintColor = uiConfig.mainThemeForegroundColor
        }
        for index in review.rating ..< stars.count {
            stars[index].image = UIImage.localImage("star-icon", template: true)
            stars[index].tintColor = uiConfig.mainTextColor
        }
        cell.ratingContainerView.backgroundColor = .clear
        cell.backgroundColor = uiConfig.mainThemeBackgroundColor
        cell.setNeedsLayout()
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ATCReviewCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        return CGSize(width: containerBounds.width, height: 105)
    }
}
