//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import XCTest
@testable import Cripper

import UIKit

extension UIImage {
    static func bundledImage(named name: String) -> UIImage {
        let bundle = Bundle(for: CripperTests.self)
        guard let path = bundle.path(forResource: name, ofType: nil),
              let image = UIImage(contentsOfFile: path) else {
            XCTAssert(false, "Could not load image \(name)")
            return UIImage()
        }
        return image
    }

    func rectCrop(rect: CGRect) -> UIImage {
        let path = CGPath(rect: rect, transform: nil)
        return pathCrop(path: path)
    }

    func ellipseCrop(rect: CGRect) -> UIImage {
        let path = CGPath(ellipseIn: rect, transform: nil)
        return pathCrop(path: path)
    }

    func rectPatternCrop(rect: CGRect) -> UIImage {
        let builder = CropShape.rect(aspectRatio: rect.width / rect.height).cropPatternBuilder
        var pattern = builder.makeCropPattern(in: .init(origin: .zero, size: rect.size))
        pattern.translation = rect.origin
        return patternCrop(pattern: pattern)
    }

    func ellipsePatternCrop(rect: CGRect, mode: CropPattern.Mode = .rect) -> UIImage {
        let builder = CropShape.ellipse(aspectRatio: rect.width / rect.height).cropPatternBuilder
        var pattern = builder.makeCropPattern(in: .init(origin: .zero, size: rect.size))
        pattern.mode = mode
        pattern.translation = rect.origin
        return patternCrop(pattern: pattern)
    }

    func patternCrop(pattern: CropPattern) -> UIImage {
        let cropper = Cropper()
        guard let croppedImage = cropper.crop(image: self, with: pattern) else {
            XCTAssert(false, "Crop result is nil")
            return UIImage()
        }
        return croppedImage
    }

    func pathCrop(path: CGPath) -> UIImage {
        let cropper = Cropper()
        guard let croppedImage = cropper.crop(image: self, with: path) else {
            XCTAssert(false, "Crop result is nil")
            return UIImage()
        }
        return croppedImage
    }

    func compare(_ rhs: UIImage, accuracy: Double) -> Bool {
        guard abs(size.width - rhs.size.width) < 3,
              abs(size.height - rhs.size.height) < 3 else {
            return false
        }
        let width = Int(min(size.width, rhs.size.width))
        let height = Int(min(size.height, rhs.size.height))
        guard let lhs = pixelDataPointer,
              let rhs = rhs.pixelDataPointer else {
            return false
        }

        var difference: Double = 0
        for x in 0..<width {
            for y in 0..<height {
                let offset = ((width  * y) + x ) * 4
                var pixelDifference: Double = 0
                for index in 0..<4 {
                    let lhs = Double(lhs[offset + index])
                    let rhs = Double(rhs[offset + index])
                    pixelDifference += pow((lhs - rhs) / 255, 2)
                }
                pixelDifference = sqrt(pixelDifference)
                difference += pixelDifference
            }
        }
        return difference < accuracy
    }

    var pixelDataPointer: UnsafePointer<UInt8>? {
        guard let cgImage = self.cgImage,
              let dataProvider = cgImage.dataProvider else {
            return nil
        }
        let pixelData = dataProvider.data
        let pointer = CFDataGetBytePtr(pixelData)
        return pointer
    }
}
