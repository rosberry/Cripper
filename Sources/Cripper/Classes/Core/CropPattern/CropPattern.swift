//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

/// Pattern that should be used to crop image
public struct CropPattern {

    /// Mode to use crop pattern
    public enum Mode {
        /// Use bounding rect of pattern shape
        case rect
        /// Use pattern shape
        case path
    }

    /// Returns a rect where pattern shape should be drawn
    var previewRect: CGRect

    /// Returns a path that is defining pattern shape
    var path: CGPath

    /// Specifies an image translation to apply crop
    var translation: CGPoint = .zero

    /// Specifies an image scale to apply crop
    var scale: CGFloat = 1

    /// Mode to use crop pattern
    var mode: Mode = .rect
}
