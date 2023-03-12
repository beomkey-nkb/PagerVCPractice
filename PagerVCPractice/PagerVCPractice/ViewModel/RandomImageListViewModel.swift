//
//  RandomImageListViewModel.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/03/05.
//

import Foundation
import Combine

final class RandomImageListViewModel {
    typealias PagedListUsecaseType = PagenationUsecase<Int, UnsplashPhoto>
    @Published var dataSource: [RandomImageCellViewModel] = []
    
    private var photoPageListUsecase: PagedListUsecaseType
    private var imageLoaderUsecase = ImageLoaderUsecase.factory()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let pageAPI = Self.unsplashPhotoPagingAPI(usecase: self.imageLoaderUsecase)
        self.photoPageListUsecase = PagenationUsecase(api: pageAPI)
    }
    
    static private func unsplashPhotoPagingAPI(usecase: ImageLoaderUsecase) -> PagedListUsecaseType.PageAPI {
        return { direction in
            guard let cursor = direction?.cursor
            else { return Empty().eraseToAnyPublisher() }
            return usecase.loadPhotos(page: cursor)
                .map { Page(nextCursor: cursor+1, items: $0) }
                .eraseToAnyPublisher()
        }
    }
    
    func loadRandomDataSource() {
        (0..<30)
            .map { $0 }
            .publisher
            .setFailureType(to: Error.self)
            .flatMap { [weak self] _ -> AnyPublisher<Data, Error> in
                guard let self = self
                else { return .empty() }
                return self.imageLoaderUsecase
                    .loadRamdomImage()
            }
            .scan([Data](), { $0 + [$1] })
            .assertNoFailure()
            .map(\.mappedRandomImageCellViewModel)
            .assign(to: \.dataSource, on: self)
            .store(in: &cancellables)
    }
    
    
}

private extension Array where Element == Data? {
    var mappedRandomImageCellViewModel: [RandomImageCellViewModel] {
        return self
            .compactMap { $0 }
            .enumerated()
            .map { offset, data in
                return RandomImageCellViewModel(
                    imageData: data,
                    webtoonName: "webtoon" + "\(offset)",
                    authorName: "author" + "\(offset)",
                    starGrade: Double(offset)
                )
            }
    }
}
