//
//  DictionaryExtension.swift
//  ShareArticle
//
//  Created by Wataru Inoue on 2017/08/30.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

public extension Dictionary {
    // 辞書型の結合
    public func union(other: Dictionary) -> Dictionary {
        var tmp = self
        other.forEach {tmp[$0.0] = $0.1}
        return tmp
    }
    public mutating func united(other: Dictionary) {
        other.forEach { self[$0.0] = $0.1 }
    }
}
