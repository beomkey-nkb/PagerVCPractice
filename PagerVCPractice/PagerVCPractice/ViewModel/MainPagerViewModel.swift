//
//  MainPagerViewModel.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/02/13.
//

import Foundation
import Combine

enum MainPagerParentAction {
    case changeFocus(_ index: Int)
}

final class MainPagerViewModel: VMParent<MainPagerParentAction> {
    private var childCollectionViewOffsetYSubject = PassthroughSubject<CGFloat, Never>()
    private var topConstantIsAnimatedSubject = PassthroughSubject<Bool, Never>()
    private var currentFocusSubject: CurrentValueSubject<Int, Never>
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        self.currentFocusSubject = .init(Self.loadCurrentDay())
        super.init()
        self.observeTrigger()
    }
    
    private static func loadCurrentDay() -> Int {
        guard var dayNumber = Date().dayNumberOfWeek()
        else { return 0 }
        dayNumber -= 2
        return dayNumber < 0 ? 6 : dayNumber
    }
    
    private func observeTrigger() {
        currentFocusSubject
            .eraseToAnyPublisher()
            .sink { [weak self] index in
                self?.transferSubject.send(.changeFocus(index))
            }
            .store(in: &cancellables)
    }
    
    func scrollTo(_ index: Int) {
        currentFocusSubject.send(index)
    }
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

extension MainPagerViewModel: WebtoonDayListner {
    
    func changeFocus(index: Int) {
        currentFocusSubject.send(index)
    }
}

private extension Date {
    
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}
