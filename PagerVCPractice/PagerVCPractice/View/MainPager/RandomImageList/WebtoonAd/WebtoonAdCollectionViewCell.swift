//
//  WebtoonAdCollectionViewCell.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/04/18.
//

import Foundation
import UIKit

final class WebtoonAdCollectionViewCell: UICollectionViewCell {
    private var mainContainerView = UIView()
    private var summaryLabel = UILabel()
    private var idLabel = UILabel()
    private var nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupLayout()
        self.setupStyling()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        var constraints = [NSLayoutConstraint]()
        
        [mainContainerView, summaryLabel, idLabel, nameLabel].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        contentView.addSubview(mainContainerView)
        constraints += [
            mainContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
        
        mainContainerView.addSubview(summaryLabel)
        constraints += [
            summaryLabel.centerYAnchor.constraint(equalTo: mainContainerView.centerYAnchor),
            summaryLabel.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor, constant: 20),
            summaryLabel.widthAnchor.constraint(equalToConstant: 40),
            summaryLabel.heightAnchor.constraint(equalToConstant: 20)
        ]
        
        mainContainerView.addSubview(idLabel)
        constraints += [
            idLabel.centerYAnchor.constraint(equalTo: mainContainerView.centerYAnchor),
            idLabel.leadingAnchor.constraint(equalTo: summaryLabel.trailingAnchor, constant: 8)
        ]
        
        mainContainerView.addSubview(nameLabel)
        constraints += [
            nameLabel.centerYAnchor.constraint(equalTo: mainContainerView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: idLabel.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: mainContainerView.trailingAnchor, constant: -20)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupStyling() {
        mainContainerView.backgroundColor = .blue
        mainContainerView.layer.cornerRadius = 5
        
        summaryLabel.textAlignment = .center
        summaryLabel.layer.cornerRadius = 2
        summaryLabel.layer.borderWidth = 1
        summaryLabel.layer.borderColor = UIColor.white.cgColor
        summaryLabel.textColor = .white
        summaryLabel.text = "화제작"
        summaryLabel.font = .systemFont(ofSize: 12)
        
        idLabel.textAlignment = .center
        idLabel.textColor = .white
        idLabel.font = .systemFont(ofSize: 15, weight: .bold)
        
        nameLabel.textAlignment = .center
        nameLabel.textColor = .white.withAlphaComponent(0.7)
        nameLabel.font = .systemFont(ofSize: 14)
    }
}

extension WebtoonAdCollectionViewCell {
    
    func configure(_ photo: UnsplashPhoto) {
        let colorValue = CGFloat(abs(photo.urls.thumb.hashValue) % 255)
        
        mainContainerView.backgroundColor = .init(
            red: colorValue / 255.0,
            green: colorValue / 255.0,
            blue: colorValue / 255.0,
            alpha: 1.0
        )
        
        idLabel.text = photo.id
        nameLabel.text = photo.user.name
    }
}
