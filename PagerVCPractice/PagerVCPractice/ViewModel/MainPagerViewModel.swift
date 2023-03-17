//
//  MainPagerViewModel.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/02/13.
//

import Foundation
import Combine

enum MainPagerParentAction {
    case collectionViewScrollable(_ isScrollable: Bool)
}

final class MainPagerViewModel {
    private var isScrollableCollectionViewSubject: CurrentValueSubject<Bool, Never> = .init(false)
    private var actionSubject = PassthroughSubject<MainPagerParentAction, Never>()
    
    var parentActionPublisher: AnyPublisher<MainPagerParentAction, Never> {
        return actionSubject.eraseToAnyPublisher()
    }
    
    var isScrollablePublisher: AnyPublisher<Bool, Never> {
        return isScrollableCollectionViewSubject.eraseToAnyPublisher()
    }
    
    var isScrollableCollectionView: Bool {
        return isScrollableCollectionViewSubject.value
    }
    
    func setupIsScrollableChildCollectionView(_ isScrollable: Bool) {
        actionSubject.send(.collectionViewScrollable(isScrollable))
        isScrollableCollectionViewSubject.send(isScrollable)
    }
}

// MARK: DayWebtoonList Listener

extension MainPagerViewModel: DayWebtoonListener {
    
    func setupIsScrollableCollectionView(_ isScrollable: Bool) {
        isScrollableCollectionViewSubject.send(isScrollable)
    }
}
