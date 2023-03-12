//
//  RandomImageListViewModel.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/03/05.
//

import Foundation
import Combine

final class DayWebtoonListViewModel {
    typealias PagedListUsecaseType = PagenationUsecase<Int, UnsplashPhoto>
    @Published var dataSource: [WebtoonImageCellViewModel] = []
    
    private var photoPageListUsecase: PagedListUsecaseType
    private var imageLoaderUsecase = ImageLoaderUsecase.factory()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let pageAPI = Self.unsplashPhotoPagingAPI(usecase: self.imageLoaderUsecase)
        self.photoPageListUsecase = PagenationUsecase(api: pageAPI)
        
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
            starGrade: Double(self.likes)
        )
    }
}
