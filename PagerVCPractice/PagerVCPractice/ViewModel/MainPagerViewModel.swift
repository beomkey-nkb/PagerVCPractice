//
//  MainPagerViewModel.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/02/13.
//

import Foundation
import Combine

enum MainPagerParentAction { }

final class MainPagerViewModel: VMParent<MainPagerParentAction> {
    
}

extension MainPagerViewModel: DayWebtoonListListner {

    func childCollectionView(current offsetY: CGFloat) {
        print("beomkey - offset: \(offsetY)")
    }
}
