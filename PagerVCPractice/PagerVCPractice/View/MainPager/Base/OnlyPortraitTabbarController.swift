//
//  OnlyPortraitTabbarController.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/05/05.
//

import Foundation
import UIKit

final class OnlyPortraitTabbarController: UITabBarController {
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
}
