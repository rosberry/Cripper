//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

public protocol AlertRoute {
    func showAlert(title: String?, message: String?, preferredStyle: UIAlertController.Style, actions: [UIAlertAction])
}

public extension AlertRoute where Self: Router {

    func showAlert(title: String?, message: String?, preferredStyle: UIAlertController.Style, actions: [UIAlertAction]) {
        let alertViewController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: preferredStyle)
        actions.forEach { action in
            alertViewController.addAction(action)
        }
        viewController?.present(alertViewController, animated: true, completion: nil)
    }
}
