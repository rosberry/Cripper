//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import CollectionViewTools

struct ImageViewState: DiffCompatible {
    let name: String
    let image: UIImage?

    var debugDescription: String {
        name
    }
}
