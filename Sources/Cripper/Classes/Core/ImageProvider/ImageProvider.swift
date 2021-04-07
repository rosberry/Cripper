//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import UIKit

/// `ImageProvider` allows to define a way how an image for a given scale can be fetched
public protocol ImageProvider {

    /// A set of constrains that defines a way how an image for a given scale can be fetched
    var constraints: [ImageScaleConstraint] { get }

    /// Async request to fetch an image with required scale
    /// - Parameters:
    ///   - scale: The scale value that should be used to fetch an image
    ///   - resultHandler: A closure that accepts an image for provided scale or nil if no image satisfying this scale
    func fetchImage(withScale scale: CGFloat, resultHandler: @escaping (UIImage?) -> Void)

    /// Async request to fetch an image with required scale constraint
    /// - Parameters:
    ///   - scaleConstraint: The scale constraint that should be used to fetch an image
    ///   - resultHandler: A closure that accepts an image for provided scale constraint or nil if no image satisfying this scale constraint
    func fetchImage(with scaleConstraint: ImageScaleConstraint, resultHandler: @escaping (UIImage?) -> Void)

    /// Returns the most satisfying scale constraint for a given scale if this one exists
    /// - Parameters:
    ///   - scale: The scale value that should be used to fetch the most satisfying scale constraint
    func constraint(forScale: CGFloat) -> ImageScaleConstraint?
}

extension ImageProvider {

    /// Default implementation that allows to return the most satisfying scale constraint for a given scale
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
        let mostGreat = matchConstraints.mostGreat

        return mostLess.distance(to: scale) < mostGreat.distance(to: scale) ? mostLess : mostGreat
    }

    // Default implementation that allows to fetch an image with required scale
    func fetchImage(withScale scale: CGFloat, resultHandler: @escaping (UIImage?) -> Void) {
        guard let constraint = self.constraint(forScale: scale) else {
            return resultHandler(nil)
        }
        fetchImage(with: constraint, resultHandler: resultHandler)
    }
}
