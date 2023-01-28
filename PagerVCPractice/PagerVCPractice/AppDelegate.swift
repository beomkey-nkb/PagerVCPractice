//
//  AppDelegate.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/01/28.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MainPagerViewController()
        window?.makeKeyAndVisible()
        return true
    }

}

