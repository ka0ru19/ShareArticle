//
//  ArticleClass.swift
//  ShareArticle
//
//  Created by Wataru Inoue on 2017/06/11.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

class Article {
    // title, url, date は必須。
    var title: String! // 記事タイトル
    var url: URL! // 記事リンク
    var date: Date! // 記事の保存日時
    var image: UIImage? // サムネイル
    var comment: String? // ユーザが入力する記事に対するコメント

    // 初めて記事を保存するとき
    init?(title: String, url: URL) {
        self.title = title
        self.url = url
        date = Date()
    }
    
    // udのdictionaryから端末で扱うためのデータ型に変換するメソッド
    init?(title: String, urlString: String, dateString: String, imageNsData: NSData?, comment: String?) {
        // dateString -> "2017/06/22 12:34:56"
        self.title = title
        self.url = URL(string: urlString)
        self.date = Date(dateString: dateString)
        if let data = imageNsData{
        self.image = UIImage(data: data as Data)
        }
        self.comment = comment
        print("init Article done. title: \(self.title as String)") // "as 型名"がないとOptionalになる
    }
    
    func setImage(image: UIImage?) {
        self.image = image
    }
    
    func setComment(comment: String?) {
        self.comment = comment
    }
    
    // userDefaultで管理できる型にキャストする
    func change2UdDict() -> Dictionary<String, Any> {
        var dict: Dictionary<String, Any> = [:]
        dict["title"] = self.title
        dict["urlString"] = String(describing: self.url as URL) // "as URL"がないとOptional
        dict["date"] = self.date
        if let img = self.image {
            dict["imageNsData"] = UIImageJPEGRepresentation(img, 1.0) as Data?
        }
        dict["comment"] = self.comment
        print("changed to ud Dict: \(dict)")
        return dict
    }
}