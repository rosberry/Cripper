//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

public final class Cropper {

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

    public func crop(image: UIImage, with pattern: CropPattern) -> UIImage? {
        let path: UIBezierPath
        switch pattern.mode {
        case .path:
            path = UIBezierPath(cgPath: pattern.path)
        case .rect:
            path = UIBezierPath(rect: .init(origin: .zero, size: pattern.previewRect.size))
        }

        path.apply(.init(translationX: pattern.translation.x,
                         y: pattern.translation.y))
        path.apply(.init(scaleX: pattern.scale, y: pattern.scale))
        return self.crop(image: image, with: path.cgPath)
    }
}
