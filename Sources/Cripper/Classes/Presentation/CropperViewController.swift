//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

public final class CropperViewController: UIViewController {

    public var cropOptions: [CropViewOption] = [] {
        didSet {
            cropPatternBuilder = cropOptions.first?.cropPatternBuilder ?? CropPatterBuilders.square.cropPatternBuilder
        }
    }

    public var maximumScale: CGFloat = 5
    public var completionHandler: ((UIImage?) -> Void)?
    public var mode: CropPattern.Mode = .rect
    public var backColor: UIColor = .black

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .portrait
    }

    typealias Cell = CropCell

    private let cellType = Cell.self
    private let reuseId = String(describing: Cell.self)

    private var cripper: Cropper = .init()
    private var feedbackGenerator: UIImpactFeedbackGenerator?

    private var cropPatternBuilder: CropPatternBuilder = CropPatterBuilders.square.cropPatternBuilder {
        didSet {
            updateCropOverlay()
            updateScaling()
        }
    }

    private var pointImageSize: CGSize {
        guard let image = imageView.image else {
            return .zero
        }
        let aspectRatio = image.size.width / image.size.height
        let width = view.bounds.width
        let heiight = width / aspectRatio
        return .init(width: width, height: heiight)
    }

    public var imageProvider: ImageProvider

    public convenience init(image: UIImage) {
        self.init(imageProvider: DefaultImageProvider(image: image))
    }

    public convenience init(images: [ImageScaleConstraint: UIImage]) {
        self.init(imageProvider: DefaultImageProvider(images: images))
    }

    public init(imageProvider: ImageProvider) {
        self.imageProvider = imageProvider
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Subviews

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.insetsLayoutMarginsFromSafeArea = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.decelerationRate = .fast
        scrollView.delegate = self
        return scrollView
    }()

    public private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    public private(set) lazy var imageWrapperView: UIView = .init()

    public private(set) lazy var overlayView: CropOverlayView = {
        let view = CropOverlayView()
        view.backgroundColor = .clear
        return view
    }()

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.addSubview(imageWrapperView)
        imageWrapperView.addSubview(imageView)
        view.addSubview(overlayView)
        view.backgroundColor = backColor
        updateCropOverlay()
        imageProvider.fetchImage(withScale: 1) { [weak self] image in
            self?.imageView.image = image
            self?.view.setNeedsLayout()
            self?.view.layoutIfNeeded()
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        feedbackGenerator = .init(style: .light)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        overlayView.frame = view.bounds
        scrollView.frame = view.bounds
        guard imageView.image != nil else {
            return
        }
        let pattern = makeCropPattern()
        let scale = imageScale(in: pattern.previewRect)
        scrollView.maximumZoomScale = maximumScale
        scrollView.minimumZoomScale = scale
        updateImage(withScale: scale)
        scrollView.contentInset = .zero
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        updateScrollViewContent(withContentOffset: false)
        updateCropOverlay()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
            self.updateScrollViewContent(withContentOffset: true)
        }
    }

    public func makeCroppedImage() -> UIImage? {
        guard let image = imageView.image else {
            return nil
        }
        return cripper.crop(image: image, with: makeCropPattern())
    }

    // MARK: - Private

    private func makeCropPattern() -> CropPattern {
        let rect = view.bounds
        var pattern = cropPatternBuilder.makeCropPattern(in: rect)
        pattern.translation = .init(x: scrollView.contentOffset.x,
                                 y: scrollView.contentOffset.y)
        pattern.scale = UIScreen.main.scale / scrollView.zoomScale
        pattern.mode = mode
        return pattern
    }

    private func updateCropOverlay() {
        overlayView.cropPatternBuilder = cropPatternBuilder
        overlayView.showsGridLines = false
        view.setNeedsDisplay()
    }

    private func updateScaling() {
        let pattern = makeCropPattern()
        let scale = self.imageScale(in: pattern.previewRect)
        scrollView.maximumZoomScale = maximumScale
        scrollView.minimumZoomScale = scale
        if scrollView.zoomScale < scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
        else if scrollView.zoomScale > scrollView.maximumZoomScale {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
        else {
            // To fix invalid scroll position after min scale changing
            let additionalSize = self.additionalSize()
            guard abs(additionalSize.width) > 1e-9 || abs(additionalSize.height) > 1e-9 else {
                return
            }
            scrollView.setZoomScale(scrollView.zoomScale * 1.001, animated: true)
        }
    }

    private func updateScrollViewContent(withContentOffset: Bool = false) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0.0)

        let pattern = makeCropPattern()
        let imageSize = pointImageSize
        let scale = acceptibleScale()
        let scaledImageSize = self.scaledImageSize(imageSize: imageSize, scale: scale)
        let scaledImageOffset = imageOffset(imageSize: scaledImageSize)
        let insets = self.previewInsets(pattern: pattern, imageSize: scaledImageSize, offset: scaledImageOffset)
        let requiredSize = self.requiredSize(insets: insets, imageSize: scaledImageSize, scale: scale)
        let additionalSize = self.additionalSize(insets: insets, imageSize: imageSize, scale: scale, requiredSize: requiredSize)

        imageWrapperView.bounds = .init(x: 0, y: 0,
                                        width: requiredSize.width,
                                        height: requiredSize.height)
        imageView.frame =  .init(origin: .init(x: insets.left / scale + additionalSize.width / 2,
                                               y: insets.top / scale + additionalSize.height / 2),
                                 size: imageSize)
        imageWrapperView.center = .init(x: scrollView.contentSize.width * 0.5 + offsetX,
                                       y: scrollView.contentSize.height * 0.5 + offsetY)

        updateImage(withScale: scale)

        if withContentOffset {
           scrollView.setContentOffset(.init(x: insets.left,
                                             y: insets.top),
                                       animated: false)
        }
    }

    private func updateImage(withScale scale: CGFloat) {
        imageProvider.fetchImage(withScale: scale) { [weak self] image in
            self?.imageView.image = image
        }
    }

    private func acceptibleScale() -> CGFloat {
        scrollView.zoomScale > scrollView.minimumZoomScale ? scrollView.zoomScale : scrollView.minimumZoomScale
    }

    private func scaledImageSize(imageSize: CGSize, scale: CGFloat) -> CGSize {
        let imageWidth = imageSize.width * scale
        let imageHeight = imageSize.height * scale
        return .init(width: imageWidth, height: imageHeight)
    }

    private func imageOffset(imageSize: CGSize) -> CGPoint {
        let imageX = (view.bounds.width - imageSize.width) / 2
        let imageY = (view.bounds.height - imageSize.height) / 2
        return .init(x: imageX, y: imageY)
    }

    private func previewInsets(pattern: CropPattern, imageSize: CGSize, offset: CGPoint) -> UIEdgeInsets {
        let topOffset = pattern.previewRect.minY - max(offset.y, 0) + overlayView.clipBorderInset
        let bottomOffset = (offset.y > 0 ? offset.y + imageSize.height : view.bounds.height) - pattern.previewRect.maxY + overlayView.clipBorderInset
        let leftOffset = pattern.previewRect.minX - max(offset.x, 0) + overlayView.clipBorderInset
        let rightOffset = (offset.x > 0 ? offset.x + imageSize.width : view.bounds.width) - pattern.previewRect.maxX + overlayView.clipBorderInset
        return .init(top: topOffset, left: leftOffset, bottom: bottomOffset, right: rightOffset)
    }

    private func requiredSize(insets: UIEdgeInsets, imageSize: CGSize, scale: CGFloat) -> CGSize {
        let requiredHeight = (max(imageSize.height, view.bounds.height) + (insets.top + insets.bottom)) / scale
        let requiredWidth = (max(imageSize.width, view.bounds.width) + (insets.left + insets.right)) / scale
        return .init(width: requiredWidth, height: requiredHeight)
    }

    private func additionalSize(insets: UIEdgeInsets, imageSize: CGSize, scale: CGFloat, requiredSize: CGSize) -> CGSize {
        let additionalHeight = requiredSize.height - imageSize.height - (insets.top + insets.bottom) / scale
        let additionalWidth = requiredSize.width - imageSize.width - (insets.left + insets.right) / scale
        return .init(width: additionalWidth, height: additionalHeight)
    }

    private func additionalSize() -> CGSize {
        let pattern = makeCropPattern()
        let imageSize = pointImageSize
        let scale = acceptibleScale()
        let scaledImageSize = self.scaledImageSize(imageSize: imageSize, scale: scale)
        let scaledImageOffset = imageOffset(imageSize: scaledImageSize)
        let insets = self.previewInsets(pattern: pattern, imageSize: scaledImageSize, offset: scaledImageOffset)
        let requiredSize = self.requiredSize(insets: insets, imageSize: scaledImageSize, scale: scale)
        let additionalSize = self.additionalSize(insets: insets, imageSize: imageSize, scale: scale, requiredSize: requiredSize)
        return additionalSize
    }

    private func restoreScrolling() {
        guard abs(scrollView.zoomScale - scrollView.minimumZoomScale) < 1e-2 else {
            return
        }
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        updateScrollViewContent(withContentOffset: true)
    }

    private func imageScale(in bounds: CGRect) -> CGFloat {
        let size = pointImageSize
        let widthScale = bounds.width / size.width
        let heightScale = bounds.height / size.height
        return max(widthScale, heightScale)
    }

    private func generateHapticFeedback() {
        feedbackGenerator?.impactOccurred()
    }
}

extension CropperViewController: UIScrollViewDelegate {

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageWrapperView
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        overlayView.showsGridLines = true
        updateScrollViewContent(withContentOffset: false)
    }

    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        overlayView.showsGridLines = false
        generateHapticFeedback()
        UIView.animate(withDuration: 0.1, animations: {
            self.restoreScrolling()
        })
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        overlayView.showsGridLines = true
        generateHapticFeedback()
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        overlayView.showsGridLines = false
        generateHapticFeedback()
    }
}
