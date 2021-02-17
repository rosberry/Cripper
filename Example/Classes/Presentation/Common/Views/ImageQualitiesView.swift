//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import UIKit

final class ImageQualitiesView: UIView {

    // MARK: - Subviews

    private(set) lazy var lowQualityImageView: UIImageView = .init()
    private(set) lazy var normalQualityImageView: UIImageView = .init()
    private(set) lazy var highQualityImageView: UIImageView = .init()
    private lazy var lowQualityLabel: UILabel = .init()
    private lazy var normalQualityLabel: UILabel = .init()
    private lazy var highQualityLabel: UILabel = .init()

    private lazy var imageViews: [UIImageView] = [lowQualityImageView, normalQualityImageView, highQualityImageView]
    private lazy var imageLabels: [UILabel] = [lowQualityLabel, normalQualityLabel, highQualityLabel]

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

        let inset: CGFloat = 16
        let imageViewHeight = (bounds.width - CGFloat(1 + imageViews.count) * inset) / CGFloat(imageViews.count)

        for index in 0..<imageViews.count {
            let imageView = imageViews[index]
            let label = imageLabels[index]
            let leftInset =  inset + CGFloat(index) * (inset + imageViewHeight)
            label.configureFrame { maker in
                maker.size(width: imageViewHeight, height: 30).top().left(inset: leftInset)
            }
            imageView.configureFrame { maker in
                maker.size(width: imageViewHeight, height: imageViewHeight).top(inset: 40).left(inset: leftInset)
            }
        }
    }

    // MARK: - Private

    private func setup() {
        add(lowQualityLabel, normalQualityLabel, highQualityLabel,
            lowQualityImageView, normalQualityImageView, highQualityImageView)
        lowQualityLabel.text = "Low"
        normalQualityLabel.text = "Normal"
        highQualityLabel.text = "High"
    }
}
