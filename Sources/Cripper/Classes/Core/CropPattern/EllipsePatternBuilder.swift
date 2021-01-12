//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

public final class EllipsePatternBuilder: AspectRatioCropPatternBuilder {
    override func makePath() -> CGPath {
        CGPath(ellipseIn: makeIdentityRect(), transform: nil)
    }
}
