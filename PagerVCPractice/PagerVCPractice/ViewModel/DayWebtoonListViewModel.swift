//
//  RandomImageListViewModel.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/03/05.
//

import Foundation
import Combine

protocol DayWebtoonListener: AnyObject {
    func setupIsScrollableCollectionView(_ isScrollable: Bool)
}

final class DayWebtoonListViewModel {
    typealias PagedListUsecaseType = PagenationUsecase<Int, UnsplashPhoto>
    @Published var dataSource: [WebtoonImageCellViewModel] = []
    weak var listener: DayWebtoonListener?
    
    private var photoPageListUsecase: PagedListUsecaseType
    private var imageLoaderUsecase = ImageLoaderUsecase.factory()
    
    private var isScrollableCollectionViewSubject = PassthroughSubject<Bool, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    var isScrollableCollectionView: AnyPublisher<Bool, Never> {
        return isScrollableCollectionViewSubject.eraseToAnyPublisher()
    }
    
    init(parentActionPublisher: AnyPublisher<MainPagerParentAction, Never>) {
        let pageAPI = Self.unsplashPhotoPagingAPI(usecase: self.imageLoaderUsecase)
        self.photoPageListUsecase = PagenationUsecase(api: pageAPI)
        
        self.bindParentActionPublisher(parentActionPublisher)
        self.observeTrigger()
    }
    
    static private func unsplashPhotoPagingAPI(usecase: ImageLoaderUsecase) -> PagedListUsecaseType.PageAPI {
        return { direction in
            let cursor = direction?.cursor ?? 1
            return usecase.loadPhotos(page: cursor, perPage: 15)
                .map { Page(nextCursor: cursor+1, items: $0) }
                .eraseToAnyPublisher()
        }
    }
    
    private func observeTrigger() {
        photoPageListUsecase
            .pagedList
            .assertNoFailure()
            .map { $0.map { $0.toWebtoonImageCellViewModel() } }
            .assign(to: \.dataSource, on: self)
            .store(in: &cancellables)
        
        photoPageListUsecase.renewPagedList()
    }
    
    private func bindParentActionPublisher(_ publisher: AnyPublisher<MainPagerParentAction, Never>) {
        publisher
            .sink(receiveValue: { [weak self] action in
                switch action {
                case .collectionViewScrollable(let isScrollable):
                    self?.isScrollableCollectionViewSubject.send(isScrollable)
                }
            })
            .store(in: &cancellables)
    }
    
    func passToParentIsScrollable(_ isScrollable: Bool) {
        listener?.setupIsScrollableCollectionView(isScrollable)
    }
    
    func nextImagePage() {
        photoPageListUsecase.loadNextPage()
    }
}

private extension UnsplashPhoto {
    func toWebtoonImageCellViewModel() -> WebtoonImageCellViewModel {
        return WebtoonImageCellViewModel(
            imageURL: self.urls.thumb,
            webtoonName: self.id,
            authorName: self.user.name,
            starCount: self.likes
        )
    }
}
