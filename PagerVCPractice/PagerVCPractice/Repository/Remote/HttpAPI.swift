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
    case photos
    
    var path: String {
        switch self {
        case .randomImage:
            return "https://source.unsplash.com/random"
        case .photos:
            return "https://api.unsplash.com/photos"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .randomImage, .photos:
            return .GET
        }
    }
}
