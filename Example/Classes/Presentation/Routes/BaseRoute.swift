//
//  Copyright © 2018 Rosberry. All rights reserved.
//

import UIKit

public protocol Router: class {

    associatedtype ViewController: UIViewController

    var viewController: ViewController? { get }
    var topViewController: UIViewController? { get }
}

open class BaseRouter<ViewController: UIViewController>: Router {

    open var topViewController: UIViewController? {
        return viewController?.findTopViewControllerRecursively()
    }
    open weak var viewController: ViewController?

    public init(viewController: ViewController? = nil) {
        self.viewController = viewController
    }
}

extension UIViewController {

    func findTopViewControllerRecursively() -> UIViewController {
        if let presentedViewController = presentedViewController {
            return presentedViewController.findTopViewControllerRecursively()
        }
        if let navigationController = self as? UINavigationController,
            let topViewController = navigationController.topViewController {
            let controller = topViewController.presentedViewController ?? topViewController
            return controller.findTopViewControllerRecursively()
        }
        return self
    }
}
