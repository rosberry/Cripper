//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import CollectionViewTools

struct ImageQualitiesViewState: DiffCompatible {
    var low: UIImage?
    var normal: UIImage?
    var high: UIImage?

    var diffIdentifier: String {
        "image qualities"
    }

    func makeDiffComparator() -> Bool {
        true
    }
}
