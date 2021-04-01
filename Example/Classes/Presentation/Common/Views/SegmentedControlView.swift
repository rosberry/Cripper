//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import UIKit

final class SegmentedControlView: UIView {

    public var selectedIndexDidChangeHandler: ((Int) -> Void)?

    // MARK: - Subviews

    private(set) lazy var label: UILabel = .init()

    private(set) lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        return segmentedControl
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

        segmentedControl.configureFrame { maker in
            maker.left().centerY().height(bounds.height).widthToFit()
        }

        segmentedControl.configureFrame { maker in
            maker.right().centerY().height(bounds.height).left(to: label.nui_right, inset: 10)
        }
    }

    // MARK: - Private

    private func setup() {
        add(segmentedControl, label)
        segmentedControl.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    // MARK: - Actions

    @objc private func valueChanged() {
        selectedIndexDidChangeHandler?(segmentedControl.selectedSegmentIndex)
    }
}
