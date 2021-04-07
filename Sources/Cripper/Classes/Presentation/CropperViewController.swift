//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

/// `CropperViewController` is reusable UI/UX component that allows to apply crop using provided image
public final class CropperViewController: UIViewController {

    /// Crop option that specifies `CropPattern`
    public var cropOption: CropOption = .square {
        didSet {
            cropPatternBuilder = cropOption.cropPatternBuilder
        }
    }

    /// Maximum allowed scale that should be applied
    public var maximumScale: CGFloat = 5

    /// Crop pattern mode
    public var mode: CropPattern.Mode = .rect

    /// Image backdrop color
    public var backColor: UIColor = .black {
        didSet {
            view.backgroundColor = backColor
        }
    }

    /// Image overlay color
    public var overlayColor: UIColor {
        get {
            overlayView.overlayColor
        }
        set {
            overlayView.overlayColor = newValue
        }
    }

    /// Color of crop area borders
    public var clipBorderColor: UIColor {
        get {
            overlayView.clipBorderColor
        }
        set {
            overlayView.clipBorderColor = newValue
        }
    }

    /// Inset of crop area from screen bounds
    public var clipBorderInset: CGFloat {
        get {
            overlayView.clipBorderInset
        }
        set {
            overlayView.clipBorderInset = newValue
        }
    }

    /// Width of crop area borders
    public var clipBorderWidth: CGFloat {
        get {
            overlayView.clipBorderWidth
        }
        set {
            overlayView.clipBorderWidth = newValue
        }
    }

    /// Opacity of blur effect othside crop area
    public var blurAlpha: CGFloat {
        get {
            overlayView.blurAlpha
        }
        set {
            overlayView.blurAlpha = newValue
        }
    }

    /// Radius of blur effect othside crop area
    public var blurRadius: CGFloat {
        get {
            overlayView.blurRadius
        }
        set {
            overlayView.blurRadius = newValue
        }
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .portrait
    }

    private var cripper: Cropper = .init()
    private var feedbackGenerator: UIImpactFeedbackGenerator?

    private var cropPatternBuilder: CropPatternBuilder = CropOption.square.cropPatternBuilder {
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
        let width = view.bounds.width - 2 * overlayView.clipBorderInset
        let height = width / aspectRatio
        return .init(width: width, height: height)
    }

    private var isModifying: Bool {
        overlayView.showsGridLines
    }

    /// `ImageProvider` allows to define a way how an image for a given scale can be fetched
    public var imageProvider: ImageProvider

    /// Initializes `CropperViewController` with the same image for all possible scales
    /// - Parameters:
    ///   - image: The image the will be used for all possible scales
    public convenience init(image: UIImage) {
        self.init(imageProvider: DefaultImageProvider(image: image))
    }

    /// Initializes `CropperViewController` with contcrete images assosiated with scale constraints
    /// - Parameters:
    ///   - images: Dictionary that associates scale constraints with contcrete images 
    public convenience init(images: [ImageScaleConstraint: UIImage]) {
        self.init(imageProvider: DefaultImageProvider(images: images))
    }

    /// Initializes `CropperViewController` with `ImageProvider`
    /// - Parameters:
    ///   - imageProvider: The imageProvider the will be used to fetch an image for a given scale
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

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var imageWrapperView: UIView = .init()

    private lazy var overlayView: CropOverlayView = {
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

    /// Apply current crop pattern
    public func makeCroppResult() -> CropResult  {
        guard let image = imageView.image,
              let resultImage = cripper.crop(image: image, with: makeCropPattern(image: image)) else {
            return .undefined
        }

        if isModifying {
            return .forced(resultImage)
        }
        return .normal(resultImage)
    }

    // MARK: - Private

    private func makeCropPattern(image: UIImage? = nil) -> CropPattern {
        let rect = view.bounds
        var pattern = cropPatternBuilder.makeCropPattern(in: rect)
        if let image = image {
            let inset = overlayView.clipBorderInset
            let pointImageSize = self.pointImageSize
            let imageSide = min(image.size.width, image.size.height)
            let pointImageSide = min(pointImageSize.width, pointImageSize.height)
            let imageScale = imageSide / pointImageSide
            pattern.translation = scrollView.contentOffset
            let path = UIBezierPath(cgPath: pattern.path)
            path.apply(inset: inset)
            pattern.path = path.cgPath
            pattern.scale = imageScale / scrollView.zoomScale
        }
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
        min(max(scrollView.zoomScale, scrollView.minimumZoomScale), scrollView.maximumZoomScale)
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
        let inset = overlayView.clipBorderInset
        let bounds = bounds.insetBy(dx: inset, dy: inset)
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
