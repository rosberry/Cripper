//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import UIKit

extension UIBezierPath {

    func apply(inset: CGFloat, withTranslate: Bool = true) {
        let insetScaleX = (bounds.width - 2 * inset) / bounds.width
        let insetScaleY = (bounds.height - 2 * inset) / bounds.height
        if withTranslate {
            apply(.init(translationX: inset, y: inset))
        }
        apply(.init(scaleX: insetScaleX, y: insetScaleY))
    }

    func reversing(in bounds: CGRect) -> UIBezierPath {
        let inverted = UIBezierPath(rect: bounds)
        let path = UIBezierPath(cgPath: cgPath)
        inverted.append(path.reversing())
        return inverted
    }
}
