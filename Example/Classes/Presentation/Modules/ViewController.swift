//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit
import Cripper
import Framezilla
import Base
import Routes
import CollectionViewTools

final class ViewController: UIViewController {

    var imageQualitiesViewState: ImageQualitiesViewState?
    var imageResultState: ImageViewState?
    var backgroundColorState: ColorViewState = .init(name: "Backround Color",
                                                     color: .black)
    var overlayColorState: ColorViewState = .init(name: "Overlay Color",
                                                  color: UIColor.black.withAlphaComponent(0.5))
    var overlayClipBorderColorState: ColorViewState = .init(name: "Overlay Clip Border Color",
                                                            color: UIColor.white.withAlphaComponent(0.5))
    var overlayClipBorderWidthState: SliderViewState = .init(name: "Overlay Clip Border Width:",
                                                             value: 1, min: 1, max: 5)
    var overlayClipBorderInsetState: SliderViewState = .init(name: "Overlay Clip Border Inset:",
                                                             value: 1, min: 1, max: 30)
    var shapesState: SegmentedControlViewState = .init(name: "Shapes", index: 0, cases: ["square", "circle", "rect"])
    lazy var cropperButtonsState: ButtonsViewState = .init(name: "Cropper Buttons",
                                                           configurations: [.init(title: "Modal",
                                                                                  buttonClickHandler: presentCropperButtonPressed),
                                                                            .init(title: "Push",
                                                                                  buttonClickHandler: pushCropperButtonPressed)])

    var factory: ViewFactory = .init()
    var decorator: Decorator = .init()

    // MARK: - Subviews

    private lazy var collectionViewManager: CollectionViewManager = .init(collectionView: collectionView)

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.insetsLayoutMarginsFromSafeArea = true
        return collectionView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Crop a photo"
        collectionView.backgroundColor = .white
        view.add(collectionView)
        showImagePicker()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    // MARK: - Actions

    private func presentCropperButtonPressed() {
        let cropperViewController = makeCropperViewController()
        let viewController = decorator.modal(cropperViewController, acceptHandler: acceptCropActionTriggered)
        present(viewController, animated: true, completion: nil)
    }

    private func pushCropperButtonPressed() {
        let cropperViewController = makeCropperViewController()
        let viewController = decorator.instant(cropperViewController, acceptHandler: acceptCropActionTriggered)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func acceptCropActionTriggered(_ cropperViewController: CropperViewController) {
        let retakeState = ButtonsViewState(name: "Retake", configurations: [.init(title: "Retake",
                                                                                  buttonClickHandler: showImagePicker)])
        let resultImageState = ImageViewState(name: "Result", image: cropperViewController.makeCroppedImage())
        collectionViewManager.update(with: factory.makeSectionItems(viewStates: [
            resultImageState,
            SpaceViewState(name: "RetakeButtonTopSpace", height: 10),
            retakeState
        ]), animated: true)
    }

    // MARK: - Private

    private func showImagePicker() {
        let viewController = UIImagePickerController()
        viewController.sourceType = .camera
        viewController.delegate = self
        present(viewController, animated: true)
    }

    private func makeCropperViewController() -> CropperViewController {
        let cropViewController = CropperViewController(images: images())
        cropViewController.view.backgroundColor = backgroundColorState.color
        cropViewController.overlayView.overlayColor = overlayColorState.color ?? UIColor.black.withAlphaComponent(0.5)
        cropViewController.overlayView.clipBorderColor = overlayClipBorderColorState.color ?? UIColor.white.withAlphaComponent(0.5)
        cropViewController.overlayView.clipBorderInset = CGFloat(overlayClipBorderInsetState.value)
        cropViewController.overlayView.clipBorderWidth = CGFloat(overlayClipBorderWidthState.value)
        switch shapesState.index {
        case 0:
            cropViewController.cropOptions = [.square()]
        case 1:
            cropViewController.cropOptions = [.circle()]
        case 2:
            cropViewController.cropOptions = [.rect(width: 4, height: 3)]
        default:
            break
        }
        return cropViewController
    }

    private func images() -> [ImageScaleConstraint: UIImage] {
        guard let state = imageQualitiesViewState else {
            return [:]
        }
        var images = [ImageScaleConstraint: UIImage]()
        if let image = state.low {
            images[.less(2)] = image
        }
        if let image = state.normal {
            images[.default] = image
        }
        if let image = state.high {
            images[.great(3)] = image
        }
        return images
    }

    private func scaleImage(_ image: UIImage, scale: CGFloat, color: UIColor) -> UIImage {
        var newSize = image.size
        newSize.width *= scale
        newSize.height *= scale
        let rect = CGRect(origin: .zero, size: newSize)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { rendererContext in
            let context = rendererContext.cgContext
            image.draw(in: rect)
            context.setFillColor(color.cgColor)
            context.fill(rect)
        }
    }

    private func update(withImage image: UIImage) {
        let lowQualityImage = scaleImage(image, scale: 0.5, color: UIColor.red.withAlphaComponent(0.3))
        let normalQualityImage = scaleImage(image, scale: 0.7, color: UIColor.clear)
        let highQualityImage = scaleImage(image, scale: 1, color: UIColor.green.withAlphaComponent(0.3))
        let imageQualitiesViewState = ImageQualitiesViewState(low: lowQualityImage,
                                                              normal: normalQualityImage,
                                                              high: highQualityImage)

        collectionViewManager.sectionItems = factory.makeSectionItems(viewStates: [
            imageQualitiesViewState,
            backgroundColorState,
            overlayColorState,
            overlayClipBorderColorState,
            overlayClipBorderWidthState,
            overlayClipBorderInsetState,
            shapesState,
            SpaceViewState(name: "CropperButtonTopSpace", height: 10),
            cropperButtonsState
        ])
        self.imageQualitiesViewState = imageQualitiesViewState
    }
}

// MARK: - UINavigationControllerDelegate

extension ViewController: UINavigationControllerDelegate {

}

// MARK: - UIImagePickerControllerDelegate

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return AppRouter(viewController: self).showAlert(title: "No image found",
                                                             message: nil,
                                                             preferredStyle: .alert,
                                                             actions: [.init(title: "OK",
                                                                             style: .cancel,
                                                                             handler: nil)])
        }

        update(withImage: image)
    }
}
