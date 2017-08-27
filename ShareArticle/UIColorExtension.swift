//
//  UIColorExtension.swift
//  ShareArticle
//
//  Created by Wataru Inoue on 2017/07/24.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

extension UIColor {
    static let saRed = colorWithHexString("FF0033")
    static let lightRed = colorWithHexString("FF8A80")
    
    // カラーコード変換
    static func colorWithHexString (_ hex:String) -> UIColor {
        
        let cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if ((cString as String).characters.count != 6) {
            return UIColor.gray
        }
        
        let rString = (cString as NSString).substring(with: NSRange(location: 0, length: 2))
        let gString = (cString as NSString).substring(with: NSRange(location: 2, length: 2))
        let bString = (cString as NSString).substring(with: NSRange(location: 4, length: 2))
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(
            red: CGFloat(Float(r) / 255.0),
            green: CGFloat(Float(g) / 255.0),
            blue: CGFloat(Float(b) / 255.0),
            alpha: CGFloat(Float(1.0))
        )
    }
}
