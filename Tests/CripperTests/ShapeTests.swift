//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import XCTest
@testable import Cripper

final class ShapeTests: XCTestCase {

    private final class CustomEllipsePatternBuilder: CropPatternBuilder {

        let aspectRatio: CGFloat

        init(aspectRatio: CGFloat) {
            self.aspectRatio = aspectRatio
        }

        func makeCropPattern(in bounds: CGRect) -> CropPattern {
            let previewRect = makeRect(with: aspectRatio, in: bounds)
            let path = CGPath(ellipseIn: .init(origin: .zero, size: previewRect.size), transform: nil)
            return .init(previewRect: previewRect, path: path)
        }
    }

    func testSquire() {
        perfromRectTest(shape: .square)
    }

    func testCircle() {
        perfromEllipseTest(shape: .circle)
    }

    func testHorisontalRect() {
        let aspectRatio: CGFloat = 4.0 / 3
        perfromRectTest(shape: .rect(aspectRatio: aspectRatio), aspectRatio: aspectRatio)
    }

    func testVerticalRect() {
        let aspectRatio: CGFloat = 3.0 / 4
        perfromRectTest(shape: .rect(aspectRatio: aspectRatio), aspectRatio: aspectRatio)
    }

    func testHorisontalEllipse() {
        let aspectRatio: CGFloat = 4.0 / 3
        perfromEllipseTest(shape: .ellipse(aspectRatio: aspectRatio), aspectRatio: aspectRatio)
    }

    func testVerticalEllipse() {
        let aspectRatio: CGFloat = 3.0 / 4
        perfromEllipseTest(shape: .ellipse(aspectRatio: aspectRatio), aspectRatio: aspectRatio)
    }

    func testCustomShape() {
        let aspectRatio: CGFloat = 3.0 / 4
        perfromEllipseTest(shape: .custom(CustomEllipsePatternBuilder(aspectRatio: aspectRatio)),
                           aspectRatio: aspectRatio)
    }

    func testInvalidShape() {
        performShapeTest(shape: .square, shouldBeEqual: false) { rect in
            .init(ellipseIn: rect, transform: nil)
        }
    }

    // MARK: - Private

    func perfromRectTest(shape: CropShape, aspectRatio: CGFloat = 1) {
        performShapeTest(shape: shape, aspectRatio: aspectRatio) { rect in
            .init(rect: rect, transform: nil)
        }
    }

    func perfromEllipseTest(shape: CropShape, aspectRatio: CGFloat = 1) {
        performShapeTest(shape: shape, aspectRatio: aspectRatio) { rect in
            .init(ellipseIn: rect, transform: nil)
        }
    }

    func performShapeTest(shape: CropShape, aspectRatio: CGFloat = 1, shouldBeEqual: Bool = true, missingPathHandler: (CGRect) -> CGPath) {
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 800)
        let rect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.width / aspectRatio)
        let missingPath = missingPathHandler(rect)
        let path = shape.cropPatternBuilder.makeCropPattern(in: bounds).path
        let isEqual = path == missingPath
        XCTAssert(isEqual == shouldBeEqual)
    }
}
