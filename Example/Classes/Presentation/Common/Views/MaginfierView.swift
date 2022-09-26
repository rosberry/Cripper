//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

public final class MagnifierView: UIView {

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if frame.contains(point) {
            return superview
        }
        return nil
    }

    func setup() {
        layer.cornerRadius = frame.height / 2.0
        layer.borderWidth = 4.0
        layer.borderColor = UIColor.gray.cgColor
    }
}
