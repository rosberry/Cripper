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
        return .init(rect: makeRect(with: aspectRatio, in: bounds),
                     path: makePath())
    }

    func makePath() -> CGPath {
        CGPath(rect: makeIdentityRect(), transform: nil)
    }
}
