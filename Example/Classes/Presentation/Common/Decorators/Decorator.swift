//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import UIKit

final class Decorator {

    func modal<ViewController: UIViewController>(_ viewController: ViewController,
                                                 acceptHandler: @escaping ((ViewController) -> Void)) -> ModalAcceptViewController {
        let modalViewController = ModalAcceptViewController(viewController: viewController)
        modalViewController.acceptHandler = {
            modalViewController.dismiss(animated: true, completion: nil)
            acceptHandler(viewController)
        }
        modalViewController.declineHandler = {
            modalViewController.dismiss(animated: true, completion: nil)
        }
        modalViewController.modalPresentationStyle = .overFullScreen
        return modalViewController
    }

    func instant<ViewController: UIViewController>(_ viewController: ViewController,
                                                   acceptHandler: @escaping ((ViewController) -> Void)) -> AcceptViewController {
        let instantViewController = AcceptViewController(viewController: viewController)

        func makeBarButtonItem(title: String, action: Selector) -> UIBarButtonItem {
            return .init(title: title, style: .plain, target: instantViewController, action: action)
        }
        instantViewController.navigationItem.leftBarButtonItem = makeBarButtonItem(title: "Decline",
                                                                                   action: #selector(instantViewController.declineButtonPressed))
        instantViewController.navigationItem.rightBarButtonItem = makeBarButtonItem(title: "Accept",
                                                                                    action: #selector(instantViewController.acceptButtonPressed))
        instantViewController.acceptHandler = {
            instantViewController.navigationController?.popViewController(animated: true)
            acceptHandler(viewController)
        }
        instantViewController.declineHandler = {
            instantViewController.navigationController?.popViewController(animated: true)
        }
        return instantViewController
    }
}
