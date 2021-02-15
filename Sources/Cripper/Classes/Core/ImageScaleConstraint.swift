//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import CoreGraphics

public enum ImageScaleConstraint {
    case less(CGFloat)
    case great(CGFloat)
    case `default`

    func distance(to scale: CGFloat) -> CGFloat {
        switch self {
        case let .great(value):
            return abs(value - scale)
        case let .less(value):
            return abs(value - scale)
        default:
            return CGFloat.greatestFiniteMagnitude
        }
    }
}

extension ImageScaleConstraint: Hashable {

}

extension Array where Element == ImageScaleConstraint {
    var mostLess: ImageScaleConstraint {
        reduce(.default) { result, constraint -> ImageScaleConstraint in
            switch (result, constraint) {
            case let (.less(resultValue), .less(constraintValue)):
                return constraintValue < resultValue ? constraint : result
            case (.default, .less):
                return constraint
            default:
                return result
            }
        }
    }

    var mostGreate:  ImageScaleConstraint {
        reduce(.default) { result, constraint -> ImageScaleConstraint in
            switch (result, constraint) {
            case let (.great(resultValue), .great(constraintValue)):
                return constraintValue > resultValue ? constraint : result
            case (.default, .great):
                return constraint
            default:
                return result
            }
        }
    }
}
