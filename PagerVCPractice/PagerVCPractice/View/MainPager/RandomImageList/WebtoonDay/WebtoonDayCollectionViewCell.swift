//
//  WebtoonDayCollectionViewCell.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/04/29.
//

import Foundation
import UIKit

final class WebtoonDayCollectionViewCell: UICollectionViewCell {
    private var dayLabel = UILabel()
    private var bottomFocusView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupStyling()
    }
    
    override func prepareForReuse() {
        bottomFocusView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        var constraints = [NSLayoutConstraint]()
        [dayLabel, bottomFocusView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        contentView.addSubview(dayLabel)
        constraints += [
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        
        contentView.addSubview(bottomFocusView)
        constraints += [
            bottomFocusView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomFocusView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomFocusView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomFocusView.heightAnchor.constraint(equalToConstant: 5)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupStyling() {
        
    }
    
    func configure(_ cellViewModel: WebtoonDayCellViewModel) {
        dayLabel.text = cellViewModel.dayString
        bottomFocusView.backgroundColor = cellViewModel.isFocus ? .black : .white
    }
}
