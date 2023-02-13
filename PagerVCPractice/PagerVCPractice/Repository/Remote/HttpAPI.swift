//
//  HttpAPI.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/02/13.
//

import Foundation

enum HTTPMethod: String {
    case GET
    case POST
}

enum HttpAPI {
    case randomImage
    
    var path: String {
        switch self {
        case .randomImage:
            return "https://source.unsplash.com/random"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .randomImage:
            return .GET
        }
    }
    
}

extension HttpAPI {
    
}
