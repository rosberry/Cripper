//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import UIKit

class DefaultImageProvider: ImageProvider {

    var images: [ImageScaleConstraint: UIImage]

    var constraints: [ImageScaleConstraint] {
        return Array(images.keys)
    }

    init(images: [ImageScaleConstraint: UIImage]) {
        self.images = images
    }

    convenience init(image: UIImage) {
        self.init(images: [.default: image])
    }

    func fetchImage(with scaleConstraint: ImageScaleConstraint, resultHandler: @escaping (UIImage?) -> Void) {
        resultHandler(images[scaleConstraint])
    }
}
