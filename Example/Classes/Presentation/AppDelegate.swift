//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationCotroller = UINavigationController(rootViewController: ViewController())
        window?.rootViewController = navigationCotroller
        window?.makeKeyAndVisible()
        return true
    }
}

