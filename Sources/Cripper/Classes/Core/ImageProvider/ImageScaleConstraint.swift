//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import CoreGraphics

/// `ImageScaleConstraint` allows to specify a rule to use image for a given scale.
/// If a set of constraints satisfy for a given scale then it is using constraint with nearest threshold value
public enum ImageScaleConstraint {
    /// Triggered when scale is less then a given threshold value
    case less(CGFloat)
    /// Triggered when scale is less then a given threshold value
    case great(CGFloat)
    /// Thriggered when there are no other satisfying constraints
    case `default`

    /// Calculates a numberic mesure of satisfyng for a given scale
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

    /// Retrives a constraint with the most less threshold value
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

    /// Retrives a constraint with the most great threshold value
    var mostGreat: ImageScaleConstraint {
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
