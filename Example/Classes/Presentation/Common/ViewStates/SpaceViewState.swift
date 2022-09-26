//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import CollectionViewTools

struct SpaceViewState: DiffCompatible {
    let name: String
    let height: CGFloat

    var diffIdentifier: String {
        name
    }

    func makeDiffComparator() -> Bool {
        true
    }
}
