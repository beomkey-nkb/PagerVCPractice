//
//  WebtoonAdViewModel.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/04/15.
//

import Foundation
import Combine

final class WebtoonAdViewModel {
    private var imageLoaderUsecase = ImageLoaderUsecase.factory()
    private var cancellables = Set<AnyCancellable>()
    @Published var dataSource: [UnsplashPhoto] = []
    
    init() {
        observeTrigger()
    }
    
    func observeTrigger() {
        imageLoaderUsecase
            .loadPhotos(page: 1, perPage: 20)
            .assertNoFailure()
            .assign(to: \.dataSource, on: self)
            .store(in: &cancellables)
    }
}
