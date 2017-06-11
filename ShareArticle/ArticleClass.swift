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
    var title: String!
    var url: URL!
    var date: Date!
    var image: UIImage?
    var comment: String?

    
    init?(title: String, url: URL) {
        self.title = title
        self.url = url
        date = Date()
    }
    
    func set(title: String, urlString: String, dateString: String, imageNsData: NSData?, comment: String?) {
        // dateString -> "2017/06/22 12:34:56"
        self.title = title
        self.url = URL(string: urlString)
        self.date = Date(dateString: dateString)
        if let data = imageNsData{
        self.image = UIImage(data: data as Data)
        }
        self.comment = comment
    }
    
    func addImage(image: UIImage?) {
        self.image = image
    }
    
    func addComment(comment: String?) {
        self.comment = comment
    }
    
}
