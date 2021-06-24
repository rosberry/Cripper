//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit
import Bin

/// `CropOverlayView` presents preview of crop aplying
final class CropOverlayView: UIView {

    /// `GridView` is view that displays over crop area.
    /// Displays bounds and grid lines for image alignment
    final class GridView: UIView {

        /// `CropPatternBuilder` to display specified crop path
        var cropPatternBuilder: CropPatternBuilder? {
            didSet {
                setNeedsDisplay()
            }
        }

        /// Color of crop area borders
        var clipBorderColor: UIColor = UIColor.white.withAlphaComponent(0.5) {
            didSet {
                setNeedsDisplay()
            }
        }

        /// Width of crop area borders
        var clipBorderWidth: CGFloat = 1 {
            didSet {
                setNeedsDisplay()
            }
        }

        /// Number of grid lines that allows to align image properly
        var gridLinesNumber: Int = 2 {
            didSet {
                setNeedsDisplay()
            }
        }

        /// Specify grid lines visibility: true on image alignment or scaling
        var showsGridLines: Bool = false {
            didSet {
                setNeedsDisplay()
            }
        }

        /// Closure that sends modifyed shape path
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
            for lineNumber in 1...gridLinesNumber {
                let horizontalOffset = bounds.width / CGFloat(gridLinesNumber + 1)
                let verticalOffset = bounds.height / CGFloat(gridLinesNumber + 1)
                let hrizontalLineY = CGFloat(lineNumber) * verticalOffset
                let verticalLineX = CGFloat(lineNumber) * horizontalOffset
                let horizontalLineStart = CGPoint(x: 0, y: hrizontalLineY)
                let horizontalLineEnd = CGPoint(x: bounds.width, y: hrizontalLineY)
                let verticalLineStart = CGPoint(x: verticalLineX, y: 0)
                let verticalLineEnd = CGPoint(x: verticalLineX, y: bounds.width)
                context.move(to: horizontalLineStart)
                context.addLine(to: horizontalLineEnd)
                context.move(to: verticalLineStart)
                context.addLine(to: verticalLineEnd)
                context.setStrokeColor(UIColor.white.cgColor)
                context.setLineWidth(0.5)
                context.strokePath()
            }
            context.restoreGState()
        }
    }

    /// Color that will display outside crop area
    public var overlayColor: UIColor = UIColor.black.withAlphaComponent(0.5) {
        didSet {
            updateDrawing()
        }
    }

    /// Inset of crop area from screen bounds
    public var clipBorderInset: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }

    /// Width of crop area borders
    public var clipBorderWidth: CGFloat {
        get {
            gridView.clipBorderWidth
        }
        set {
            gridView.clipBorderWidth = newValue
        }
    }

    /// Color of crop area borders
    public var clipBorderColor: UIColor {
        get {
            gridView.clipBorderColor
        }
        set {
            gridView.clipBorderColor = newValue
        }
    }

    /// Opacity of blur effect othside crop area
    public var blurAlpha: CGFloat = 0.5 {
        didSet {
            updateDrawing()
        }
    }

    /// Radius of blur effect othside crop area
    public var blurRadius: CGFloat = 1 {
        didSet {
            updateDrawing()
        }
    }

    /// Number of grid lines that allows to align image properly
    public var gridLinesNumber: Int {
        get {
            gridView.gridLinesNumber
        }
        set {
            gridView.gridLinesNumber = newValue
        }
    }

    /// `CropPatternBuilder` to display specified crop path
    var cropPatternBuilder: CropPatternBuilder? {
        didSet {
            gridView.cropPatternBuilder = cropPatternBuilder
            updateDrawing()
            setNeedsLayout()
            layoutIfNeeded()
            setNeedsDisplay()
        }
    }

    /// Specify grid lines visibility: true on image alignment or scaling
    var showsGridLines: Bool {
        get {
            gridView.showsGridLines
        }
        set {
            gridView.showsGridLines = newValue
        }
    }

    private(set) var blurView: CustomBlurEffectView?
    private(set) lazy var gridView: GridView = {
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
