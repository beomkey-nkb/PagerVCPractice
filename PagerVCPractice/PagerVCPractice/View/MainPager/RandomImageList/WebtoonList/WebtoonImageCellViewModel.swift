//
//  RandomImageCellViewModel.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/03/05.
//

import Foundation

struct WebtoonImageCellViewModel: Hashable {
    let imageURL: String
    let webtoonName: String
    let authorName: String
    let starCount: Int
    
    var discriptionText: String {
        return " / ★ \(starCount)"
    }
}
