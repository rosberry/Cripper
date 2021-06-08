import XCTest
@testable import Cripper

final class CropperViewControllerTests: XCTestCase {
    var cropper: ViewControllerCropper!

    override func setUp() {
        super.setUp()
        cropper = .init(name: "image.png", test: self)
    }

    // MARK: - Logic

    func testPositiveRectCrop() {
        let rect = CGRect(x: 257, y: 167, width: 287, height: 269)
        let missingImage = rectCrop(bundledImage(named: "image_257_167_287_269.png"),
                                    rect: .init(origin: .zero, size: rect.size))
        let result = cropper.crop(rect: rect, shape: .rect(aspectRatio: rect.width / rect.height))
        guard case let .normal(resultImage) = result else {
            return XCTAssert(false, "Could not fetch result image")
        }
        XCTAssert(compare(resultImage, missingImage, accuracy: 500))
    }

    func testPositiveRectWithInsetCrop() {
        let rect = CGRect(x: 257, y: 167, width: 287, height: 269)
        let missingImage = rectCrop(bundledImage(named: "image_257_167_287_269.png"),
                                    rect: .init(origin: .zero, size: rect.size))
        let inset: CGFloat = 10
        let result = cropper.crop(rect: rect,
                                  shape: .rect(aspectRatio: rect.width / rect.height),
                                  inset: inset)

        guard case let .normal(resultImage) = result else {
            return XCTAssert(false, "Could not fetch result image")
        }
        XCTAssert(cropper.viewController.clipBorderInset == inset)
        XCTAssert(compare(resultImage, missingImage, accuracy: 1000))
    }

    func testEllipseRectCrop() {
        let rect = CGRect(x: 257, y: 167, width: 287, height: 269)
        let missingImage = rectCrop(bundledImage(named: "ellipse_257_167_287_269.png"),
                                    rect: .init(origin: .zero, size: rect.size))

        let result = cropper.crop(rect: rect, shape: .ellipse(aspectRatio: rect.width / rect.height), mode: .path)
        guard case let .normal(resultImage) = result else {
            return XCTAssert(false, "Could not fetch result image")
        }
        XCTAssertTrue(compare(resultImage, missingImage, accuracy: 1000))
    }

    // MARK: - UI

    func testZeroGridInset() {
        performGridInsetTest(inset: 0)
    }

    func testNonZeroGridInset() {
        performGridInsetTest(inset: 10)
    }

    func testUnitClipBorderWidth() {
        performClipBorderWidthTest(width: 1)
    }

    func testLargeClipBorderWidth() {
        performClipBorderWidthTest(width: 10)
    }

    func testWhiteClipBorderColor() {
        performClipBorderColorTest(color: .white)
    }

    func testRedClipBorderColor() {
        performClipBorderColorTest(color: .red)
    }

    func testBlackOverlayColor() {
        performOverlayColorTest(color: .black)
    }

    func testRedOverlayColor() {
        performOverlayColorTest(color: .red)
    }

    func testBlackBackColor() {
        performBackColorTest(color: .black)
    }

    func testRedBackColor() {
        performBackColorTest(color: .red)
    }

    func testZeroBlurAlpha() {
        performBlurAlphaTest(alpha: 0)
    }

    func testNonZeroBlurAlpha() {
        performBlurAlphaTest(alpha: 0.5)
    }

    func testZeroBlurRadius() {
        performBlurRadiusTest(radius: 0)
    }

    func testNonZeroBlurRadius() {
        performBlurRadiusTest(radius: 10)
    }

    // MARK: - Private

    private func performGridInsetTest(inset: CGFloat) {
        wait(for: [cropper.expectation], timeout: 10)
        let aspectRatio: CGFloat = 287 / 269
        cropper.viewController.clipBorderInset = inset
        cropper.viewController.shape = .rect(aspectRatio: aspectRatio)
        let resultFrame = cropper.viewController.overlayView.gridView.frame
        let missingFrame = missingGrdidFrame(inset: inset, aspectRatio: aspectRatio)
        XCTAssertTrue(resultFrame == missingFrame)
    }

    private func performClipBorderWidthTest(width: CGFloat) {
        wait(for: [cropper.expectation], timeout: 10)
        cropper.viewController.clipBorderWidth = width
        XCTAssertTrue(cropper.viewController.clipBorderWidth == width)
        XCTAssertTrue(cropper.viewController.overlayView.clipBorderWidth == width)
        XCTAssertTrue(cropper.viewController.overlayView.gridView.clipBorderWidth == width)
    }

    private func performClipBorderColorTest(color: UIColor) {
        wait(for: [cropper.expectation], timeout: 10)
        cropper.viewController.clipBorderColor = color
        XCTAssertTrue(cropper.viewController.clipBorderColor == color)
        XCTAssertTrue(cropper.viewController.overlayView.clipBorderColor == color)
        XCTAssertTrue(cropper.viewController.overlayView.gridView.clipBorderColor == color)
    }

    private func performOverlayColorTest(color: UIColor) {
        wait(for: [cropper.expectation], timeout: 10)
        cropper.viewController.overlayColor = color
        XCTAssertTrue(cropper.viewController.overlayColor == color)
        XCTAssertTrue(cropper.viewController.overlayView.overlayColor == color)
    }

    private func performBackColorTest(color: UIColor) {
        wait(for: [cropper.expectation], timeout: 10)
        cropper.viewController.backColor = color
        XCTAssertTrue(cropper.viewController.backColor == color)
        XCTAssertTrue(cropper.viewController.view.backgroundColor == color)
    }

    private func performBlurAlphaTest(alpha: CGFloat) {
        wait(for: [cropper.expectation], timeout: 10)
        cropper.viewController.blurAlpha = alpha
        XCTAssertTrue(cropper.viewController.blurAlpha == alpha)
        XCTAssertTrue(cropper.viewController.overlayView.blurAlpha == alpha)
        XCTAssertTrue(cropper.viewController.overlayView.blurView?.blurAlpha == alpha)
    }

    private func performBlurRadiusTest(radius: CGFloat) {
        wait(for: [cropper.expectation], timeout: 10)
        cropper.viewController.blurRadius = radius
        XCTAssertTrue(cropper.viewController.blurRadius == radius)
        XCTAssertTrue(cropper.viewController.overlayView.blurRadius == radius)
        XCTAssertTrue(cropper.viewController.overlayView.blurView?.blurRadius == radius)
    }

    func missingGrdidFrame(inset: CGFloat, aspectRatio: CGFloat) -> CGRect {
        let bounds = cropper.viewController.view.bounds
        let width = bounds.width - 2 * inset
        let height = bounds.width / aspectRatio - 2 * inset
        return CGRect(x: inset, y: (bounds.height - height) / 2, width: width, height: height)
    }
}
