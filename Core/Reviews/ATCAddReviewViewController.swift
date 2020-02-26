//
//  ATCListingAddReviewViewController.swift
//  ClassifiedsApp
//
//  Created by Florian Marcu on 10/19/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCAddReviewViewController: UIViewController {

    @IBOutlet var closeButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var ratingContainerView: UIView!
    @IBOutlet var textView: UITextView!
    
    var reviewableEntity: ATCReviewable
    var user: ATCUser
    var uiConfig: ATCUIGenericConfigurationProtocol
    var rating: Int
    let reviewWriter: ATCFirebaseReviewWriter

    init(nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         reviewableEntity: ATCReviewable,
         user: ATCUser,
         reviewWriter: ATCFirebaseReviewWriter,
         uiConfig: ATCUIGenericConfigurationProtocol) {
        self.reviewableEntity = reviewableEntity
        self.user = user
        self.uiConfig = uiConfig
        self.rating = 5
        self.reviewWriter = reviewWriter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "Add a Review".localizedReviews
        titleLabel.font = uiConfig.boldSuperLargeFont
        titleLabel.textColor = uiConfig.mainTextColor

        closeButton.configure(icon: UIImage.localImage("close-x-icon", template: true), color: uiConfig.mainThemeForegroundColor)
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)

        textView.inputAccessoryView = self.postReviewButton()
        textView.font = uiConfig.regularFont(size: 18.0)
        textView.becomeFirstResponder()

        if let starButtons = ratingContainerView.subviews as? [UIButton] {
            for starBtn in starButtons {
                starBtn.addTarget(self, action: #selector(self.didTapStarButton(_:)), for: .touchUpInside)
            }
            updateStars()
        }
        self.view.backgroundColor = uiConfig.mainThemeBackgroundColor
        ratingContainerView.backgroundColor = uiConfig.mainThemeBackgroundColor
    }

    fileprivate func postReviewButton() -> UIButton {
        let postReviewButton = UIButton()
        postReviewButton.configure(color: uiConfig.mainThemeBackgroundColor,
                                   font: uiConfig.regularFont(size: 20),
                                   cornerRadius: 0.0,
                                   borderColor: uiConfig.mainThemeBackgroundColor,
                                   backgroundColor: uiConfig.mainThemeForegroundColor,
                                   borderWidth: 0)
        postReviewButton.setTitle("Add review".localizedReviews, for: .normal)
        postReviewButton.snp.makeConstraints({ (maker) in
            maker.height.equalTo(65)
        })
        postReviewButton.addTarget(self, action: #selector(didTapPostReviewButton), for: .touchUpInside)
        return postReviewButton
    }

    fileprivate func updateStars() {
        guard let stars = ratingContainerView.subviews as? [UIButton] else { return }
        for index in 0 ..< rating {
            stars[index].setImage(UIImage.localImage("star-filled-icon", template: true), for: .normal)
            stars[index].tintColor = uiConfig.mainThemeForegroundColor
        }
        for index in rating ..< stars.count {
            stars[index].setImage(UIImage.localImage("star-icon", template: true), for: .normal)
            stars[index].tintColor = uiConfig.mainTextColor
        }
    }

    @objc private func didTapStarButton(_ sender: UIButton) {
        if let starButtons = ratingContainerView.subviews as? [UIButton] {
            for (index, starBtn) in starButtons.enumerated() {
                if sender == starBtn {
                    self.rating = (index + 1)
                    self.updateStars()
                    break
                }
            }
        }
    }

    @objc private func didTapPostReviewButton() {
        guard let text = textView.text else {
            showErrorMessage("You cannot submit an empty review.".localizedReviews)
            return
        }
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedText.count < 20 {
            showErrorMessage("Please describe your review in more details. Your review needs to contain at least 50 letters.".localizedReviews)
            return
        }
        if (user.uid?.count ?? 0) <= 0
            || (user.profilePictureURL?.count ?? 0) <= 0
            || user.hasDefaultAvatar
            || user.fullName().count <= 0 {
            showErrorMessage("You can't submit a review, unless you have a complete profile. Please make sure you uploaded a profile picture, and you specified your full name.".localizedReviews)
            return
        }
        let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Posting".localizedReviews))
        hud.show(in: view)
        reviewWriter.save(user, rating: rating, text: text, entity: reviewableEntity) {[weak self] in
            guard let `self` = self else { return }
            hud.dismiss()
            self.dismiss(animated: false, completion: nil)
        }
    }

    @objc private func didTapCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }

    private func showErrorMessage(_ string: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: string, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK".localizedCore, style: .cancel, handler: { (action) in
            if let completion = completion {
                completion()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
