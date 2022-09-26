//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import CollectionViewTools

struct ImageViewState: DiffCompatible {
    let name: String
    let image: UIImage?

    var diffIdentifier: String {
        name
    }

    func makeDiffComparator() -> Bool {
        true
    }
}
