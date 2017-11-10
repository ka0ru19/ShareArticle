//
//  ShareViewController.swift
//  Posty
//
//  Created by Wataru Inoue on 2017/11/11.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {
    
    let suiteName: String = "group.com.wataru.ShareArticle"
    let keyName: String = "shareData"
    
    var articleTitle = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // titleName
        self.title = "Posty"
        
        // TODO : - titleのテキストをアイコンの画像に変更する
        
        // color
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.backgroundColor = UIColor(red:1.0, green:0.75, blue:0.5, alpha:1.0)
        
        // postName
        guard let controller: UIViewController = self.navigationController?.viewControllers.first else { return }
        controller.navigationItem.rightBarButtonItem!.title = "保存"
        
        // 記事のタイトルを取得
        articleTitle = self.textView.text
        
        // 初期入力されているタイトルテキストを無くす
        self.textView.text = ""
        
        self.placeholder = "コメントを入力(任意)"
    }
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    override func didSelectPost() {
        let extensionItem: NSExtensionItem = self.extensionContext?.inputItems.first as! NSExtensionItem
        let itemProvider = extensionItem.attachments?.first as! NSItemProvider
        
        let publicUrlString = String(kUTTypeURL)  // "public.url"
        
        if itemProvider.hasItemConformingToTypeIdentifier(publicUrlString) {
            itemProvider.loadItem(forTypeIdentifier: publicUrlString, options: nil, completionHandler: { (item, error) in
                if let url: URL = item as? URL {
                    // 保存処理
                    guard let ud: UserDefaults = UserDefaults(suiteName: self.suiteName) else { return }
                    
                    let newArticleDict: [String: Any] = [
                        "title": self.articleTitle,
                        "url": url.absoluteString,
                        "date": Date(),
                        "comment": self.textView.text
                        
                    ]
                    //  FirebaseDatabaseManager().postNewArcitle(newValue: newArticleDict, vc: self)
                    
                    
                    if let pastArray = ud.array(forKey: self.keyName) {
                        ud.set(pastArray + [newArticleDict], forKey: self.keyName)
                    } else {
                        ud.set([newArticleDict], forKey: self.keyName)
                    }
                    
//                    ud.set(url.absoluteString, forKey: self.keyName)
                    ud.synchronize()
                    
                }
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
            })
        }
    }
    
    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
}
