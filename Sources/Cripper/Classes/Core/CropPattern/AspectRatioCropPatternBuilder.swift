//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

/// Implementation of `CropPatternBuilder` that allows to create rectangular crop patterns with required aspect ratio
public class AspectRatioCropPatternBuilder: CropPatternBuilder {

    /// Aspect ratio that will be used to create rectangular crop shape
    let aspectRatio: CGFloat

    /// Initializer that allows to use the specified aspect spect ratio that will be used to create rectangular crop shape
    /// - Parameters:
    ///   - aspectRatio: Aspect ratio that will be used to create rectangular crop shape
    init(aspectRatio: CGFloat) {
        self.aspectRatio = aspectRatio
    }

    /// Implementation of `makeCropPattern` that creates rectangular crop pattern placed in provided bounds
    /// - Parameters:
    ///   - bounds: Bounding rect where crop shape should be placed  (for example, screen bounds)
    public func makeCropPattern(in bounds: CGRect) -> CropPattern {
        let previewRect = makeRect(with: aspectRatio, in: bounds)
        return .init(previewRect: previewRect,
                     path: makePath(with: previewRect.size))
    }

    /// Creates  rectangular shape path with provided size
    /// - Parameters:
    ///   - size: Size of creating shape path
    func makePath(with size: CGSize) -> CGPath {
        CGPath(rect: .init(origin: .zero, size: size), transform: nil)
    }
}
