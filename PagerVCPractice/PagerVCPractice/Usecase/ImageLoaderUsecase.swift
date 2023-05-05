//
//  ImageLoaderUsecase.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/02/13.
//

import Foundation
import Combine

final class ImageLoaderUsecase {
    private var repository: ImageLoaderRepositoryProtocol
    
    init(repository: ImageLoaderRepositoryProtocol) {
        self.repository = repository
    }
    
    func loadRamdomImage() -> AnyPublisher<Data, Error> {
        return self.repository.loadRandomImage()
    }
    
    func loadPhotos(page: Int, perPage: Int = 10) -> AnyPublisher<[UnsplashPhoto], Error> {
        return self.repository.loadPhotos(page: page, perPage: perPage)
    }
}

extension ImageLoaderUsecase {
    static func factory() -> ImageLoaderUsecase {
        return ImageLoaderUsecase(repository: ImageLoaderRepository.factory())
    }
}
