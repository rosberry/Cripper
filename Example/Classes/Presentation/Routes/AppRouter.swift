//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import UIKit
import Routes

final class AppRouter: BaseRouter<UIViewController>, AlertRoute {

    init(viewController: UIViewController) {
        super.init()
        self.viewController = viewController
    }
}
