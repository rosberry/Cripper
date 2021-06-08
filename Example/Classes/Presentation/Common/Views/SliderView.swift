//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import UIKit

final class SliderView: UIView {

    public var valueDidChangeHandler: ((Float) -> Void)?

    // MARK: - Subviews

    private(set) lazy var label: UILabel = .init()

    private(set) lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        return slider
    }()

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

        label.configureFrame { maker in
            maker.left().centerY().height(bounds.height).widthToFit()
        }

        slider.configureFrame { maker in
            maker.right().centerY().height(bounds.height).left(to: label.nui_right, inset: 10)
        }
    }

    // MARK: - Private

    private func setup() {
        add(slider, label)
        slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    // MARK: - Actions

    @objc private func valueChanged() {
        valueDidChangeHandler?(slider.value)
    }
}
