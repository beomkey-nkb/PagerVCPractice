//
//  WebtoonListFooterView.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/05/05.
//

import Foundation
import UIKit

final class WebtoonListFooterView: UICollectionReusableView {
    private let backgroundView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupLayout()
        self.setupStyling()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Presentable

extension WebtoonListFooterView {
    
    func setupLayout() {
        var constraints = [NSLayoutConstraint]()
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        constraints += [
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -16),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 16),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupStyling() {
        backgroundView.backgroundColor = .lightGray
    }
}
