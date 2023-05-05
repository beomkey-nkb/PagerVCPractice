//
//  DayWebtoonHorizontalListCell.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/05/05.
//

import Foundation
import UIKit
import Kingfisher

final class DayWebtoonHorizontalListCell: UICollectionViewCell {
    private var webtoonImageView = UIImageView()
    private var webtoonIndexLabel = UILabel()
    private var nameLabel = UILabel()
    private var priorityLabel = UILabel()
    
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
        
        webtoonImageView.image = nil
        webtoonIndexLabel.text = nil
        nameLabel.text = nil
    }
    
    func configure(_ cellViewModel: WebtoonImageCellViewModel, index: Int) {
        webtoonImageView.kf.setImage(with: URL(string: cellViewModel.imageURL))
        webtoonIndexLabel.setupStrokeText("\(index + 1)")
        nameLabel.text = cellViewModel.authorName
    }
    
}

// MARK: Presentable

private extension DayWebtoonHorizontalListCell {
    
    func setupLayout() {
        var constraints = [NSLayoutConstraint]()
        
        [webtoonImageView, webtoonIndexLabel, nameLabel, priorityLabel].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        contentView.addSubview(webtoonImageView)
        constraints += [
            webtoonImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            webtoonImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            webtoonImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            webtoonImageView.heightAnchor.constraint(equalToConstant: 120)
        ]
        
        contentView.addSubview(webtoonIndexLabel)
        constraints += [
            webtoonIndexLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -60),
            webtoonIndexLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8)
        ]
        
        contentView.addSubview(nameLabel)
        constraints += [
            nameLabel.topAnchor.constraint(equalTo: webtoonImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: webtoonIndexLabel.trailingAnchor, constant: 2),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor)
        ]
        
        contentView.addSubview(priorityLabel)
        constraints += [
            priorityLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3),
            priorityLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            priorityLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor)
        ]
        
        webtoonIndexLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        priorityLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupStyling() {
        webtoonImageView.contentMode = .scaleToFill
        webtoonImageView.clipsToBounds = true
        webtoonImageView.layer.cornerRadius = 5
        
        nameLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        priorityLabel.font = .systemFont(ofSize: 9, weight: .regular)
        priorityLabel.textColor = .green
        priorityLabel.text = "priority 99%"
    }
}

private extension UILabel {
    func setupStrokeText(_ text: String) {
        let strokeTextAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.strokeColor : UIColor.white,
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.strokeWidth : -4.0,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 40, weight: .heavy)
        ]

        self.attributedText = NSMutableAttributedString(string: text, attributes: strokeTextAttributes)
    }
}
