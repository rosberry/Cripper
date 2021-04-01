//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

public final class EllipsePatternBuilder: AspectRatioCropPatternBuilder {
    override func makePath(with size: CGSize) -> CGPath {
        CGPath(ellipseIn: .init(origin: .zero, size: size), transform: nil)
    }
}
