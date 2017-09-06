//
//  ConstDefine.swift
//  ShareArticle
//
//  Created by Wataru Inoue on 2017/07/12.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//
//  アプリ全体で頻繁に使うViewのSize定数を定義するファイル

import UIKit

struct ViewSize {
    static let navigationbarHeight: CGFloat = 44.0
    static let navigationbarBottomY: CGFloat = 64.0
    static let statusBarBottomY = navigationbarBottomY - navigationbarHeight
    static let toolbarHeight: CGFloat = 44.0
}
