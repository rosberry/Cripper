//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import CollectionViewTools

final class ColorViewState: DiffCompatible {
    let name: String
    var color: UIColor?

    init(name: String, color: UIColor?) {
        self.name = name
        self.color = color
    }

    var debugDescription: String {
        name
    }

    static func == (lhs: ColorViewState, rhs: ColorViewState) -> Bool {
        lhs.name == rhs.name
    }
}
