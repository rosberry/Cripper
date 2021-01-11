//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

public final class Cripper {

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

    public func crop(image: UIImage, with crop: Crop, in bounds: CGRect) -> UIImage? {
        let path = UIBezierPath(cgPath: crop.path)
        path.apply(.init(scaleX: crop.rect.width, y: crop.rect.height))
        path.apply(.init(translationX: crop.translation.x,
                         y: crop.translation.y))
        path.apply(.init(scaleX: crop.scale, y: crop.scale))
        return self.crop(image: image, with: path.cgPath)
    }

    func pointSize(of image: UIImage) -> CGSize {
        let size = image.size
        let scale = UIScreen.main.scale
        return .init(width: size.width / scale, height: size.height / scale)
    }

    func scale(for size: CGSize, in bounds: CGRect) -> CGFloat {
        let widthScale = bounds.width / size.width
        let heightScale = bounds.height / size.height
        return min(widthScale, heightScale)
    }
}
