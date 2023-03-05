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
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(_ cellViewModel: RandomImageCellViewModel) {
        imageView.image = UIImage(data: cellViewModel.imageData)
        webtoonNameLabel.text = cellViewModel.webtoonName
        webtoonDiscriptionLabel.text = cellViewModel.discriptionText
    }
}
