//
//  ImageLoaderRepository.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/02/13.
//

import Foundation
import Combine

protocol ImageLoaderRepositoryProtocol {
    func loadRandomImage() -> AnyPublisher<Data, Error>
}

struct ImageLoaderRepository: ImageLoaderRepositoryProtocol {
    var remote: RemoteProtocol
    
    init(remote: RemoteProtocol) {
        self.remote = remote
    }
    
    func loadRandomImage() -> AnyPublisher<Data, Error> {
        return self.remote.requestData(.randomImage)
    }
}

extension ImageLoaderRepository {
    static func factory() -> ImageLoaderRepository {
        return ImageLoaderRepository(remote: Remote())
    }
}
