//
//  WebtoonListHeaderView.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/05/05.
//

import Foundation
import UIKit

final class WebtoonListHeaderView: UICollectionReusableView {
    private let iconImageView = UIImageView()
    private let textLabel = UILabel()
    private let infoImageView = UIImageView()
    
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

extension WebtoonListHeaderView {
    
    func setupLayout() {
        var constraints = [NSLayoutConstraint]()
        [iconImageView, textLabel, infoImageView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addSubview(iconImageView)
        constraints += [
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ]
        
        addSubview(textLabel)
        constraints += [
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            textLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 5)
        ]
        
        addSubview(infoImageView)
        constraints += [
            infoImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            infoImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            infoImageView.widthAnchor.constraint(equalToConstant: 20),
            infoImageView.heightAnchor.constraint(equalToConstant: 20)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupStyling() {
        iconImageView.image = UIImage(named: "heart")
        iconImageView.tintColor = .black
        textLabel.text = "독자님들이 좋아하는 웹툰 랭킹!"
        textLabel.font = .systemFont(ofSize: 17, weight: .medium)
        infoImageView.image = UIImage(named: "info")
        infoImageView.tintColor = .lightGray
    }
}
