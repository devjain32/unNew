//
//  ATCComposerPhotoGalleryViewController.swift
//  ListingApp
//
//  Created by Florian Marcu on 10/6/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import Photos
import UIKit

class ATCComposerPhotoGalleryViewController: ATCGenericCollectionViewController {
    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        let layout = ATCLiquidCollectionViewLayout(cellPadding: 10)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let vcConfig = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                       pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
                                                                       collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
                                                                       collectionViewLayout: layout,
                                                                       collectionPagingEnabled: false,
                                                                       hideScrollIndicators: true,
                                                                       hidesNavigationBar: false,
                                                                       headerNibName: nil,
                                                                       scrollEnabled: true,
                                                                       uiConfig: uiConfig,
                                                                       emptyViewModel: nil)

        super.init(configuration: vcConfig)
        let size = CGSize(width: 70, height: 70)
        use(adapter: ATCFormImageRowAdapter(size: size, uiConfig: uiConfig), for: "ATCFormImageViewModel")
        setupDataSource()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectionBlock =  {[weak self] (navigationController, object, indexPath) in
            guard let `self` = self else { return }
            if let viewModel = object as? ATCFormImageViewModel {
                if let image = viewModel.image {
                    let vc = self.removeImageAlertController(image: image, index: indexPath.row)
                    self.parent?.present(vc, animated: true)
                } else {
                    let vc = self.addImageAlertController()
                    self.parent?.present(vc, animated: true)
                }
            }
        }
    }

    private func setupDataSource() {
        if genericDataSource == nil {
            genericDataSource = ATCGenericLocalDataSource<ATCFormImageViewModel>(items: [ATCFormImageViewModel(image: nil)])
            collectionView?.reloadData()
        }
    }

    private func removeImageAlertController(image: UIImage, index: Int) -> UIAlertController {
        let alert = UIAlertController(title: "Remove photo".localizedComposer, message: "", preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Remove photo".localizedComposer, style: .destructive, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.didTapRemoveImageButton(image: image, index: index)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localizedCore, style: .cancel, handler: nil))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = self.view.bounds
        }
        return alert
    }

    private func didTapRemoveImageButton(image: UIImage, index: Int) {
        if let ds = self.genericDataSource as? ATCGenericLocalDataSource<ATCFormImageViewModel> {
            ds.items.remove(at: index)
            self.collectionView?.reloadData()
        }
    }

    private func addImageAlertController() -> UIAlertController {
        let alert = UIAlertController(title: "Add Photos".localizedComposer, message: "", preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Import from Library".localizedComposer, style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.didTapAddImageButton(sourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Take Photo".localizedComposer, style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.didTapAddImageButton(sourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localizedCore, style: .cancel, handler: nil))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = self.view.bounds
        }
        return alert
    }

    private func didTapAddImageButton(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self

        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            picker.sourceType = sourceType
        } else {
            return
        }

        present(picker, animated: true, completion: nil)
    }

    fileprivate func didAddImage(_ image: UIImage) {
        if let ds = self.genericDataSource as? ATCGenericLocalDataSource<ATCFormImageViewModel> {
            ds.items.insert(ATCFormImageViewModel(image: image), at: ds.items.count - 1)
            self.collectionView?.reloadData()
        }
        
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ATCComposerPhotoGalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let asset = info[.phAsset] as? PHAsset {
            let size = CGSize(width: 500, height: 500)
            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { result, info in
                guard let image = result else {
                    return
                }
                self.didAddImage(image)
            }
        } else if let image = info[.originalImage] as? UIImage {
            didAddImage(image)
        }
       
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
