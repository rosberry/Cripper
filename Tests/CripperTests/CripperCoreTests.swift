//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import XCTest
@testable import Cripper

final class CripperTests: XCTestCase {

    func testPositiveRectCrop() {
        let image = bundledImage(named: "image.png")
        let rect = CGRect(x: 257, y: 167, width: 287, height: 269)
        let croppedImage = rectCrop(image, rect: rect)
        let missingImage = rectCrop(bundledImage(named: "image_257_167_287_269.png"),
                                    rect: .init(origin: .zero, size: rect.size))
        XCTAssertTrue(compare(croppedImage, missingImage, accuracy: 0.01))
    }

    func testEllipseRectCrop() {
        let image = bundledImage(named: "image.png")
        let rect = CGRect(x: 257, y: 167, width: 287, height: 269)
        let croppedImage = ellipseCrop(image, rect: rect)
        let missingImage = rectCrop(bundledImage(named: "ellipse_257_167_287_269.png"),
                                    rect: .init(origin: .zero, size: rect.size))
        XCTAssertTrue(compare(croppedImage, missingImage, accuracy: 500))
    }

    func testPositivePatternRectCrop() {
        let image = bundledImage(named: "image.png")
        let rect = CGRect(x: 257, y: 167, width: 287, height: 269)
        let croppedImage = rectPatternCrop(image, rect: rect)
        let missingImage = rectCrop(bundledImage(named: "image_257_167_287_269.png"),
                                    rect: .init(origin: .zero, size: rect.size))
        XCTAssertTrue(compare(croppedImage, missingImage, accuracy: 0.01))
    }

    func testPositivePatternEllipseCrop() {
        let image = bundledImage(named: "image.png")
        let rect = CGRect(x: 257, y: 167, width: 287, height: 269)
        let croppedImage = ellipsePatternCrop(image, rect: rect, mode: .path)
        let missingImage = rectCrop(bundledImage(named: "ellipse_257_167_287_269.png"),
                                    rect: .init(origin: .zero, size: rect.size))
        XCTAssertTrue(compare(croppedImage, missingImage, accuracy: 500))
    }

    func testPositivePatternEllipsePreviewCrop() {
        let image = bundledImage(named: "image.png")
        let rect = CGRect(x: 257, y: 167, width: 287, height: 269)
        let croppedImage = ellipsePatternCrop(image, rect: rect)
        let missingImage = rectCrop(bundledImage(named: "image_257_167_287_269.png"),
                                    rect: .init(origin: .zero, size: rect.size))
        XCTAssertTrue(compare(croppedImage, missingImage, accuracy: 500))
    }

    func testNefativeTopLeftRectCrop() {
        let image = bundledImage(named: "image.png")
        let rect = CGRect(x: -100, y: -100, width: 287, height: 269)
        let croppedImage = rectCrop(image, rect: rect)
        let missingImage = rectCrop(bundledImage(named: "image_257_167_287_269.png"),
                                    rect: .init(origin: .zero, size: rect.size))
        XCTAssertFalse(compare(croppedImage, missingImage, accuracy: 0.01))
    }

    func testForceTopLeftRectCrop() {
        let image = bundledImage(named: "image.png")
        let rect = CGRect(x: -100, y: -100, width: 287, height: 269)
        let croppedImage = rectCrop(image, rect: rect)
        let missingImage = rectCrop(bundledImage(named: "image_-100_-100_287_269.png"),
                                    rect: .init(origin: .zero, size: rect.size))
        XCTAssertFalse(compare(croppedImage, missingImage, accuracy: 0.01))
    }
}
