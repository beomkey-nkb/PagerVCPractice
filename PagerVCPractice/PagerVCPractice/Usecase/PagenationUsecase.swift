//
//  PagenationUsecase.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/03/12.
//

import Foundation
import Combine

enum PageDirection<CursorType> {
    case prev(CursorType)
    case next(CursorType)
    
    var cursor: CursorType? {
        switch self {
        case let .prev(cursor), let .next(cursor):
            return cursor
        }
    }
}

struct Page<CursorType, DataModelType> {
    var prevCursor: CursorType?
    var nextCursor: CursorType?
    var items: [DataModelType]
    
    init(prevCursor: CursorType? = nil, nextCursor: CursorType? = nil, items: [DataModelType]) {
        self.prevCursor = prevCursor
        self.nextCursor = nextCursor
        self.items = items
    }
}

final class PagenationUsecase<CursorType, DataModelType: Hashable> {
    typealias PageModel = Page<CursorType, DataModelType>
    typealias PageAPI = (PageDirection<CursorType>?) -> AnyPublisher<PageModel, Error>
    typealias DataModelType = DataModelType
    
    private let api: PageAPI
    private var prevCursor: CursorType?
    private var nextCursor: CursorType?
    
    private let renewSubject = PassthroughSubject<Void, Error>()
    private let nextLoadSubject = PassthroughSubject<Void, Error>()
    private let prevLoadSubject = PassthroughSubject<Void, Error>()
    private let errorSubject = PassthroughSubject<Void, Error>()
    private let dataSubject = CurrentValueSubject<[DataModelType], Error>.init([])
    private var cancellables = Set<AnyCancellable>()
    
    init(api: @escaping PageAPI) {
        self.api = api
        observeTrigger()
    }
    
    private func observeTrigger() {
        
        renewSubject
            .flatMap { [weak self] _ in
                guard let self = self
                else { return Empty<PageModel, Error>().eraseToAnyPublisher() }
                return self.loadData(direction: nil)
            }
            .assertNoFailure()
            .sink(receiveValue: { [weak self] page in
                self?.updateCursor(page)
                self?.dataSubject.send(page.items)
            })
            .store(in: &cancellables)
        
        nextLoadSubject
            .flatMap { [weak self] _ in
                guard let self = self, let nextCursor = self.nextCursor
                else { return Empty<PageModel, Error>().eraseToAnyPublisher() }
                return self.loadData(direction: PageDirection.next(nextCursor))
            }
            .assertNoFailure()
            .sink(receiveValue: { [weak self] page in
                self?.updateCursor(page)
                self?.dataSubject.send(page.items)
            })
            .store(in: &cancellables)
            
        prevLoadSubject
            .flatMap { [weak self] _ in
                guard let self = self, let prevCursor = self.prevCursor
                else { return Empty<PageModel, Error>().eraseToAnyPublisher() }
                return self.loadData(direction: PageDirection.prev(prevCursor))
            }
            .assertNoFailure()
            .sink(receiveValue: { [weak self] page in
                self?.updateCursor(page)
                self?.dataSubject.send(page.items)
            })
            .store(in: &cancellables)
    }
}

// MARK: interaction

extension PagenationUsecase {
    func renewPagedList() {
        renewSubject.send(())
    }
    
    func loadNextPage() {
        nextLoadSubject.send(())
    }
    
    func loadPrevPage() {
        prevLoadSubject.send(())
    }
}

// MARK: Presenter

extension PagenationUsecase {
    var pagedList: AnyPublisher<[DataModelType], Error> {
        return dataSubject.eraseToAnyPublisher()
    }
}

private extension PagenationUsecase {
    func loadData(direction: PageDirection<CursorType>?) -> AnyPublisher<PageModel, Error> {
        return api(direction)
            .catch { [weak self] error in
                self?.errorSubject.send(completion: .failure(error))
                return Empty<PageModel, Error>(completeImmediately: true)
            }
            .eraseToAnyPublisher()
    }
    
    func updateCursor(_ page: PageModel) {
        prevCursor = page.prevCursor
        nextCursor = page.nextCursor
    }
}
