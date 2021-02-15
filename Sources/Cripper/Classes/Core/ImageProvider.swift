//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import UIKit

public protocol ImageProvider {
    var constraints: [ImageScaleConstraint] { get }
    func fetchImage(withScale scale: CGFloat, resultHandler: @escaping (UIImage?) -> Void)
    func fetchImage(with scaleConstraint: ImageScaleConstraint, resultHandler: @escaping (UIImage?) -> Void)
    func constraint(forScale: CGFloat) -> ImageScaleConstraint?
}

extension ImageProvider {

    func constraint(forScale scale: CGFloat) -> ImageScaleConstraint? {
        let matchConstraints = constraints.filter { constraint in
            switch constraint {
            case let .less(value):
                return scale < value
            case let .great(value):
                return scale > value
            case .default:
                return true
            }
        }
        let mostLess = matchConstraints.mostLess
        let mostGreat = matchConstraints.mostGreate

        return mostLess.distance(to: scale) < mostGreat.distance(to: scale) ? mostLess : mostGreat
    }

    func fetchImage(withScale scale: CGFloat, resultHandler: @escaping (UIImage?) -> Void) {
        guard let constraint = self.constraint(forScale: scale) else {
            return resultHandler(nil)
        }
        fetchImage(with: constraint, resultHandler: resultHandler)
    }
}
