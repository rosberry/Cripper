//
//  Copyright © 2022 Rosberry. All rights reserved.
//

import UIKit
import Framezilla

public protocol HSLViewDelegate: AnyObject {
    func hslView(_ hslView: HSLView, didSelectColor color: UIColor)
    func hslViewDidSelectAllColorItems(_ hslView: HSLView)
    func hslViewDidBeginColorSelection(_ hslView: HSLView)
    func hslViewDidEndColorSelection(_ hslView: HSLView)
}

public final class HSLView: UIView {

    public weak var delegate: HSLViewDelegate?

    private(set) lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hueSaturationViewRecognizerTriggered))
        return gestureRecognizer
    }()

    private(set) lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(hueSaturationViewRecognizerTriggered))
        return gestureRecognizer
    }()

    public var relativeGrayscaleWidth: CGFloat = 0.02 {
        didSet {
            setNeedsLayout()
        }
    }

    private var grayscaleWidth: CGFloat {
        return  bounds.width * relativeGrayscaleWidth
    }

    private lazy var bundle: Bundle = .init(for: HSLView.self)

    // If color is provided from external code then we need place magnifier, else we need only to remember a new value
    private var _color: UIColor?

    public var color: UIColor? {
        get {
            _color
        }
        set {
            _color = newValue
            if let color = self.color {
                magnifierView.center = magnifierViewCenter(forColor: color)
                magnifierView.backgroundColor = color
                magnifierView.isHidden = false
            }
            else {
                magnifierView.isHidden = true
            }
        }
    }

    // MARK: - Subviews

    private lazy var hueSaturationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private lazy var grayScaleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    public private(set) lazy var magnifierView = MagnifierView()

    public private(set) lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
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
        containerView.frame = bounds
        hueSaturationImageView.configureFrame { maker in
            maker.left().top().bottom().right(inset: grayscaleWidth)
        }
        grayScaleImageView.configureFrame { maker in
            maker.top().bottom().right().width(grayscaleWidth)
        }
        if let color = _color {
            magnifierView.center = magnifierViewCenter(forColor: color)
        }
    }

    // MARK: - Actions

    @objc private func hueSaturationViewRecognizerTriggered(_ recognizer: UIGestureRecognizer) {
        func setColor() {
            var touchPosition = recognizer.location(in: self)
            touchPosition = point(touchPosition, thatFits: hueSaturationImageView.frame)

            let color = UIColor(hue: hue(for: touchPosition),
                                saturation: saturation(for: touchPosition),
                                brightness: brightness(for: touchPosition),
                                alpha: 1.0)
            magnifierView.center = touchPosition
            magnifierView.backgroundColor = color
            _color = color
            delegate?.hslView(self, didSelectColor: color)
        }
        magnifierView.isHidden = false
        delegate?.hslViewDidSelectAllColorItems(self)
        switch recognizer.state {
        case .began:
            setColor()
            delegate?.hslViewDidBeginColorSelection(self)
        case .changed:
            setColor()
        case .ended:
            setColor()
            delegate?.hslViewDidEndColorSelection(self)
        default:
            break
        }
    }

    // MARK: - Private

    private func setup() {
        add(containerView, magnifierView)
        containerView.add(hueSaturationImageView, grayScaleImageView)
        containerView.addGestureRecognizer(tapGestureRecognizer)
        containerView.addGestureRecognizer(panGestureRecognizer)
        magnifierView.isHidden = true
        // Does not displayed without it
        DispatchQueue.main.async {
            self.hueSaturationImageView.image = self.image(withName: "hslColorPicker")
            self.grayScaleImageView.image = self.image(withName: "grayScale")
        }
    }

    private func image(withName name: String) -> UIImage? {
        UIImage(named: name, in: bundle, compatibleWith: nil)
    }

    private func magnifierViewCenter(forColor color: UIColor) -> CGPoint {
        let hue: UnsafeMutablePointer<CGFloat> = .allocate(capacity: 1)
        let saturation: UnsafeMutablePointer<CGFloat> = .allocate(capacity: 1)
        let brightness: UnsafeMutablePointer<CGFloat> = .allocate(capacity: 1)
        color.getHue(hue, saturation: saturation, brightness: brightness, alpha: nil)
        var x = hue.pointee * containerView.bounds.width
        var y = 0.5 * hueSaturationImageView.bounds.height

        if saturation.pointee == 0 { // Gray scale
            x = containerView.bounds.width
            y = (1 - brightness.pointee) * hueSaturationImageView.bounds.height
        }
        else {
            x = hue.pointee * containerView.bounds.width
            if brightness.pointee < 1 {
                y = (1 - brightness.pointee / 2) * hueSaturationImageView.bounds.height
            }
            else if saturation.pointee < 1 {
                y = saturation.pointee / 2 * hueSaturationImageView.bounds.height
            }
        }
        return .init(x: x, y: y)
    }

    private func hue(for position: CGPoint) -> CGFloat {
        return position.x / hueSaturationImageView.frame.width
    }

    private func saturation(for position: CGPoint) -> CGFloat {
        if grayscaleWidth > 0,
           containerView.bounds.width - position.x <= grayscaleWidth {
            return 0.0
        }

        let pointY = position.y / containerView.bounds.height
        if pointY < 0.5 {
            return 1.0 - (0.5 - pointY) * 2
        }
        else {
            return 1.0
        }
    }

    private func brightness(for position: CGPoint) -> CGFloat {
        if grayscaleWidth > 0,
           containerView.bounds.width - position.x <= grayscaleWidth {
            return 1.0 - position.y / containerView.bounds.height
        }

        let pointY = position.y / containerView.bounds.height
        if pointY > 0.5 {
            return 1.0 - (pointY - 0.5) * 2
        }
        else {
            return 1.0
        }
    }

    private func point(_ point: CGPoint, thatFits rect: CGRect) -> CGPoint {
        .init(x: min(max(point.x, rect.origin.x), rect.maxX),
              y: min(max(point.y, rect.origin.y), rect.maxY))
    }
}
