//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import UIKit

/// Syntax sugar extension that simplifyes `UIBezierPath` usage
extension UIBezierPath {

    /// Applies insets to current `UIBezierPath`
    /// - Parameters:
    ///   - inset: Inset that should be applied
    ///   - withTranslate: Flag that allows to skip path translation after inset scale applying
    func apply(inset: CGFloat, withTranslate: Bool = true) {
        let insetScaleX = (bounds.width - 2 * inset) / bounds.width
        let insetScaleY = (bounds.height - 2 * inset) / bounds.height
        if withTranslate {
            apply(.init(translationX: inset, y: inset))
        }
        apply(.init(scaleX: insetScaleX, y: insetScaleY))
    }

    /// Creates reversed path from current path using external bounds
    /// - Parameters:
    ///   - bounds: external bounds of reversing path
    func reversing(in bounds: CGRect) -> UIBezierPath {
        let inverted = UIBezierPath(rect: bounds)
        let path = UIBezierPath(cgPath: cgPath)
        inverted.append(path.reversing())
        return inverted
    }
}
