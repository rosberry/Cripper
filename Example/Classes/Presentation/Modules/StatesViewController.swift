//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit
import Cripper
import Framezilla
import Base
import Routes
import CollectionViewTools

final class StatesViewController: ViewController {

    var states: [Any]
    
    // MARK: - Lifecycle

    init(states: [Any]) {
        self.states = states
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        initialStates = states
        super.viewDidLoad()
    }
}
