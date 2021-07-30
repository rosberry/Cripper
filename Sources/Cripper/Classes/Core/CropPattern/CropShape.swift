//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

/// Presets of the most used crop shapes
public enum CropShape {
    /// Rectangular shape with unit aspect ratio
    case square
    /// Rectangular shape with specified aspect ratio
    case rect(aspectRatio: CGFloat)
    /// Ellipsoidal shape with unit aspect ratio
    case circle
    /// Ellipsoidal shape with specified aspect ratio
    case ellipse(aspectRatio: CGFloat)
    /// Custom shape that provides by `CropPatternBuilder`
    case custom(CropPatternBuilder)

    /// Returns `CropPatternBuilder` for preset
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
