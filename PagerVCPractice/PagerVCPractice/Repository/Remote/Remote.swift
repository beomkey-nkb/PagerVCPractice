//
//  RemoteProtocol.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/02/13.
//

import Foundation
import Combine

enum RemoteError: Error {
    case notURL
    case notExsitedResponse
    case requestError(_ statusCode: Int)
}

struct Remote: RemoteProtocol { }

protocol RemoteProtocol {
    func requestAndDecode<T: Decodable>(_ api: HttpAPI, parameters: [String: Any]?) -> AnyPublisher<T, Error>
    func requestData(_ api: HttpAPI, parameters: [String: Any]?) -> AnyPublisher<Data, Error>
}

extension RemoteProtocol {
    
    var splashKey: String {
        return "xGefBiH6cEj19h9oljE5wioVY5jKjuCAgi4piJwFIwk"
    }
    
    func requestAndDecode<T: Decodable>(_ api: HttpAPI, parameters: [String: Any]? = nil) -> AnyPublisher<T, Error> {
        guard let url = URL(string: api.path)
        else { return Fail<T, Error>(error: RemoteError.notURL).eraseToAnyPublisher() }
        
        switch api.method {
        case .GET:
            return requestGetAPI(url: url, parameters: parameters)
                .checkResponseAndDecode(type: T.self)
        case .POST:
            return requestPostAPI(url: url, parameters: parameters)
                .checkResponseAndDecode(type: T.self)
        }
    }
    
    func requestData(_ api: HttpAPI, parameters: [String: Any]? = nil) -> AnyPublisher<Data, Error> {
        guard let url = URL(string: api.path)
        else { return Fail<Data, Error>(error: RemoteError.notURL).eraseToAnyPublisher() }
        
        switch api.method {
        case .GET:
            return requestGetAPI(url: url, parameters: parameters)
                .getResponseData()
        case .POST:
            return requestPostAPI(url: url, parameters: parameters)
                .getResponseData()
        }
    }
    
    private func requestPostAPI(url: URL, parameters: [String: Any]? = nil) -> URLSession.DataTaskPublisher {
        let paramtersData = try? JSONSerialization.data(withJSONObject: parameters ?? [:])
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = paramtersData
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
    }
    
    private func requestGetAPI(url: URL, parameters: [String: Any]? = nil) -> URLSession.DataTaskPublisher {
        var urlComponent = URLComponents(string: url.absoluteString)
        urlComponent?.queryItems = (parameters ?? [:]).map { key, value in
            return URLQueryItem(name: key, value: "\(value)")
        }
        
        guard let url = urlComponent?.url
        else { fatalError("[🔥fatal] not exsit url.") }
        
        return URLSession.shared.dataTaskPublisher(for: url)
    }
}

private extension Publisher where Self == URLSession.DataTaskPublisher {
    func checkResponseAndDecode<T: Decodable>(type: T.Type) -> AnyPublisher<T, Error> {
        return self.tryMap { element in
            guard let response = element.response as? HTTPURLResponse
            else { throw RemoteError.notExsitedResponse }
            
            guard response.statusCode == 200
            else { throw RemoteError.requestError(response.statusCode) }
            
            return element.data
        }
        .decode(type: T.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    }
    
    func getResponseData() -> AnyPublisher<Data, Error> {
        return self.tryMap { element in
            guard let response = element.response as? HTTPURLResponse
            else { throw RemoteError.notExsitedResponse }
            
            guard response.statusCode == 200
            else { throw RemoteError.requestError(response.statusCode) }
            
            return element.data
        }
        .compactMap { $0 }
        .eraseToAnyPublisher()
    }
}

private extension URLSession.DataTaskPublisher {
    static func empty() -> AnyPublisher<Output, Error> {
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }
}
