//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

/// `CropPatternBuilder` creates `CropPattern` relative to provided bounds
public protocol CropPatternBuilder {
    /// Returns `CropPattern` relative to provided bounds
    /// - Parameters:
    ///   - bounds: Bounding rect where crop shape should be placed (for example, screen bounds)
    func makeCropPattern(in bounds: CGRect) -> CropPattern

    /// Helper method that alows to specify bounding box of `CropPattern` relative to provided bounds
    /// - Parameters:
    ///   - aspectRatio: Aspect ration of crop pattern bounding box
    ///   - bounds: Bounding rect where crop shape should be placed  (for example, screen bounds)
    func makeRect(with aspectRatio: CGFloat, in bounds: CGRect) -> CGRect
}

public extension CropPatternBuilder {

    /// Default implementation of helper method that alows to specify bounding box of `CropPattern` relative to provided bounds
    /// - Parameters:
    ///   - aspectRatio: Aspect ration of crop pattern bounding box
    ///   - bounds: Bounding rect where crop shape should be placed  (for example, screen bounds)
    func makeRect(with aspectRatio: CGFloat, in bounds: CGRect) -> CGRect {
        var width = bounds.width
        var height = width / aspectRatio
        if height > bounds.height {
            height = bounds.height
            width = height * aspectRatio
        }
        let x = (bounds.width - width) / 2
        let y = (bounds.height - height) / 2
        return .init(x: x, y: y, width: width, height: height)
    }
}
