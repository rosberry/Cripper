import XCTest
@testable import Cripper

final class ViewControllerCropper {
    var expectation: XCTestExpectation
    var viewController: CropperViewController
    var sourceImage: UIImage
    var test: XCTestCase

    init(name: String, test: XCTestCase) {
        sourceImage = bundledImage(named: name)
        viewController = .init(image: sourceImage)
        self.test = test
        let window = UIWindow()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        expectation = test.expectation(for: NSPredicate(block: { imageView, _ in
            guard let imageView = imageView as? UIImageView,
                  imageView.image != nil else {
                return false
            }
            return true
        }), evaluatedWith: viewController.imageView, handler: nil)
    }

    func crop(rect: CGRect, shape: CropShape, mode: CropPattern.Mode = .rect, inset: CGFloat = 0) -> CropResult {
        test.wait(for: [expectation], timeout: 10)
        viewController.shape = shape
        viewController.clipBorderInset = inset
        viewController.mode = mode
        let pointImageSize = viewController.pointImageSize
        let imageSide = min(sourceImage.size.width, sourceImage.size.height)
        let pointImageSide = min(pointImageSize.width, pointImageSize.height)
        let imageScale = imageSide / pointImageSide
        let insetScale = (pointImageSize.width - 2 * inset) / pointImageSize.width
        let scale = viewController.view.bounds.width / rect.width * insetScale
        viewController.scrollView.zoomScale = imageScale * scale
        viewController.scrollView.contentOffset = .init(x: rect.minX * scale, y: rect.minY * scale)
        viewController.overlayView.showsGridLines = false
        return viewController.makeCroppResult()
    }
}
