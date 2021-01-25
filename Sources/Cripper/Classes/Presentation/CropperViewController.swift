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

    public var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    typealias Cell = CropCell

    private let cellType = Cell.self
    private let reuseId = String(describing: Cell.self)

    private var cripper: Cropper = .init()
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
        return cripper.pointSize(of: image)
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

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.backgroundColor = .clear
        collectionView.register(cellType, forCellWithReuseIdentifier: reuseId)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
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

    public private(set) lazy var acceptBarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()

    public private(set) lazy var shapeBarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()

    public private(set) lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✓", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24)
        button.addTarget(self, action: #selector(acceptButtonPressed), for: .touchUpInside)
        return button
    }()

    public private(set) lazy var declineButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✗", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24)
        button.addTarget(self, action: #selector(declineButtonPressed), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.addSubview(imageWrapperView)
        imageWrapperView.addSubview(imageView)
        view.addSubview(overlayView)
        view.addSubview(acceptBarView)
        view.addSubview(shapeBarView)
        shapeBarView.addSubview(collectionView)
        acceptBarView.addSubview(acceptButton)
        acceptBarView.addSubview(declineButton)
        view.backgroundColor = .black
        updateCropOverlay()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        overlayView.frame = view.bounds
        scrollView.frame = view.bounds
        let pattern = makeCropPattern()
        let scale = cripper.scale(for: pointImageSize, in: pattern.previewRect)
        scrollView.maximumZoomScale = maximumScale
        scrollView.minimumZoomScale = scale
        scrollView.contentInset = .zero
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        updateScrollViewContent(withContentOffset: false)
        updateCropOverlay()
        acceptBarView.frame = .init(x: 0, y: 0,
                                    width: view.bounds.width,
                                    height: 56 + view.safeAreaInsets.top)
        let acceptButtonFitSize = acceptButton.sizeThatFits(acceptBarView.bounds.size)
        let declineButtonFitSize = declineButton.sizeThatFits(declineButton.bounds.size)
        let acceptButtonWidth = acceptButtonFitSize.width + 32
        declineButton.frame = .init(x: 0, y: view.safeAreaInsets.top,
                                    width: declineButtonFitSize.width + 32, height: 56)
        acceptButton.frame = .init(x: view.bounds.width - acceptButtonWidth,
                                   y: view.safeAreaInsets.top,
                                   width: acceptButtonWidth,
                                   height: 56)

        let shapeBarViewHeight: CGFloat = 100
        shapeBarView.frame = .init(x: 0,
                                   y: view.frame.height - shapeBarViewHeight - view.safeAreaInsets.bottom,
                                   width: view.bounds.width,
                                   height: shapeBarViewHeight + view.safeAreaInsets.bottom)
        collectionView.frame = .init(x: 0, y: 0,
                                     width: shapeBarView.bounds.width, height: shapeBarViewHeight)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
            self.updateScrollViewContent(withContentOffset: true)
        }
    }

    // MARK: - Actions

    @objc private func acceptButtonPressed() {
        dismiss(animated: false, completion: nil)
        guard let image = imageView.image else {
            completionHandler?(nil)
            return
        }
        completionHandler?(cripper.crop(image: image, with: makeCropPattern()))
    }

    @objc private func declineButtonPressed() {
        dismiss(animated: false, completion: nil)
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
        if cropOptions.count > 1 {
            shapeBarView.isHidden = false
            collectionView.reloadData()
        }
        else {
            shapeBarView.isHidden = true
        }
        view.setNeedsDisplay()
    }

    private func updateScaling() {
        let pattern = makeCropPattern()
        let scale = cripper.scale(for: pointImageSize, in: pattern.previewRect)
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
        imageView.frame = .init(origin: .init(x: insets.left / scale + additionalSize.width / 2,
                                              y: insets.top / scale + additionalSize.height / 2),
                               size: imageSize)
        imageWrapperView.center = .init(x: scrollView.contentSize.width * 0.5 + offsetX,
                                       y: scrollView.contentSize.height * 0.5 + offsetY)

        if withContentOffset {
           scrollView.setContentOffset(.init(x: insets.left,
                                             y: insets.top),
                                       animated: false)
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
        let topOffset = pattern.previewRect.minY - max(offset.y, 0)
        let bottomOffset = (offset.y > 0 ? offset.y + imageSize.height : view.bounds.height) - pattern.previewRect.maxY
        let leftOffset = pattern.previewRect.minX - max(offset.x, 0)
        let rightOffset = (offset.x > 0 ? offset.x + imageSize.width : view.bounds.width) - pattern.previewRect.maxX
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
}

extension CropperViewController: UIScrollViewDelegate {

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageWrapperView
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateScrollViewContent(withContentOffset: false)
    }

    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        UIView.animate(withDuration: 0.1, animations: {
            self.restoreScrolling()
        })
    }
}

extension CropperViewController: UICollectionViewDelegate {

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cropPatternBuilder = cropOptions[indexPath.row].cropPatternBuilder
    }
}

extension CropperViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cropOptions.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as? Cell else {
            return UICollectionViewCell()
        }
        let option = cropOptions[indexPath.row]
        cell.imageView.image = option.image
        cell.titleLabel.text = option.title
        return cell
    }
}
