//
//  PostFromUIActivity.swift
//  ShareArticle
//
//  Created by Wataru Inoue on 2017/06/19.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//
//  アクティビティコントローラからこのアプリに登録するUIActivity。上段に表示されるアイコン。

import UIKit

class PostFromUIActivity: UIActivity {
    var postFromAcVc: PostFromUIActivityViewController!
    
    override class var activityCategory: UIActivityCategory {
        // 上段に表示する
        return .share
    }
    
    override var activityType: UIActivityType? {
        guard let bundleId = Bundle.main.bundleIdentifier else { return nil }
        return UIActivityType(rawValue: bundleId + "\(self.classForCoder)")
    }
    
    override var activityTitle: String? {
        return "ShareArticle"
    }
    
    override var activityImage: UIImage? {
        return UIImage(named: "inocci-icon-uiac")
    }
    
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        // 次のviewcontrollerに引き継ぐ
        super.prepare(withActivityItems: activityItems)
        postFromAcVc = PostFromUIActivityViewController()
        postFromAcVc.postFromUiAc = self
        postFromAcVc.activityItems = activityItems
    }
    
    override var activityViewController: UIViewController? {
        return postFromAcVc
    }
    
    override func perform() {
        activityDidFinish(true)
    }

}
