//
//  ATCReviewsListViewController.swift
//  ClassifiedsApp
//
//  Created by Florian Marcu on 11/28/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

let kATCReviewsListDidUpdate = NSNotification.Name(rawValue: "kATCReviewsListDidUpdate")

import UIKit

class ATCReviewsListViewController: ATCGenericCollectionViewController {
    fileprivate let addReviewButtonEnabled: Bool
    fileprivate let uiConfig: ATCUIGenericConfigurationProtocol
    fileprivate let reviewableEntity: ATCReviewable?
    fileprivate let user: ATCUser?
    fileprivate let reviewWriter: ATCFirebaseReviewWriter?

    init(uiConfig: ATCUIGenericConfigurationProtocol,
         dataSource: ATCGenericCollectionViewControllerDataSource?,
         addReviewButtonEnabled: Bool = false,
         reviewableEntity: ATCReviewable? = nil,
         reviewWriter: ATCFirebaseReviewWriter? = nil,
         user: ATCUser? = nil) {
        self.addReviewButtonEnabled = addReviewButtonEnabled
        self.uiConfig = uiConfig
        self.user = user
        self.reviewableEntity = reviewableEntity
        self.reviewWriter = reviewWriter

        let emptyViewModel = CPKEmptyViewModel(image: nil,
                                               title: nil,
                                               description: "There are no reviews yet.".localizedReviews,
                                               callToAction: nil)
        let reviewVCConf = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                           pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
                                                                           collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
                                                                           collectionViewLayout: ATCLiquidCollectionViewLayout(),
                                                                           collectionPagingEnabled: true,
                                                                           hideScrollIndicators: true,
                                                                           hidesNavigationBar: false,
                                                                           headerNibName: nil,
                                                                           scrollEnabled: true,
                                                                           uiConfig: uiConfig,
                                                                           emptyViewModel: emptyViewModel)
        super.init(configuration: reviewVCConf)
        self.use(adapter: ATCReviewRowAdapter(uiConfig: uiConfig), for: "ATCReview")
        self.genericDataSource = dataSource
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateReviewList), name: kATCReviewsListDidUpdate, object: nil)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if addReviewButtonEnabled {
            var rightButtons: [UIBarButtonItem] = []
            rightButtons.append(UIBarButtonItem(customView: self.addReviewButton()))
            self.navigationItem.rightBarButtonItems = rightButtons
        }
    }

    fileprivate func addReviewButton() -> UIButton {
        let reviewButton = UIButton()
        reviewButton.configure(icon: UIImage.localImage("inscription-icon", template: true),
                               color: uiConfig.mainThemeForegroundColor)
        reviewButton.snp.makeConstraints({ (maker) in
            maker.width.equalTo(22)
            maker.height.equalTo(22)
        })
        reviewButton.addTarget(self, action: #selector(didTapReviewButton), for: .touchUpInside)
        return reviewButton
    }
    
    @objc private func didTapReviewButton() {
        guard let user = user,
            let reviewableEntity = reviewableEntity,
            let reviewWriter = reviewWriter  else { return }
        let postReviewVC = ATCAddReviewViewController(nibName: "ATCAddReviewViewController",
                                                      bundle: nil,
                                                      reviewableEntity: reviewableEntity,
                                                      user: user,
                                                      reviewWriter: reviewWriter,
                                                      uiConfig: uiConfig)
        self.present(postReviewVC, animated: true, completion: nil)
    }

    @objc private func didUpdateReviewList() {
        self.genericDataSource?.loadFirst()
    }
}
