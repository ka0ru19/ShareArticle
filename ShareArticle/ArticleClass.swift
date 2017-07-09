//
//  ArticleClass.swift
//  ShareArticle
//
//  Created by Wataru Inoue on 2017/06/11.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit
import AlamofireImage
import OpenGraph

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
    
    // udのdictionaryから端末で扱うためのデータ型に変換するメソッド // デバック用
    init?(title: String, urlString: String, dateString: String, comment: String?) {
        // dateString -> "2017/06/22 12:34:56"
        self.title = title
        self.url = URL(string: urlString)
        self.date = Date(dateString: dateString)
        self.comment = comment
        print("init Article done. title: \(self.title as String)") // "as 型名"がないとOptionalになる
    }
    
    // udのdictionaryから端末で扱うためのデータ型に変換するメソッド
    init?(from udDict: Dictionary<String, Any>){
        self.title = udDict["title"] as? String ?? "no-title"
        self.url = URL(string: udDict["urlString"] as? String ?? String("https://www.apple.com/"))
        self.date = udDict["date"] as! Date
        if let comment = udDict["comment"] as? String {
            self.comment = comment
        }
        print("init Article done. title: \(self.title as String)")
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
        dict["comment"] = self.comment
        print("changed to ud Dict: \(dict)")
        return dict
    }
}

extension Article {
    func requestSetImageOnTableView(imageView iv: UIImageView?, tableView tv: UITableView) {
        // MARK: urlからサムネイル画像のurlを非同期で取得してimageviewに表示
        OpenGraph.fetch(url: self.url) { og, error in
            // 非同期で返ってくる
            
            guard let imageUrlString = og?[.image] else {
                print("no-imageUrlString")
                return
            }
            
            guard let imageUrl = URL(string: imageUrlString) else {
                return
            }
            
            iv?.af_setImage(withURL: imageUrl,
                            placeholderImage: nil,
                            filter: nil,
                            progress: nil,
                            progressQueue: DispatchQueue.main,
                            imageTransition: .noTransition,
                            runImageTransitionIfCached: false,
                            completion: { response in
                                
                                tv.reloadData() // tableViewをreloadする
                                guard let image = response.result.value else {
                                    print("サムネイルの取得に失敗: \(self.title as String)")
                                    return
                                }
                                print("サムネイルの取得完了: \(self.title as String)")
                                self.image = image
            })
        }
    }
    
    func requestSetImage(reloadTargetTableView rttv: UITableView?) {
        // MARK: urlからサムネイル画像のurlを非同期で取得してself.imageにセット
        OpenGraph.fetch(url: self.url) { og, error in
            // 非同期で返ってくる
            
            guard let imageUrlString = og?[.image] else {
                print("no-imageUrlString")
                return
            }
            
            guard let imageUrl = URL(string: imageUrlString) else {
                return
            }
            
            let CACHE_SEC : TimeInterval = 2 * 60; //2分キャッシュ
            let req = URLRequest(url: imageUrl,
                                 cachePolicy: .returnCacheDataElseLoad,
                                 timeoutInterval: CACHE_SEC);
            let conf =  URLSessionConfiguration.default;
            let session = URLSession(configuration: conf, delegate: nil, delegateQueue: OperationQueue.main);
            
            session.dataTask(with: req, completionHandler:
                { (data, resp, err) in
                    if let imageData = data {
                        self.image = UIImage(data: imageData)
                        print("サムネイルの取得完了: \(self.title as String)")
                        rttv?.reloadData()
                    }
                    if (error != nil) {
                        print("【警告】サムネイルの取得に失敗: \(self.title as String)")
                        print("AsyncImageView:Error \(String(describing: err?.localizedDescription))");
                    }
            }).resume();
        }
    }
}

extension Array where Element: Article {
    // [Article]同士を比較して差分だけ追加、削除するメソッドを作る
    func replace(newArray nArray: [Article]) {
        
    }
}
