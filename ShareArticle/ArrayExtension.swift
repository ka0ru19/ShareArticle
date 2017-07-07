//
//  ArrayExtension.swift
//  ShareArticle
//
//  Created by Wataru Inoue on 2017/07/07.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

extension Array where Element: Equatable {
    typealias E = Element
    
    func subtracting(_ other: [E]) -> [E] {
        return self.flatMap { element in
            if (other.filter { $0 == element }).count == 0 {
                return element
            } else {
                return nil
            }
        }
    }
    
    mutating func subtract(_ other: [E]) {
        self = subtracting(other)
    }
}

/* usage
 
 var a = [1, 2, 3, 4]
 let b = [8, 2, 3, 9]
 
 let sub1 = a.subtracting(b)
 sub1 // => [1, 4]
 a // => [1, 2, 3, 4]
 a.subtract(b)
 a // => [1, 4]
 
 */
