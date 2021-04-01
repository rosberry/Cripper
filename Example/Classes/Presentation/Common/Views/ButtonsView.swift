//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import UIKit

final class ButtonsView: UIView {

    struct ButtonConfiguration {
        var title: String
        var buttonClickHandler: (() -> Void)
    }

    // MARK: - Subviews

    var buttonConfigurations: [ButtonConfiguration] = [] {
        didSet {
            remove(subviews)
            for i in 0..<buttonConfigurations.count {
                let button = UIButton(type: .system)
                button.setTitle(buttonConfigurations[i].title, for: .normal)
                button.tag = i
                button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
                add(button)
            }
            setNeedsLayout()
        }
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let inset: CGFloat = 10
        let count = CGFloat(subviews.count)
        let width = (bounds.width - inset * (count - 1)) / count
        subviews.forEach { view in
            view.configureFrame { maker in
                maker.top().bottom().width(width).left(inset: CGFloat(view.tag) * (width + inset))
            }
        }
    }

    // MARK: - Action

    @objc private func buttonPressed(_ button: UIButton) {
        let configuration = buttonConfigurations[button.tag]
        configuration.buttonClickHandler()
    }
}
