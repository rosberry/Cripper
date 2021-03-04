//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit
import Bin

public final class CropOverlayView: UIView {

    private class GridView: UIView {
        var cropPatternBuilder: CropPatternBuilder? {
            didSet {
                setNeedsDisplay()
            }
        }

        var clipBorderColor: UIColor = UIColor.white.withAlphaComponent(0.5){
            didSet {
                setNeedsDisplay()
            }
        }

        var clipBorderWidth: CGFloat = 1{
            didSet {
                setNeedsDisplay()
            }
        }

        var gridLinesNumber: Int = 2{
            didSet {
                setNeedsDisplay()
            }
        }

        var showsGridLines: Bool = false {
            didSet {
                setNeedsDisplay()
            }
        }

        var shapePathWillUpdated: ((UIBezierPath) -> Void)?

        override func draw(_ rect: CGRect) {
            guard let context = UIGraphicsGetCurrentContext(),
                  let pattern = cropPatternBuilder?.makeCropPattern(in: bounds) else {
                return super.draw(rect)
            }
            let path = UIBezierPath(cgPath: pattern.path)
            path.apply(inset: clipBorderWidth / 2)
            shapePathWillUpdated?(path)
            context.saveGState()
            context.addPath(path.cgPath)
            context.setStrokeColor(clipBorderColor.cgColor)
            context.setLineWidth(clipBorderWidth)
            context.strokePath()
            context.restoreGState()
            guard showsGridLines else {
                return
            }
            context.saveGState()
            context.addPath(path.cgPath)
            context.clip()
            for i  in 0..<gridLinesNumber {
                let horizontalOffset = bounds.width / CGFloat(gridLinesNumber + 1)
                let verticalOffset = bounds.height / CGFloat(gridLinesNumber + 1)
                let hrizontalLineY = CGFloat(i + 1) * verticalOffset
                let verticalLineX = CGFloat(i + 1) * horizontalOffset
                let horizontalLineStart = CGPoint(x: 0, y: hrizontalLineY)
                let horizontalLineEnd = CGPoint(x: bounds.width, y: hrizontalLineY)
                let verticalLineStart = CGPoint(x: verticalLineX, y: 0)
                let verticalLineEnd = CGPoint(x: verticalLineX, y: bounds.width)
                context.move(to: horizontalLineStart)
                context.addLine(to: horizontalLineEnd)
                context.move(to: verticalLineStart)
                context.addLine(to: verticalLineEnd)
                context.setLineWidth(clipBorderWidth)
                context.setStrokeColor(clipBorderColor.cgColor)
                context.strokePath()
            }
            context.restoreGState()
        }
    }

    public var overlayColor: UIColor = UIColor.black.withAlphaComponent(0.5) {
        didSet {
            updateDrawing()
        }
    }

    public var clipBorderInset: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }

    public var clipBorderWidth: CGFloat {
        get {
            gridView.clipBorderWidth
        }
        set {
            gridView.clipBorderWidth = newValue
        }
    }

    public var clipBorderColor: UIColor {
        get {
            gridView.clipBorderColor
        }
        set {
            gridView.clipBorderColor = newValue
        }
    }

    public var blurAlpha: CGFloat = 0.5 {
        didSet {
            updateDrawing()
        }
    }

    public var blurRadius: CGFloat = 1 {
        didSet {
            updateDrawing()
        }
    }

    public var gridLinesNumber: Int {
        get {
            gridView.gridLinesNumber
        }
        set {
            gridView.gridLinesNumber = newValue
        }
    }

    var cropPatternBuilder: CropPatternBuilder? {
        didSet {
            gridView.cropPatternBuilder = cropPatternBuilder
            updateDrawing()
            setNeedsLayout()
            layoutIfNeeded()
            setNeedsDisplay()
        }
    }

    var showsGridLines: Bool {
        get {
            gridView.showsGridLines
        }
        set {
            gridView.showsGridLines = newValue
        }
    }

    private var blurView: CustomBlurEffectView?
    private lazy var gridView: GridView = {
        let view = GridView()
        view.shapePathWillUpdated = { [weak self] path in
            guard let self = self else {
                return
            }
            let layer = self.blurView?.layer as? CAShapeLayer ?? CAShapeLayer()
            var path = UIBezierPath(cgPath: path.cgPath)
            path.apply(.init(translationX: view.frame.minX, y: view.frame.minY))
            path = path.reversing(in: self.bounds)
            layer.path = path.cgPath
            self.blurView?.layer.mask = layer
        }
        return view
    }()

    // MARK: - Lifecycle

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        blurView?.frame = bounds
        if let frame = cropPatternBuilder?.makeCropPattern(in: bounds).previewRect {
            gridView.frame = frame.insetBy(dx: clipBorderInset, dy: clipBorderInset)
        }
    }

    // MARK: - Private

    private func setup() {
        isUserInteractionEnabled = false
        add(gridView)
        gridView.backgroundColor = .clear
        updateDrawing()
    }

    private func updateDrawing() {
        blurView?.removeFromSuperview()
        let blurView = CustomBlurEffectView(blurAlpha: blurAlpha, blurColor: overlayColor, blurRadius: blurRadius)
        add(blurView)
        self.blurView = blurView
        sendSubviewToBack(blurView)
        setNeedsDisplay()
    }
}
