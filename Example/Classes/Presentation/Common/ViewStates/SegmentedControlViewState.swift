//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import CollectionViewTools

class SegmentedControlViewState: DiffCompatible {
    let name: String
    var index: Int
    let cases: [String]

    var debugDescription: String {
        name
    }

    init(name: String, index: Int, cases: [String]) {
        self.name = name
        self.index = index
        self.cases = cases
    }

    static func == (lhs: SegmentedControlViewState, rhs: SegmentedControlViewState) -> Bool {
        lhs.name == rhs.name &&
        lhs.index == rhs.index &&
        lhs.cases == rhs.cases
    }
}
