//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

/// Implementation of `AspectRatioCropPatternBuilder` that allows to create ellipsoidal crop patterns with required aspect ratio
public final class EllipsePatternBuilder: AspectRatioCropPatternBuilder {

    /// Creates ellipsoidal shape path with provided size
    /// - Parameters:
    ///   - size: Size of creating shape path
    override func makePath(with size: CGSize) -> CGPath {
        CGPath(ellipseIn: .init(origin: .zero, size: size), transform: nil)
    }
}
