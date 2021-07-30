//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import CollectionViewTools

class SliderViewState: DiffCompatible {
    let name: String
    var value: Float
    let min: Float
    let max: Float

    var debugDescription: String {
        name
    }

    init(name: String, value: Float, min: Float, max: Float) {
        self.name = name
        self.value = value
        self.min = min
        self.max = max
    }

    static func == (lhs: SliderViewState, rhs: SliderViewState) -> Bool {
        lhs.name == rhs.name
    }
}
