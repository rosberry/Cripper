//
//  Copyright © 2018 Rosberry. All rights reserved.
//

import UIKit

final class AppRouter: BaseRouter<UIViewController>, AlertRoute {

    init(viewController: UIViewController) {
        super.init()
        self.viewController = viewController
    }
}
