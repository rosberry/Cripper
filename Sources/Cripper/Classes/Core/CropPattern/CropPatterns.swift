//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

/// Presets of the most used crop patterns
public enum CropPatterns {
    /// Rectangular crop pattern builder with unit aspect ratio
    case square
    /// Rectangular crop pattern builder with specified aspect ratio
    case rect(aspectRatio: CGFloat)
    /// Ellipsoidal crop pattern builder with unit aspect ratio
    case circle
    /// Ellipsoidal crop pattern builder with specified aspect ratio
    case ellipse(aspectRatio: CGFloat)
    /// Custom crop pattern builder
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
