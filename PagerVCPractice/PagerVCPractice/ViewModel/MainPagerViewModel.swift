//
//  MainPagerViewModel.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/02/13.
//

import Foundation
import Combine

final class MainPagerViewModel {
    private var isScrollableCollectionViewSubject: CurrentValueSubject<Bool, Never> = .init(false)
    
    var isScrollableCollectionView: Bool {
        return isScrollableCollectionViewSubject.value
    }
    
    func setupIsScrollableChildCollectionView(_ isScrollable: Bool) {
        isScrollableCollectionViewSubject.send(isScrollable)
    }
}
