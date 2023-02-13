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
    
    func loadRamdomImage() -> AnyPublisher<Data?, Error> {
        return self.repository.loadRandomImage()
    }
}
