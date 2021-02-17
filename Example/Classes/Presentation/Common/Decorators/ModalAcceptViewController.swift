//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import UIKit
import Framezilla

final class ModalAcceptViewController: AcceptViewController {

    // MARK: - Subviews

    private(set) lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✓", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24)
        button.titleLabel?.tintColor = .white
        button.addTarget(self, action: #selector(acceptButtonPressed), for: .touchUpInside)
        return button
    }()

    private(set) lazy var declineButton: UIButton = {
        let button = UIButton()
        button.setTitle("✗", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24)
        button.titleLabel?.tintColor = .white
        button.addTarget(self, action: #selector(declineButtonPressed), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override init(viewController: UIViewController) {
        super.init(viewController: viewController)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.add(acceptButton, declineButton)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        acceptButton.configureFrame { maker in
            maker.top(to: view.nui_safeArea.top).left().size(width: 56, height: 56)
        }
        declineButton.configureFrame { maker in
            maker.top(to: view.nui_safeArea.top).right().size(width: 56, height: 56)
        }
    }
}
