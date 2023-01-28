//
//  ViewController.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/01/28.
//

import UIKit
import OSLog

class ViewController: UIViewController {
    let label: UILabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        os_log("show good")
    }
}

