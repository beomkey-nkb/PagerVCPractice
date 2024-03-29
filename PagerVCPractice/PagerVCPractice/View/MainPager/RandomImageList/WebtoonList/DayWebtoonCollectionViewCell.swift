//
//  RandomImageCollectionViewCell.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/03/05.
//

import Foundation
import UIKit
import Kingfisher

final class DayWebtoonCollectionViewCell: UICollectionViewCell {
    private var imageView = UIImageView()
    private var webtoonNameLabel = UILabel()
    private var authorNameLabel = UILabel()
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
    
    func configure(_ cellViewModel: WebtoonImageCellViewModel) {
        imageView.kf.setImage(with: URL(string: cellViewModel.imageURL))
        webtoonNameLabel.text = cellViewModel.webtoonName
        authorNameLabel.text = cellViewModel.authorName
        webtoonDiscriptionLabel.text = cellViewModel.discriptionText
    }
}

// MARK: Presentable

extension DayWebtoonCollectionViewCell {
    
    func setupLayout() {
        var constraints = [NSLayoutConstraint]()
        
        [imageView, webtoonNameLabel, authorNameLabel, webtoonDiscriptionLabel].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        contentView.addSubview(imageView)
        constraints += [
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 155)
        ]
        
        contentView.addSubview(webtoonNameLabel)
        constraints += [
            webtoonNameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            webtoonNameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            webtoonNameLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
        ]
        
        contentView.addSubview(authorNameLabel)
        constraints += [
            authorNameLabel.topAnchor.constraint(equalTo: webtoonNameLabel.bottomAnchor),
            authorNameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            authorNameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: 0)
        ]
        
        contentView.addSubview(webtoonDiscriptionLabel)
        constraints += [
            webtoonDiscriptionLabel.topAnchor.constraint(equalTo: webtoonNameLabel.bottomAnchor),
            webtoonDiscriptionLabel.leadingAnchor.constraint(equalTo: authorNameLabel.trailingAnchor),
            webtoonDiscriptionLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            webtoonDiscriptionLabel.bottomAnchor.constraint(equalTo: authorNameLabel.bottomAnchor)
        ]
        
        authorNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        webtoonDiscriptionLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupStyling() {
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        
        webtoonNameLabel.textAlignment = .left
        webtoonNameLabel.font = .systemFont(ofSize: 15, weight: .medium)
        webtoonNameLabel.textColor = .black
        
        authorNameLabel.textAlignment = .left
        authorNameLabel.font = .systemFont(ofSize: 12, weight: .regular)
        authorNameLabel.textColor = .systemGray
        
        webtoonDiscriptionLabel.textAlignment = .left
        webtoonDiscriptionLabel.font = .systemFont(ofSize: 12, weight: .regular)
        webtoonDiscriptionLabel.textColor = .systemGray
    }
}
