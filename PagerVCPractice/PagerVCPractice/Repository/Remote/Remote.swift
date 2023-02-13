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
}

extension RemoteProtocol {
    func requestAndDecode<T: Decodable>(_ api: HttpAPI, parameters: [String: Any]? = nil) -> AnyPublisher<T, Error> {
        guard let url = URL(string: api.path)
        else { return Fail<T, Error>(error: RemoteError.notURL).eraseToAnyPublisher() }
        
        switch api.method {
        case .GET:
            return requestGetAPI(url: url, parameters: parameters)
        case .POST:
            return requestPostAPI(url: url, parameters: parameters)
        }
    }
    
    private func requestPostAPI<T: Decodable>(url: URL, parameters: [String: Any]? = nil) -> AnyPublisher<T, Error> {
        let paramtersData = try? JSONSerialization.data(withJSONObject: parameters ?? [:])
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = paramtersData
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .checkResponseAndDecode(type: T.self)
    }
    
    private func requestGetAPI<T: Decodable>(url: URL, parameters: [String: Any]? = nil) -> AnyPublisher<T, Error> {
        var urlComponent = URLComponents(string: url.absoluteString)
        urlComponent?.queryItems = (parameters ?? [:]).map { key, value in
            return URLQueryItem(name: key, value: "\(value)")
        }
        
        guard let url = urlComponent?.url
        else { return Fail<T, Error>(error: RemoteError.notURL).eraseToAnyPublisher() }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .checkResponseAndDecode(type: T.self)
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
}
