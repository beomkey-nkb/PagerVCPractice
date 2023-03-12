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
    func loadPhotos(page: Int, perPage: Int) -> AnyPublisher<[UnsplashPhoto], Error>
}

struct ImageLoaderRepository: ImageLoaderRepositoryProtocol {
    var remote: RemoteProtocol
    
    init(remote: RemoteProtocol) {
        self.remote = remote
    }
    
    func loadRandomImage() -> AnyPublisher<Data, Error> {
        return self.remote.requestData(.randomImage)
    }
    
    func loadPhotos(page: Int, perPage: Int) -> AnyPublisher<[UnsplashPhoto], Error> {
        var parameters: [String: Any] = [:]
        parameters["page"] = page
        parameters["per_page"] = perPage
        return self.remote.requestAndDecode(.photos, parameters: parameters)
    }
}

extension ImageLoaderRepository {
    static func factory() -> ImageLoaderRepository {
        return ImageLoaderRepository(remote: Remote())
    }
}
