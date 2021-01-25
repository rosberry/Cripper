//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

public class AspectRatioCropPatternBuilder: CropPatternBuilder {
    let aspectRatio: CGFloat

    init(aspectRatio: CGFloat) {
        self.aspectRatio = aspectRatio
    }

    public func makeCropPattern(in bounds: CGRect) -> CropPattern {
        let previewRect = makeRect(with: aspectRatio, in: bounds)
        return .init(previewRect: previewRect,
                     path: makePath(with: previewRect.size))
    }

    func makePath(with size: CGSize) -> CGPath {
        CGPath(rect: .init(origin: .zero, size: size), transform: nil)
    }
}
