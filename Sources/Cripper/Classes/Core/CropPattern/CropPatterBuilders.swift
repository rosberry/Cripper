//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

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
