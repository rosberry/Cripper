//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

public struct CropPattern {

    public enum Mode {
        case rect
        case path
    }

    var rect: CGRect
    var path: CGPath
    var translation: CGPoint = .zero
    var scale: CGFloat = 1
    var mode: Mode = .rect
}
