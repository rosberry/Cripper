//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

/// `Cropper` allows to crop some image with `CropPattern` or `CGPath`
public final class Cropper {

    /// Creates new cropped image from given one using `CGPath`
    /// - Parameters:
    ///  - image: Original image that should be cropped
    ///  - path: `CGPath` that should be used to crop original image
    public func crop(image: UIImage, with path: CGPath) -> UIImage? {
        let box = path.boundingBox
        let renderer = UIGraphicsImageRenderer(size: box.size)
        return renderer.image { rendererContext in
            let context = rendererContext.cgContext
            context.translateBy(x: -box.minX, y: -box.minY)
            context.addPath(path)
            context.clip()
            image.draw(in: .init(origin: .zero, size: image.size))
        }
    }

    /// Creates new cropped image from given one using `CropPattern`
    /// - Parameters:
    ///  - image: Original image that should be cropped
    ///  - path: `CropPattern` that should be used to crop original image
    public func crop(image: UIImage, with pattern: CropPattern) -> UIImage? {
        let path: UIBezierPath
        switch pattern.mode {
        case .path:
            let origin = pattern.path.boundingBox.origin
            path = UIBezierPath(cgPath: pattern.path)
            path.apply(.init(translationX: -origin.x, y: -origin.y))
        case .rect:
            path = UIBezierPath(rect: .init(origin: .zero, size: pattern.path.boundingBox.size))
        }
        path.apply(.init(translationX: pattern.translation.x,
                         y: pattern.translation.y))
        path.apply(.init(scaleX: pattern.scale, y: pattern.scale))
        return self.crop(image: image, with: path.cgPath)
    }
}
