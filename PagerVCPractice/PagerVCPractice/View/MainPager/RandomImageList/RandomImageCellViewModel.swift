//
//  RandomImageCellViewModel.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/03/05.
//

import Foundation

struct RandomImageCellViewModel: Hashable {
    let imageData: Data
    let webtoonName: String
    let authorName: String
    let starGrade: Double
    
    var discriptionText: String {
        let starGradeString = String(format: "%.2f", starGrade)
        return authorName + " / " + starGradeString
    }
}
