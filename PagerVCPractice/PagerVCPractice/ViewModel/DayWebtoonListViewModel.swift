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
    
    private var imageLoaderUsecase = ImageLoaderUsecase.factory()
    private let currentPage: Int
    private let changeOffsetYSubject = CurrentValueSubject<CGFloat?, Never>.init(nil)
    private var cancellables = Set<AnyCancellable>()
    
    var changeOffsetY: AnyPublisher<CGFloat, Never> {
        return changeOffsetYSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    init(currentPage: Int) {
        self.currentPage = currentPage
        super.init()
        self.observeTrigger()
    }
    
    override func bindParentAction(_ publisher: AnyPublisher<MainPagerParentAction, Never>) {
        publisher
            .sink { [weak self] action in
                guard let self = self else { return }
                switch action {
                case let .changeOffset(offset):
                    self.changeOffsetYSubject.send(offset)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    private func observeTrigger() {
        imageLoaderUsecase
            .loadPhotos(page: currentPage, perPage: 28)
            .map { $0.map { $0.toWebtoonImageCellViewModel() } }
            .assertNoFailure()
            .assign(to: \.dataSource, on: self)
            .store(in: &cancellables)
    }
}

// MARK: Interactor

extension DayWebtoonListViewModel {
    
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
