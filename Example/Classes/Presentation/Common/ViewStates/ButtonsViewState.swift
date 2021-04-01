//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import CollectionViewTools

struct ButtonsViewState: DiffCompatible {
    let name: String
    let configurations: [ButtonsView.ButtonConfiguration]

    var debugDescription: String {
        name
    }

    static func ==(lhs: ButtonsViewState, rhs: ButtonsViewState) -> Bool {
        lhs.name == rhs.name
    }
}
