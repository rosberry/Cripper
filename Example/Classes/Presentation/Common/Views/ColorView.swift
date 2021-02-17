//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import UIKit
import Framezilla
import Bin

final class ColorView: UIView {

    var colorDidChangeHandler: ((UIColor?) -> Void)?

    var color: UIColor? {
        return hslView.color?.withAlphaComponent(CGFloat(sliderView.slider.value))
    }

    // MARK: - Subviews

    private(set) lazy var titleLabel: UILabel = .init()
    private(set) lazy var hslView: HSLView = .init()
    private(set) lazy var sliderView: SliderView = .init()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        titleLabel.configureFrame { maker in
            maker.top().left().right().height(40)
        }

        sliderView.configureFrame { maker in
            maker.left().right().bottom().height(40)
        }

        hslView.configureFrame { maker in
            maker.left().right().top(to: titleLabel.nui_bottom).bottom(to: sliderView.nui_top)
        }
    }

    // MARK: - Private

    private func setup() {
        add(titleLabel, hslView, sliderView)
        sliderView.label.text = "Opacity:"
        hslView.delegate = self
        sliderView.valueDidChangeHandler = { [weak self] value in
            self?.colorDidUpdate()
        }
    }

    private func colorDidUpdate() {
        hslView.magnifierView.backgroundColor = hslView.color?.withAlphaComponent(CGFloat(sliderView.slider.value))
        colorDidChangeHandler?(color)
    }
}

// MARK: - HSLViewDelegate

extension ColorView: HSLViewDelegate {
    func hslView(_ hslView: HSLView, didSelectColor color: UIColor) {
        colorDidUpdate()
    }

    func hslViewDidSelectAllColorItems(_ hslView: HSLView) {
        //
    }

    func hslViewDidBeginColorSelection(_ hslView: HSLView) {
        //
    }

    func hslViewDidEndColorSelection(_ hslView: HSLView) {
        //
    }
}
