//
//  Array+Extension.swift
//  PagerVCPractice
//
//  Created by 남기범 on 2023/03/12.
//

import Foundation

extension Array where Element: Hashable {
    var duplicateRemoved: [Element] {
        var dict = [Int: Void]()
        return self.filter { element in
            guard dict[element.hashValue] == nil else {
                return false
            }
            
            dict[element.hashValue] = ()
            return true
        }
    }
}
