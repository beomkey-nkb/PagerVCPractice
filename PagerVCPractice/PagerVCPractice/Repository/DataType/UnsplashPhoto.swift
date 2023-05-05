//
//  UnsplashPhoto.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/03/12.
//

import Foundation

struct UnsplashPhoto: Decodable, Hashable {
    let id: String
    let urls: UnsplashURL
    let user: UnsplashUser
    let likes: Int
    
    static func == (lhs: UnsplashPhoto, rhs: UnsplashPhoto) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct UnsplashUser: Decodable {
    let name: String
}

struct UnsplashURL: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}
