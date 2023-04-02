//
//  MainPagerViewModel.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/02/13.
//

import Foundation
import Combine

enum MainPagerParentAction { }

final class MainPagerViewModel: VMParent<MainPagerParentAction> {
    private var childCollectionViewOffsetYSubject = PassthroughSubject<CGFloat, Never>()
    private var topConstantIsAnimatedSubject = PassthroughSubject<Bool, Never>()
}

extension MainPagerViewModel: DayWebtoonListListner {
    
    private var topConstant: AnyPublisher<CGFloat, Never> {
        return childCollectionViewOffsetYSubject
            .map { -($0 + 300) }
            .map { $0 <= -250 ? -250 : $0 }
            .map { $0 > 0 ? 0 : $0 }
            .eraseToAnyPublisher()
    }
    
    var headerTopAreaConstantPublisher: AnyPublisher<(CGFloat, Bool), Never> {
        return topConstant
            .combineLatest(topConstantIsAnimatedSubject)
            .eraseToAnyPublisher()
    }

    func childCollectionView(current offsetY: CGFloat, isAnimated: Bool) {
        childCollectionViewOffsetYSubject.send(offsetY)
        topConstantIsAnimatedSubject.send(isAnimated)
        
    }
}
