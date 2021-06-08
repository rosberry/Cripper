import XCTest
@testable import Cripper

import UIKit

func bundledImage(named name: String) -> UIImage {
    let bundle = Bundle(for: CripperTests.self)
    guard let path = bundle.path(forResource: name, ofType: nil),
          let image = UIImage(contentsOfFile: path) else {
        XCTAssert(false, "Could not load image \(name)")
        return UIImage()
    }
    return image
}

func rectCrop(_ image: UIImage, rect: CGRect) -> UIImage {
    let path = CGPath(rect: rect, transform: nil)
    return pathCrop(image, path: path)
}

func ellipseCrop(_ image: UIImage, rect: CGRect) -> UIImage {
    let path = CGPath(ellipseIn: rect, transform: nil)
    return pathCrop(image, path: path)
}

func rectPatternCrop(_ image: UIImage, rect: CGRect) -> UIImage {
    let builder = CropShape.rect(aspectRatio: rect.width / rect.height).cropPatternBuilder
    var pattern = builder.makeCropPattern(in: .init(origin: .zero, size: rect.size))
    pattern.translation = rect.origin
    return patternCrop(image, pattern: pattern)
}

func ellipsePatternCrop(_ image: UIImage, rect: CGRect, mode: CropPattern.Mode = .rect) -> UIImage {
    let builder = CropShape.ellipse(aspectRatio: rect.width / rect.height).cropPatternBuilder
    var pattern = builder.makeCropPattern(in: .init(origin: .zero, size: rect.size))
    pattern.mode = mode
    pattern.translation = rect.origin
    return patternCrop(image, pattern: pattern)
}

func patternCrop(_ image: UIImage, pattern: CropPattern) -> UIImage {
    let cropper = Cropper()
    guard let croppedImage = cropper.crop(image: image, with: pattern) else {
        XCTAssert(false, "Crop result is nil")
        return UIImage()
    }
    return croppedImage
}

func pathCrop(_ image: UIImage, path: CGPath) -> UIImage {
    let cropper = Cropper()
    guard let croppedImage = cropper.crop(image: image, with: path) else {
        XCTAssert(false, "Crop result is nil")
        return UIImage()
    }
    return croppedImage
}

func compare(_ lhs: UIImage, _ rhs: UIImage, accuracy: Double) -> Bool {
    guard abs(lhs.size.width - rhs.size.width) < 3 &&
          abs(lhs.size.height - rhs.size.height) < 3 else {
        return false
    }
    let width = Int(min(lhs.size.width, rhs.size.width))
    let height = Int(min(lhs.size.height, rhs.size.height))
    guard let lhs = pixelDataPointer(lhs),
          let rhs = pixelDataPointer(rhs) else {
        return false
    }

    var difference: Double = 0
    for x in 0..<width {
        for y in 0..<height {
            let offset = ((width  * y) + x ) * 4
            var pixelDifference: Double = 0
            for i in 0..<4 {
                let lhs = Double(lhs[offset + i])
                let rhs = Double(rhs[offset + i])
                pixelDifference += pow((lhs - rhs) / 255, 2)
            }
            pixelDifference = sqrt(pixelDifference)
            difference += pixelDifference
        }
    }
    return difference < accuracy
}

func pixelDataPointer(_ image: UIImage) -> UnsafePointer<UInt8>? {
    guard let cgImage = image.cgImage,
          let dataProvider = cgImage.dataProvider else {
        return nil
    }
    let pixelData = dataProvider.data
    let pointer = CFDataGetBytePtr(pixelData)
    return pointer
}
