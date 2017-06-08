//
//  AppDelegate.swift
//  copycat
//
//  Created by Austin Tucker on 6/2/17.
//  Copyright © 2017 Austin Tucker. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        FirebaseApp.configure()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        let viewModel = ViewModel()
        _ = viewModel.firebaseLogsOut()
    }
}

