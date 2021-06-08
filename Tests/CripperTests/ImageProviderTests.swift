//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import XCTest
@testable import Cripper

final class ImageProviderTests: XCTestCase {
    var expectation: XCTestExpectation!
    var viewController: CropperViewController!
    var largeImage: UIImage!
    var normalImage: UIImage!
    var smallImage: UIImage!

    override func setUp() {
        super.setUp()
        let largeImage = bundledImage(named: "image.png")
        let smallImage = bundledImage(named: "image_-100_-100_287_269.png")
        let normalImage = bundledImage(named: "image_257_167_287_269.png")
        viewController = .init(images: [.less(2): smallImage, .great(3): largeImage, .default: normalImage])
        self.largeImage = largeImage
        self.smallImage = smallImage
        self.normalImage = normalImage
        let window = UIWindow()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        expectation = expectation(for: NSPredicate(block: { imageView, _ in
            guard let imageView = imageView as? UIImageView,
                  imageView.image != nil else {
                return false
            }
            return true
        }), evaluatedWith: viewController.imageView, handler: nil)
    }

    func testSmalImage() {
        performImageTest(image: smallImage, scale: 1)
    }

    func testNormalImage() {
        performImageTest(image: normalImage, scale: 2.5)
    }

    func testLargeImage() {
        performImageTest(image: largeImage, scale: 4)
    }

    // MARK: - Private

    private func performImageTest(image: UIImage, scale: CGFloat) {
        wait(for: [expectation], timeout: 10)
        viewController.scrollView.zoomScale = scale
        viewController.updateScrollViewContent()
        XCTAssert(image == viewController.imageView.image)
    }
}
