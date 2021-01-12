//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

public struct CropPattern {
    var rect: CGRect
    var path: CGPath
    var translation: CGPoint = .zero
    var scale: CGFloat = 1
}

public protocol CropPatternBuilder {
    func makeCropPattern(in bounds: CGRect) -> CropPattern
    func makeIdentityRect() -> CGRect
    func makeRect(with aspectRatio: CGFloat, in bounds: CGRect) -> CGRect
}

public extension CropPatternBuilder {

    func makeIdentityRect() -> CGRect {
        .init(x: 0, y: 0, width: 1, height: 1)
    }

    func makeRect(with aspectRatio: CGFloat, in bounds: CGRect) -> CGRect {
        let minSide = min(bounds.height, bounds.width)
        if aspectRatio < 1 {
            let height = minSide
            let width = height * aspectRatio
            let x = (bounds.width - width) / 2
            let y = (bounds.height - height) / 2
            return .init(x: x, y: y, width: width, height: height)
        }
        else {
            let width = minSide
            let height = width / aspectRatio
            let x = (bounds.width - width) / 2
            let y = (bounds.height - height) / 2
            return .init(x: x, y: y, width: width, height: height)
        }
    }
}

public class AspectRatioCropPatternBuilder: CropPatternBuilder {
    let aspectRatio: CGFloat

    init(aspectRatio: CGFloat) {
        self.aspectRatio = aspectRatio
    }

    public func makeCropPattern(in bounds: CGRect) -> CropPattern {
        return .init(rect: makeRect(with: aspectRatio, in: bounds),
                     path: makePath())
    }

    func makePath() -> CGPath {
        CGPath(rect: makeIdentityRect(), transform: nil)
    }
}

public final class EllipsePatternBuilder: AspectRatioCropPatternBuilder {
    override func makePath() -> CGPath {
        CGPath(ellipseIn: makeIdentityRect(), transform: nil)
    }
}

public enum CropPatterBuilders {
    case square
    case rect(aspectRatio: CGFloat)
    case circle
    case ellipse(aspectRatio: CGFloat)
    case custom(cropPatternBuilder: CropPatternBuilder)

    var cropPatternBuilder: CropPatternBuilder {
        switch self {
        case .square:
            return AspectRatioCropPatternBuilder(aspectRatio: 1)
        case .rect(let aspectRatio):
            return AspectRatioCropPatternBuilder(aspectRatio: aspectRatio)
        case .circle:
            return EllipsePatternBuilder(aspectRatio: 1)
        case .ellipse(let aspectRatio):
            return EllipsePatternBuilder(aspectRatio: aspectRatio)
        case .custom(let cropPatternBuilder):
            return cropPatternBuilder
        }
    }
}
