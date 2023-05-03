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
        let nav = UINavigationController(rootViewController: MainPagerViewController())
        nav.tabBarItem.tag = 0
        let tabbarController = UITabBarController()
        tabbarController.tabBar.tintColor = .black
        if #available(iOS 15.0, *) {
            tabbarController.tabBar.scrollEdgeAppearance = tabbarController.tabBar.standardAppearance
        }
        
        tabbarController.viewControllers = [nav]
        tabbarController.tabBar.items?.forEach({ item in
            item.title = "main"
            item.image = UIImage(named: "tabbarMain")
        })
        window?.rootViewController = tabbarController
        window?.makeKeyAndVisible()
        return true
    }
}

