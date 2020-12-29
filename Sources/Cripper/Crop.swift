//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

public struct Crop {
    var rect: CGRect
    var path: CGPath
}

public protocol CropBuilder {
    func makeCrop(in bounds: CGRect) -> Crop
}

extension CropBuilder {
    func makeRect(with aspect: CGFloat, in bounds: CGRect) -> CGRect {
        let minSide = min(bounds.height, bounds.width)
        if aspect < 1 {
            let height = minSide
            let width = height * aspect
            let x = (bounds.width - width) / 2
            let y = (bounds.height - height) / 2
            return .init(x: x, y: y, width: width, height: height)
        }
        else {
            let width = minSide
            let height = width / aspect
            let x = (bounds.width - width) / 2
            let y = (bounds.height - height) / 2
            return .init(x: x, y: y, width: width, height: height)
        }
    }
}

public final class AspectCropBuilder: CropBuilder {
    let aspect: CGFloat

    init(aspect: CGFloat) {
        self.aspect = aspect
    }

    public func makeCrop(in bounds: CGRect) -> Crop {
        let rect = makeRect(with: aspect, in: bounds)
        let path = UIBezierPath(rect: rect)
        return .init(rect: rect, path: path.cgPath)
    }
}

public enum CropBuilders {
    case square
    case rect(aspect: CGFloat)
    case custom(_ builder: CropBuilder)

    var builder: CropBuilder {
        switch self {
        case .square:
            return AspectCropBuilder(aspect: 1)
        case let .rect(aspect):
            return AspectCropBuilder(aspect: aspect)
        case let .custom(builder):
            return builder
        }
    }
}
