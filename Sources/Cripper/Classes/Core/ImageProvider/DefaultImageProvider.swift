//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import UIKit

/// Default `ImageProvider` implementation that allows to fetch an image for required scale from a known in advance dictionary
class DefaultImageProvider: ImageProvider {

    /// Dictionary that associates scale constraints with contcrete images
    var images: [ImageScaleConstraint: UIImage]

    /// Returns an array of all specified scale constraints
    var constraints: [ImageScaleConstraint] {
        Array(images.keys)
    }

    /// Initializes image provider with the known in advance dictionary of images associated with scale constraints
    /// - Parameters:
    ///   - images: Dictionary that associates scale constraints with contcrete images
    init(images: [ImageScaleConstraint: UIImage]) {
        self.images = images
    }

    /// Initializer that allows to use the same image for all possible scales
    /// - Parameters:
    ///   - image: The image the will be used for all possible scales
    convenience init(image: UIImage) {
        self.init(images: [.default: image])
    }

    /// Implementetion of `ImageProvider` method that fetch the most satisfying image for a given scale constaint
    /// - Parameters:
    ///   - scaleConstraint: The scale constraint that should be used to fetch an image
    ///   - resultHandler: A closure that accepts an image for provided scale constraint or nil if no image satisfying this scale constraint   
    func fetchImage(with scaleConstraint: ImageScaleConstraint, resultHandler: @escaping (UIImage?) -> Void) {
        resultHandler(images[scaleConstraint])
    }
}
