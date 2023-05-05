//
//  UIView+Extension.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/03/05.
//

import Foundation
import UIKit

extension UIView {
    
    var safeTopAnchor: NSLayoutYAxisAnchor {
        return self.safeAreaLayoutGuide.topAnchor
    }
    
    var safeTrailingAnchor: NSLayoutXAxisAnchor {
        return self.safeAreaLayoutGuide.trailingAnchor
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        return self.safeAreaLayoutGuide.bottomAnchor
    }
    
    var safeLeadingAnchor: NSLayoutXAxisAnchor {
        return self.safeAreaLayoutGuide.leadingAnchor
    }
}
