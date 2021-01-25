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

    var clipBorderInset: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }

    var clipBorderWidth: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }

    var clipBorderColor: UIColor = UIColor.white.withAlphaComponent(0.5) {
        didSet {
            setNeedsDisplay()
        }
    }

    var cropPatternBuilder: CropPatternBuilder? {
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
        if let pattern = cropPatternBuilder?.makeCropPattern(in: rect),
            let context = UIGraphicsGetCurrentContext() {
            context.saveGState()

            context.setFillColor(overlayColor.cgColor)
            let insetScaleX = (rect.width - 2 * clipBorderInset) / rect.width
            let insetScaleY = (rect.height - 2 * clipBorderInset) / rect.height
            let externalRect = CGRect(x: rect.minX - clipBorderInset,
                                      y: rect.minY - clipBorderInset,
                                      width: rect.width / insetScaleX,
                                      height: rect.height / insetScaleY)
            let inverted = UIBezierPath(rect: externalRect)
            let shapePath = UIBezierPath(cgPath: pattern.path)
            shapePath.apply(.init(translationX: pattern.previewRect.minX, y: pattern.previewRect.minY))
            inverted.append(shapePath.reversing())
            let clipPath = inverted.cgPath
            context.scaleBy(x: insetScaleX, y: insetScaleY)
            context.translateBy(x: clipBorderInset, y: clipBorderInset)
            context.addPath(clipPath)
            context.clip()
            context.fill(externalRect)
            context.addPath(shapePath.cgPath)
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
