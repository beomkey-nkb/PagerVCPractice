//
//  RandomImageCollectionViewCell.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/03/05.
//

import Foundation
import UIKit

final class RandomImageCollectionViewCell: UICollectionViewCell {
    private var imageView = UIImageView()
    private var webtoonNameLabel = UILabel()
    private var webtoonDiscriptionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupStyling()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        webtoonNameLabel.text = nil
        webtoonDiscriptionLabel.text = nil
    }
    
    func configure(_ cellViewModel: RandomImageCellViewModel) {
        imageView.image = UIImage(data: cellViewModel.imageData)
        webtoonNameLabel.text = cellViewModel.webtoonName
        webtoonDiscriptionLabel.text = cellViewModel.discriptionText
    }
}

// MARK: Presentable

extension RandomImageCollectionViewCell {
    
    func setupLayout() {
        var constraints = [NSLayoutConstraint]()
        
        [imageView, webtoonNameLabel, webtoonDiscriptionLabel].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        contentView.addSubview(imageView)
        constraints += [
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            imageView.heightAnchor.constraint(equalToConstant: 64)
        ]
        
        contentView.addSubview(webtoonNameLabel)
        constraints += [
            webtoonNameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            webtoonNameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            webtoonNameLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
        ]
        
        contentView.addSubview(webtoonDiscriptionLabel)
        constraints += [
            webtoonDiscriptionLabel.topAnchor.constraint(equalTo: webtoonNameLabel.bottomAnchor, constant: 5),
            webtoonDiscriptionLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            webtoonDiscriptionLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            webtoonDiscriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupStyling() {
        imageView.contentMode = .scaleToFill
        webtoonNameLabel.textAlignment = .left
        webtoonDiscriptionLabel.textAlignment = .left
    }
}
