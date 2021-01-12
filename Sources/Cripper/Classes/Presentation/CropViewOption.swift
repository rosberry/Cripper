//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

public struct CropViewOption {

    public static func square(title: String? = nil, image: UIImage? = nil) -> CropViewOption {
        .init(title: title ?? NSLocalizedString("Square", comment: ""),
              image: nil,
              cropPatternBuilder: .square)
    }

    public static func rect(title: String? = nil, image: UIImage? = nil, width: Int, height: Int) -> CropViewOption {
        .init(title: title ?? "\(width):\(height)",
              image: nil,
              cropPatternBuilder: .rect(aspectRatio: CGFloat(width) / CGFloat(height)))
    }

    public static func circle(title: String? = nil, image: UIImage? = nil) -> CropViewOption {
        .init(title: title ?? NSLocalizedString("Circle", comment: ""),
              image: nil,
              cropPatternBuilder: .circle)
    }

    public static func ellipse(title: String? = nil, image: UIImage? = nil, width: Int, height: Int) -> CropViewOption {
        .init(title: title ?? "\(width):\(height)",
              image: nil,
              cropPatternBuilder: .ellipse(aspectRatio: CGFloat(width) / CGFloat(height)))
    }

    let title: String?
    let image: UIImage?
    let cropPatternBuilder: CropPatternBuilder

    public init(title: String? = nil, image: UIImage? = nil, cropPatternBuilder: CropPatternBuilder) {
        self.title = title
        self.image = image
        self.cropPatternBuilder = cropPatternBuilder
    }

    public init(title: String? = nil, image: UIImage? = nil, cropPatternBuilder: CropPatterBuilders) {
        self.init(title: title,
                  image: image,
                  cropPatternBuilder: cropPatternBuilder.cropPatternBuilder)
    }
}
