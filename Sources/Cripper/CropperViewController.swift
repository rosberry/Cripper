//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

public final class CropperViewController: UIViewController {

    public var cropBuilder: CropBuilder = CropBuilders.square.builder {
        didSet {
            update()
        }
    }

    var transform: CGAffineTransform = .identity
    var currentTransform: CGAffineTransform = .identity
    var maximumScale: CGFloat = 5
    var scale: CGFloat = 1

    var pointImageSize: CGSize {
        guard let size = imageView.image?.size else {
            return .zero
        }
        let scale = UIScreen.main.scale
        return .init(width: size.width / scale, height: size.height / scale)
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    // MARK: - GestureRecognizers


    // MARK: - Subviews

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.insetsLayoutMarginsFromSafeArea = false
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()

    public private(set) lazy var imageView: UIImageView = .init()
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

    public private(set) lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Use Photo", for: .normal)
        button.addTarget(self, action: #selector(acceptButtonPressed), for: .touchUpInside)
        return button
    }()

    public private(set) lazy var declineButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retake", for: .normal)
        button.addTarget(self, action: #selector(declineButtonPressed), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    public convenience init(image: UIImage) {
        self.init(nibName: nil, bundle: nil)
        imageView.image = image
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.addSubview(imageWrapperView)
        imageWrapperView.addSubview(imageView)
        scrollView.delegate = self
        view.addSubview(overlayView)
        view.addSubview(acceptBarView)
        acceptBarView.addSubview(acceptButton)
        acceptBarView.addSubview(declineButton)
        imageView.contentMode = .scaleAspectFit
        view.backgroundColor = .black
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        overlayView.frame = view.bounds
        scrollView.frame = view.bounds
        let imageSize = pointImageSize
        let widthScale = view.bounds.width / imageSize.width
        let heightScale = view.bounds.height / imageSize.height
        scale = min(widthScale, heightScale)
        scrollView.maximumZoomScale = maximumScale
        scrollView.minimumZoomScale = scale
        scrollView.contentInset = .zero
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        updateScrollViewContent(withContentOffset: true)
        update()
        let acceptBarHeight = 100 + view.safeAreaInsets.bottom
        acceptBarView.frame = .init(x: 0, y: view.bounds.height - acceptBarHeight,
                                    width: view.bounds.width, height: acceptBarHeight)
        let acceptButtonFitSize = acceptButton.sizeThatFits(acceptBarView.bounds.size)
        let declineButtonFitSize = declineButton.sizeThatFits(declineButton.bounds.size)
        let declineButtonWidth = declineButtonFitSize.width + 32
        acceptButton.frame = .init(origin: .zero, size: .init(width: acceptButtonFitSize.width + 32, height: 56))
        declineButton.frame = .init(x: view.bounds.width - declineButtonWidth, y: 0, width: declineButtonWidth, height: 56)
    }

    // MARK: - Actions

    @objc private func acceptButtonPressed() {

    }

    @objc private func declineButtonPressed() {

    }

    // MARK: - Private

    private func update() {
        overlayView.cropBuilder = cropBuilder
        view.setNeedsDisplay()
    }
}

extension CropperViewController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageWrapperView
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateScrollViewContent(withContentOffset: false)
    }

    func updateScrollViewContent(withContentOffset: Bool = false) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0.0)
        let scale = scrollView.zoomScale
        let imageSize = pointImageSize
        let crop = cropBuilder.makeCrop(in: view.bounds)
        let imageWidth = imageSize.width * scale
        let imageHeight = imageSize.height * scale
        let imageX = (view.bounds.width - imageWidth) / 2
        let imageY = (view.bounds.height - imageHeight) / 2
        let topOffset = crop.rect.minY - imageY
        let bottomOffset = (imageY + imageHeight) - crop.rect.maxY
        let leftOffset = crop.rect.minX - imageX
        let rightOffset = (imageX + imageWidth) - crop.rect.maxX
        let requiredHeight = (max(imageHeight, view.bounds.height) + (topOffset + bottomOffset)) / scale
        let requiredWidth = (max(imageWidth, view.bounds.width) + (leftOffset + rightOffset)) / scale
        let additionalHeight = requiredHeight - imageSize.height - (topOffset + bottomOffset) / scale
        let additionalWidth = requiredWidth - imageSize.width - (leftOffset + rightOffset) / scale
        imageWrapperView.bounds = .init(x: 0, y: 0,
                                        width: requiredWidth,
                                        height: requiredHeight)
        scrollView.contentSize = .init(width: requiredWidth * scale,
                                       height: requiredHeight * scale)
        imageView.frame = .init(origin: .init(x: leftOffset / scale + additionalWidth / 2,
                                              y: topOffset / scale + additionalHeight / 2),
                                size: imageSize)
        imageWrapperView.center = .init(x: scrollView.contentSize.width * 0.5 + offsetX,
                                        y: scrollView.contentSize.height * 0.5 + offsetY)
        if withContentOffset {
            scrollView.setContentOffset(.init(x: leftOffset,
                                              y: topOffset),
                                        animated: false)
        }
    }
}
