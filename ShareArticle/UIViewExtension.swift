//
//  UIViewExtension.swift
//  ShareArticle
//
//  Created by Wataru Inoue on 2017/06/11.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

extension UIView {
    var bottomX: CGFloat {
        get {
            return self.frame.origin.x + self.frame.size.width
        }
    }
    
    var bottomY: CGFloat {
        get {
            return self.frame.origin.y + self.frame.size.height
        }
    }
}
