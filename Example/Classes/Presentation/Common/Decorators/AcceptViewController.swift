//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import UIKit
import Framezilla

class AcceptViewController: UIViewController {

    var acceptHandler: (() -> Void)?
    var declineHandler: (() -> Void)?

    // MARK: - Subviews

    let viewController: UIViewController

    // MARK: - Lifecycle

    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.add(viewController.view)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewController.view.frame = view.bounds
    }

    // MARK: - Actions

    @objc func acceptButtonPressed() {
        acceptHandler?()
    }

    @objc func declineButtonPressed() {
        declineHandler?()
    }
}
