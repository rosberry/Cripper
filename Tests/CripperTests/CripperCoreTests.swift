//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import XCTest
@testable import Cripper

final class CripperTests: XCTestCase {

    func testPositiveRectCrop() {
        let image = UIImage.bundledImage(named: "image.png")
        let rect = CGRect(x: 257, y: 167, width: 287, height: 269)
        let croppedImage = image.rectCrop(rect: rect)
        let missingImage = UIImage.bundledImage(named: "image_257_167_287_269.png").rectCrop(rect: .init(origin: .zero, size: rect.size))
        XCTAssertTrue(croppedImage.compare(missingImage, accuracy: 0.01))
    }

    func testEllipseRectCrop() {
        let image = UIImage.bundledImage(named: "image.png")
        let rect = CGRect(x: 257, y: 167, width: 287, height: 269)
        let croppedImage = image.ellipseCrop(rect: rect)
        let missingImage = UIImage.bundledImage(named: "ellipse_257_167_287_269.png").rectCrop(rect: .init(origin: .zero, size: rect.size))
        XCTAssertTrue(croppedImage.compare(missingImage, accuracy: 500))
    }

    func testPositivePatternRectCrop() {
        let image = UIImage.bundledImage(named: "image.png")
        let rect = CGRect(x: 257, y: 167, width: 287, height: 269)
        let croppedImage = image.rectPatternCrop(rect: rect)
        let missingImage = UIImage.bundledImage(named: "image_257_167_287_269.png").rectCrop(rect: .init(origin: .zero, size: rect.size))
        XCTAssertTrue(croppedImage.compare(missingImage, accuracy: 0.01))
    }

    func testPositivePatternEllipseCrop() {
        let image = UIImage.bundledImage(named: "image.png")
        let rect = CGRect(x: 257, y: 167, width: 287, height: 269)
        let croppedImage = image.ellipsePatternCrop(rect: rect, mode: .path)
        let missingImage = UIImage.bundledImage(named: "ellipse_257_167_287_269.png").rectCrop(rect: .init(origin: .zero, size: rect.size))
        XCTAssertTrue(croppedImage.compare(missingImage, accuracy: 500))
    }

    func testPositivePatternEllipsePreviewCrop() {
        let image = UIImage.bundledImage(named: "image.png")
        let rect = CGRect(x: 257, y: 167, width: 287, height: 269)
        let croppedImage = image.ellipsePatternCrop(rect: rect)
        let missingImage = UIImage.bundledImage(named: "image_257_167_287_269.png").rectCrop(rect: .init(origin: .zero, size: rect.size))
        XCTAssertTrue(croppedImage.compare(missingImage, accuracy: 500))
    }

    func testNefativeTopLeftRectCrop() {
        let image = UIImage.bundledImage(named: "image.png")
        let rect = CGRect(x: -100, y: -100, width: 287, height: 269)
        let croppedImage = image.rectCrop(rect: rect)
        let missingImage = UIImage.bundledImage(named: "image_257_167_287_269.png").rectCrop(rect: .init(origin: .zero, size: rect.size))
        XCTAssertFalse(croppedImage.compare(missingImage, accuracy: 0.01))
    }

    func testForceTopLeftRectCrop() {
        let image = UIImage.bundledImage(named: "image.png")
        let rect = CGRect(x: -100, y: -100, width: 287, height: 269)
        let croppedImage = image.rectCrop(rect: rect)
        let missingImage = UIImage.bundledImage(named: "image_-100_-100_287_269.png").rectCrop(rect: .init(origin: .zero, size: rect.size))
        XCTAssertFalse(croppedImage.compare(missingImage, accuracy: 0.01))
    }
}
