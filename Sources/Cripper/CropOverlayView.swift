//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

public final class CropOverlayView: UIView {

    var overlayColor: UIColor = UIColor.black.withAlphaComponent(0.5) {
        didSet {
            setNeedsDisplay()
        }
    }

    var clipBorderInset: CGFloat = 4 {
        didSet {
            setNeedsDisplay()
        }
    }

    var clipBorderWidth: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }

    var clipBorderColor: UIColor = .yellow {
        didSet {
            setNeedsDisplay()
        }
    }

    var cropBuilder: CropBuilder? {
        didSet {
            setNeedsDisplay()
        }
    }

    // MARK: - Lifecycle

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    public override func draw(_ rect: CGRect) {
        if let crop = cropBuilder?.makeCrop(in: rect),
            let context = UIGraphicsGetCurrentContext() {
            context.saveGState()

            context.setFillColor(overlayColor.cgColor)
            let scaleX = (rect.width - 2 * clipBorderInset) / rect.width
            let scaleY = (rect.height - 2 * clipBorderInset) / rect.height
            let externalRect = CGRect (x: rect.minX - clipBorderInset,
                                       y: rect.minY - clipBorderInset,
                                       width: rect.width / scaleX,
                                       height: rect.height / scaleY)
            let inverted = UIBezierPath(rect: externalRect)
            inverted.append(UIBezierPath(cgPath: crop.path).reversing())
            let clipPath = inverted.cgPath
            context.scaleBy(x: scaleX, y: scaleY)
            context.translateBy(x: clipBorderInset, y: clipBorderInset)
            context.addPath(clipPath)
            context.clip()
            context.fill(externalRect)
            context.addPath(crop.path)
            context.setStrokeColor(clipBorderColor.cgColor)
            // half of line width will be clipped
            context.setLineWidth(clipBorderWidth * 2)
            context.strokePath()
            context.restoreGState()
        }
        else {
            super.draw(rect)
        }
    }

    // MARK: - Private

    private func setup() {
        isUserInteractionEnabled = false
    }
}