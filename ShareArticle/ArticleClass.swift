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
    var title: String? // 記事タイトル
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
        print("init Article done. title: \(title as String)") // "as 型名"がないとOptionalになる
    }
    
    // udのdictionaryから端末で扱うためのデータ型に変換するメソッド
//    init?(from udDict: Dictionary<String, Any>){
//        self.title = udDict["title"] as? String
//        self.url = URL(string: udDict["urlString"] as! String)
//        self.date = udDict["date"] as! Date
//        if let comment = udDict["comment"] as? String {
//            self.comment = comment
//        }
//        print("init Article done. title: \(self.title ?? "no-title")")
//    }
    
    // firebaseのdatabaseからクラスオブジェクトに変換する
    init?(from fbDict: Dictionary<String, String>) {
        self.title = fbDict["title"]
        self.url = URL(string: fbDict["url"] ?? "")
        self.date = Date(dateString: fbDict["date"] ?? Date().string())
        self.comment = fbDict["comment"]
        print("Article init done. title: \(self.title ?? "no-title")")
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
        dict["urlString"] = self.url.absoluteString
        dict["date"] = self.date
        dict["comment"] = self.comment
        print("changed to ud Dict: \(dict)")
        return dict
    }
    
    // firebaseのdatabaseで管理できる型にキャストする
    func change2FbDict() -> Dictionary<String, String> {
        var dict: Dictionary<String, String> = [:]
        dict["title"] = self.title
        dict["url"] = self.url.absoluteString
        dict["date"] = self.date.string()
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
            
            guard
                let imageUrlString = og?[.image],
                let imageUrl = URL(string: imageUrlString) else {
                    print("no-imageUrlString")
                    return
            }
            
            iv?.af_setImage(withURL: imageUrl,
                            placeholderImage: UIImage(named: "thumbnail_nowLoading.png"),
                            filter: nil,
                            progress: nil,
                            progressQueue: DispatchQueue.main,
                            imageTransition: .noTransition,
                            runImageTransitionIfCached: false,
                            completion: { response in
                                
                                tv.reloadData() // tableViewをreloadする
                                guard let image = response.result.value else {
                                    print("サムネイルの取得に失敗: \(self.title ?? "no-title")")
                                    return
                                }
                                print("サムネイルの取得完了: \(self.title ?? "no-title")")
                                self.image = image
            })
        }
    }
    
    func requestSetImage(reloadTargetTableView rttv: UITableView?, indexPath ip: IndexPath) {
        // MARK: urlからサムネイル画像のurlを非同期で取得してself.imageにセット
        if self.image != nil { return }
        self.image = UIImage(named: "thumbnail_nowLoading.png")
        OpenGraph.fetch(url: self.url) { og, error in
            // 非同期で返ってくる
            
            guard
                let imageUrlString = og?[.image],
                let imageUrl = URL(string: imageUrlString)  else {
                    print("no-imageUrlString")
                    self.image = nil
                    return
            }
            
            let CACHE_SEC : TimeInterval = 2 * 60 //2分キャッシュ
            let req = URLRequest(url: imageUrl,
                                 cachePolicy: .returnCacheDataElseLoad,
                                 timeoutInterval: CACHE_SEC)
            let conf =  URLSessionConfiguration.default
            let session = URLSession(configuration: conf, delegate: nil, delegateQueue: OperationQueue.main)
            
            session.dataTask(with: req, completionHandler:
                { (data, resp, err) in
                    if let imageData = data {
                        self.image = UIImage(data: imageData)
                        print("サムネイルの取得完了: \(self.title ?? "no-title")")
                    } else {
                        print("【警告】サムネイルの取得に失敗: \(self.title ?? "no-title")")
                        self.image = nil
                        if let error = err {
                            print("AsyncImageView:Error \(error.localizedDescription)")
                        }
                    }
                    //                    rttv?.reloadData()
                    rttv?.reloadRows(at: [ip], with: .fade)
            }).resume()
        }
    }
    
    func requestSetTitle(reloadTargetTableView rttv: UITableView?) {
        // MARK: urlからtitleを非同期で取得してself.titleにセット、tableViewをリロード
        OpenGraph.fetch(url: self.url) { og, error in
            // 非同期で返ってくる
            guard let titleString = og?[.title] else {
                return
            }
            self.title = titleString
            rttv?.reloadData()
        }
    }
    
}

extension Array where Element: Article {
    // [Article]同士を比較して差分だけ追加、削除するメソッド
    func replace(newArray nArray: [Article]) -> [Article] {
        var oldTempArray = self
        var resultArray: [Article] = []
        
        for (nIndex, n) in nArray.enumerated() {
            if oldTempArray.count == 0 {
                resultArray.append(nArray[nIndex])
                continue
            }
            for (oIndex, o) in oldTempArray.enumerated() {
                if n.url == o.url && n.date == o.date {
                    resultArray.append(o)
                    oldTempArray.remove(at: oIndex)
                    break
                }
                if oIndex == oldTempArray.count - 1 {
                    resultArray.append(n)
                }
            }
        }
        
        return resultArray
        
    }
}
