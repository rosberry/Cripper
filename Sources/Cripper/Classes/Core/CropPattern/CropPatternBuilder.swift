//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

public protocol CropPatternBuilder {
    func makeCropPattern(in bounds: CGRect) -> CropPattern
    func makeIdentityRect() -> CGRect
    func makeRect(with aspectRatio: CGFloat, in bounds: CGRect) -> CGRect
}

public extension CropPatternBuilder {

    func makeIdentityRect() -> CGRect {
        .init(x: 0, y: 0, width: 1, height: 1)
    }

    func makeRect(with aspectRatio: CGFloat, in bounds: CGRect) -> CGRect {
        var width = bounds.width
        var height = width / aspectRatio
        if height > bounds.height {
            height = bounds.height
            width = height * aspectRatio
        }
        let x = (bounds.width - width) / 2
        let y = (bounds.height - height) / 2
        return .init(x: x, y: y, width: width, height: height)
    }
}
