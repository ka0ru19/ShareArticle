//
//  DateFormatExtension.swift
//  ShareArticle
//
//  Created by Wataru Inoue on 2017/06/11.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

private let formatter: DateFormatter = {
    let formatter: DateFormatter = DateFormatter()
    formatter.timeZone = NSTimeZone.system
    formatter.locale = Locale(identifier: "ja_JP")
    formatter.calendar = Calendar(identifier: .gregorian)
    return formatter
}()

public extension Date {
    
    // Date→String
    func string(format: String = "yyyy/MM/dd' 'HH:mm:ssZ") -> String {
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    // Date -> 2017/06/21
    func dateString(format: String = "yyyy/MM/dd") -> String {
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    // Date -> 12:34
    func timeString(format: String = "HH:mm") -> String {
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    // String → Date
    init?(dateString: String, dateFormat: String = "yyyy/MM/dd' 'HH:mm:ssZ") {
        formatter.dateFormat = dateFormat
        guard let date = formatter.date(from: dateString) else { return nil }
        self = date
    }
    
}

/* 使用例
Date().string(format: "yyyy/MM/dd") // 2017/02/26
Date(dateString: "2016-02-26 10:17:30 +0900")  // Date
 */
