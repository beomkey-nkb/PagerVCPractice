//
//  UICollectionView+Extension.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/03/05.
//

import Foundation
import UIKit
import Combine

extension UICollectionView {
    
    func registerCell(cellType: UICollectionViewCell.Type, reuseIdentifier: String? = nil) {
        let reuseIdentifier = reuseIdentifier ?? String(describing: cellType.self)
        self.register(cellType, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func dequeueCell<T: UICollectionViewCell>(reuseIdentifier: String? = nil, indexPath: IndexPath) -> T {
        let reuseIdentifier = reuseIdentifier ?? String(describing: T.self)
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? T else {
            fatalError()
        }
        return cell
    }
    
    func registerSupplementaryView(viewType: UICollectionReusableView.Type,
                                   forSupplementaryViewOfKind: String = UICollectionView.elementKindSectionHeader,
                                   reuseIdentifier: String? = nil) {
        let reuseIdentifier = reuseIdentifier ?? String(describing: viewType.self)
        self.register(viewType, forSupplementaryViewOfKind: forSupplementaryViewOfKind, withReuseIdentifier: reuseIdentifier)
    }
    
    func dequeueSupplementaryView<T: UICollectionReusableView>(ofKind: String = UICollectionView.elementKindSectionHeader,
                                                               reuseIdentifier: String? = nil,
                                                               indexPath: IndexPath) -> T {
        let reuseIdentifier = reuseIdentifier ?? String(describing: T.self)
        guard let view = self.dequeueReusableSupplementaryView(ofKind: ofKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as? T else {
            fatalError()
        }
        return view
    }
    
    var scrollBottomHit: AnyPublisher<Void, Never> {
        return self.publisher(for: \.contentOffset)
            .compactMap { [weak self] offset -> Bool? in
                guard let self = self, offset.y != 0 else { return nil }
                return self.verticalScrollableHeight - self.frame.height <= offset.y
            }
            .filter { $0 }
            .map { _ in }
            .eraseToAnyPublisher()
     }
    
    var verticalScrollableHeight: CGFloat {
        let height = self.contentSize.height - self.frame.height + self.contentInset.top + self.contentInset.bottom
        return max(height, 0)
    }
}
