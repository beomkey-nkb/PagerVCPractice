//
//  WebtoonDayViewModel.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/04/29.
//

import Foundation
import Combine

protocol WebtoonDayListner {
    func changeFocus(index: Int)
}

final class WebtoonDayViewModel: VMChild<MainPagerParentAction, WebtoonDayListner> {
    private let days = ["월", "화", "수", "목", "금", "토", "일"]
    private var currentFocusSubject: CurrentValueSubject<Int, Never>
    private var cancellables = Set<AnyCancellable>()
    
    @Published var dataSource: [WebtoonDayCellViewModel] = []
    
    init(focusIndex: Int) {
        self.currentFocusSubject = .init(focusIndex)
        super.init()
        self.observeTrigger()
    }
    
    override func bindParentAction(_ publisher: AnyPublisher<MainPagerParentAction, Never>) {
        publisher
            .sink { [weak self] action in
                switch action {
                case .changeFocus(let index):
                    self?.currentFocusSubject.send(index)
                }
            }
            .store(in: &cancellables)
    }
    
    private func observeTrigger() {
        currentFocusSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
            .map { [weak self] index in
                guard let self = self else { return [] }
                return self.days.enumerated().map { offset, day in
                    return WebtoonDayCellViewModel(
                        isFocus: offset == index,
                        dayString: day
                    )
                }
            }
            .assign(to: \.dataSource, on: self)
            .store(in: &cancellables)
    }
    
    func changeFocus(index: Int) {
        listner?.changeFocus(index: index)
        currentFocusSubject.send(index)
    }
}
