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

    public var maximumScale: CGFloat = 5
    public var completionHandler: ((UIImage?) -> Void)?

    var scale: CGFloat = 1

    var cripper: Cripper = .init()

    var pointImageSize: CGSize {
        guard let image = imageView.image else {
            return .zero
        }
        return cripper.pointSize(of: image)
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
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(acceptButtonPressed), for: .touchUpInside)
        return button
    }()

    public private(set) lazy var declineButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retake", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(declineButtonPressed), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    public convenience init(image: UIImage, completionHandler: @escaping ((UIImage?) -> Void)) {
        self.init(nibName: nil, bundle: nil)
        self.completionHandler = completionHandler
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

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        overlayView.frame = view.bounds
        scrollView.frame = view.bounds
        scale = cripper.scale(for: pointImageSize, in: view.bounds)
        scrollView.maximumZoomScale = maximumScale
        scrollView.minimumZoomScale = scale
        scrollView.contentInset = .zero
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        updateScrollViewContent(withContentOffset: false)
        update()
        let acceptBarHeight = 100 + view.safeAreaInsets.bottom
        acceptBarView.frame = .init(x: 0, y: view.bounds.height - acceptBarHeight,
                                    width: view.bounds.width, height: acceptBarHeight)
        let acceptButtonFitSize = acceptButton.sizeThatFits(acceptBarView.bounds.size)
        let declineButtonFitSize = declineButton.sizeThatFits(declineButton.bounds.size)
        let acceptButtonWidth = acceptButtonFitSize.width + 32
        declineButton.frame = .init(origin: .zero, size: .init(width: declineButtonFitSize.width + 32,
                                                               height: 56))
        acceptButton.frame = .init(x: view.bounds.width - acceptButtonWidth, y: 0, width: acceptButtonWidth, height: 56)
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
        var crop = cropBuilder.makeCrop(in: view.bounds)
        crop.translation = .init(x: scrollView.contentOffset.x,
                                 y: scrollView.contentOffset.y)
        crop.scale = UIScreen.main.scale / scrollView.zoomScale
        completionHandler?(cripper.crop(image: image, with: crop, in: view.bounds))
    }

    @objc private func declineButtonPressed() {
        dismiss(animated: false, completion: nil)
    }

    // MARK: - Private

    private func update() {
        overlayView.cropBuilder = cropBuilder
        view.setNeedsDisplay()
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
        let topOffset = crop.rect.minY - max(imageY, 0)
        let bottomOffset = (imageY > 0 ? imageY + imageHeight : view.bounds.height) - crop.rect.maxY
        let leftOffset = crop.rect.minX - max(imageX, 0)
        let rightOffset = (imageX > 0 ? imageX + imageWidth : view.bounds.width) - crop.rect.maxX
        let requiredHeight = (max(imageHeight, view.bounds.height) + (topOffset + bottomOffset)) / scale
        let requiredWidth = (max(imageWidth, view.bounds.width) + (leftOffset + rightOffset)) / scale
        let additionalHeight = requiredHeight - imageSize.height - (topOffset + bottomOffset) / scale
        let additionalWidth = requiredWidth - imageSize.width - (leftOffset + rightOffset) / scale

        imageWrapperView.bounds = .init(x: 0, y: 0,
                                        width: requiredWidth,
                                        height: requiredHeight)
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

    func alignImageByCenter() {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0.0)
        let imageSize = pointImageSize
        imageWrapperView.bounds = .init(x: 0, y: 0,
                                        width: imageSize.width,
                                        height: imageSize.height)
        imageView.frame = .init(origin: .init(x: 0, y: 0), size: imageSize)
        imageWrapperView.center = .init(x: scrollView.contentSize.width * 0.5 + offsetX,
                                        y: scrollView.contentSize.height * 0.5 + offsetY)
    }
}
