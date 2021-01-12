//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

final class CropCell: UICollectionViewCell {

    private(set) lazy var imageView: UIImageView = .init()
    private(set) lazy var titleLabel: UILabel = .init()

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
        imageView.center = center
        imageView.bounds = .init(origin: .zero,
                                 size: .init(width: bounds.width - 8,
                                             height: bounds.height - 10))
        titleLabel.frame = .init(x: 0, y: bounds.height - 10,
                                 width: bounds.width, height: 10)
    }

    func setup() {
        addSubview(imageView)
        addSubview(titleLabel)
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 10)
    }
}
