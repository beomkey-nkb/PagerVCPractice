//
//  RandomImageListViewModel.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/03/05.
//

import Foundation
import Combine

protocol DayWebtoonListListner {
    func childCollectionView(current offsetY: CGFloat, isAnimated: Bool)
}

final class DayWebtoonListViewModel: VMChild<MainPagerParentAction, DayWebtoonListListner> {
    typealias PagedListUsecaseType = PagenationUsecase<Int, UnsplashPhoto>
    @Published var dataSource: [WebtoonImageCellViewModel] = []
    
    private var photoPageListUsecase: PagedListUsecaseType
    private var imageLoaderUsecase = ImageLoaderUsecase.factory()
    
    private var isScrollableCollectionViewSubject = PassthroughSubject<Bool, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        let pageAPI = Self.unsplashPhotoPagingAPI(usecase: self.imageLoaderUsecase)
        self.photoPageListUsecase = PagenationUsecase(api: pageAPI)
        super.init()
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
}

// MARK: Interactor

extension DayWebtoonListViewModel {
    
    func nextImagePage() {
        photoPageListUsecase.loadNextPage()
    }
    
    func deliverCollectionViewOffsetY(_ offsetY: CGFloat, isAnimated: Bool = false) {
        listner?.childCollectionView(current: offsetY, isAnimated: isAnimated)
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
