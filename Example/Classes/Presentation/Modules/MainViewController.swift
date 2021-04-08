//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit
import Cripper
import Framezilla
import Base
import Routes
import CollectionViewTools

class MainViewController: ViewController {

    var imageQualitiesViewState: ImageQualitiesViewState?
    var imageResultState: ImageViewState?
    lazy var backgroundColorState: ColorViewState = .init(name: "Backround Color",
                                                          color: .black)
    lazy var overlayColorState: ColorViewState = .init(name: "Overlay Color",
                                                       color: UIColor.black.withAlphaComponent(0.5))
    lazy var overlayClipBorderColorState: ColorViewState = .init(name: "Overlay Clip Border Color",
                                                                 color: UIColor.white.withAlphaComponent(0.5))
    var overlayClipBorderWidthState: SliderViewState = .init(name: "Overlay Clip Border Width:",
                                                             value: 1, min: 1, max: 5)
    lazy var overlayClipBorderInsetState: SliderViewState = .init(name: "Overlay Clip Border Inset:",
                                                                  value: 17, min: 1, max: 30)
    lazy var overlayBlurAlphaState: SliderViewState = .init(name: "Overlay Blur Alpha:",
                                                            value: 0.5, min: 0, max: 1)
    lazy var overlayBlurRadiusState: SliderViewState = .init(name: "Overlay Blur Radius:",
                                                             value: 5, min: 0, max: 10)
    lazy var shapesState: SegmentedControlViewState = .init(name: "Shapes:", index: 0, cases: ["Square", "Circle", "Rect"])
    lazy var modeState: SegmentedControlViewState = .init(name: "Mode:", index: 0, cases: ["Preview", "Crop"])
    lazy var cropperButtonsState: ButtonsViewState = .init(name: "Cropper Buttons",
                                                           configurations: [.init(title: "Modal",
                                                                                  buttonClickHandler: presentCropperButtonPressed),
                                                                            .init(title: "Push",
                                                                                  buttonClickHandler: pushCropperButtonPressed)])
    lazy var backgroundState: ButtonsViewState = .init(name: "",
                                                       configurations: [.init(title: "Background",
                                                                              buttonClickHandler: makePushHandler(backgroundViewController))])
    lazy var overlayState: ButtonsViewState = .init(name: "",
                                                    configurations: [.init(title: "Overlay",
                                                                           buttonClickHandler: makePushHandler(overlayViewController))])

    private lazy var backgroundViewController: UIViewController = StatesViewController(states: [backgroundColorState])
    private lazy var overlayViewController: UIViewController = StatesViewController(states: [overlayColorState,
                                                                                             overlayClipBorderColorState,
                                                                                             overlayClipBorderWidthState,
                                                                                             overlayClipBorderInsetState,
                                                                                             overlayBlurAlphaState,
                                                                                             overlayBlurRadiusState])
    private var customizationStates: [Any] = []

    var decorator: Decorator = .init()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        initialStates = [
            ButtonsViewState(name: "Camera", configurations: [.init(title: "Camera", buttonClickHandler: showCameraImagePicker)]),
            ButtonsViewState(name: "Library", configurations: [.init(title: "Library", buttonClickHandler: showLibraryImagePicker)])
        ]
        super.viewDidLoad()
        navigationItem.title = "Crop a photo"
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
        guard case let .normal(image) = cropperViewController.makeCroppResult() else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        let cameraState = ButtonsViewState(name: "Camera", configurations: [.init(title: "Camera", buttonClickHandler: showCameraImagePicker)])
        let libraryState = ButtonsViewState(name: "Library", configurations: [.init(title: "Library", buttonClickHandler: showLibraryImagePicker)])
        let resultImageState = ImageViewState(name: "Result", image: image)
        let backState = ButtonsViewState(name: "Back", configurations: [.init(title: "Back", buttonClickHandler: back)])
        collectionViewManager.update(with: factory.makeSectionItems(viewStates: [
            resultImageState,
            SpaceViewState(name: "RetakeButtonTopSpace", height: 10),
            cameraState,
            libraryState,
            backState
        ]), animated: true)
    }

    // MARK: - Private

    private func makePushHandler(_ viewController: UIViewController) -> (() -> Void) {
        return { [weak self] in
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    private func showCameraImagePicker() {
        showImagePicker(sourceType: .camera)
    }

    private func showLibraryImagePicker() {
        showImagePicker(sourceType: .photoLibrary)
    }

    private func back() {
        collectionViewManager.sectionItems = factory.makeSectionItems(viewStates: customizationStates)
    }

    private func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        let viewController = UIImagePickerController()
        viewController.sourceType = sourceType
        viewController.delegate = self
        present(viewController, animated: true)
    }

    private func makeCropperViewController() -> CropperViewController {
        let cropViewController = CropperViewController(images: images())
        cropViewController.backColor = backgroundColorState.color ?? .black
        cropViewController.overlayColor = overlayColorState.color ?? UIColor.black.withAlphaComponent(0.5)
        cropViewController.clipBorderColor = overlayClipBorderColorState.color ?? UIColor.white.withAlphaComponent(0.5)
        cropViewController.clipBorderInset = CGFloat(overlayClipBorderInsetState.value)
        cropViewController.clipBorderWidth = CGFloat(overlayClipBorderWidthState.value)
        cropViewController.blurAlpha = CGFloat(overlayBlurAlphaState.value)
        cropViewController.blurRadius = CGFloat(overlayBlurRadiusState.value)
        switch shapesState.index {
        case 0:
            cropViewController.cropOption = .square
        case 1:
            cropViewController.cropOption = .circle
        case 2:
            cropViewController.cropOption = .rect(aspectRatio: 4 / 3)
        default:
            break
        }
        switch modeState.index {
        case 0:
            cropViewController.mode = .rect
        case 1:
            cropViewController.mode = .path
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

        customizationStates = [
            imageQualitiesViewState,
            backgroundState,
            overlayState,
            shapesState,
            SpaceViewState(name: "ModeTopSpace", height: 10),
            modeState,
            SpaceViewState(name: "CropperButtonTopSpace", height: 10),
            cropperButtonsState
        ]
        collectionViewManager.sectionItems = factory.makeSectionItems(viewStates: customizationStates)
        self.imageQualitiesViewState = imageQualitiesViewState
    }
}


// MARK: - UIImagePickerControllerDelegate

extension MainViewController: UIImagePickerControllerDelegate {
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
