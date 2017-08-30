//
//  FirebaseDatabaseManager.swift
//  ShareArticle
//
//  Created by Wataru Inoue on 2017/08/30.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit
import Firebase

class FirebaseDatabaseManager {
    
    let rootRef = Database.database().reference()
    let fireUser: User? = Auth.auth().currentUser
    
    // MARK: - 取得
    func getArcitleArray(vc: ArticleListViewController) {
        // Firebaseのデータベースにアクセスする下準備
        guard let uid = fireUser?.uid else { return }
        let articleIdListRef = rootRef.child("user-list").child(uid).child("article-list")
        
        // リクエストを送信
        articleIdListRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let valueArray = snapshot.value as? [String: AnyObject] else {
                vc.failedGetArcitleArray(message: "snapshot.valueを[String: AnyObject]に変換できなかったため")
                return // このブロックを抜ける
            }
            print("取得完了: valueArray: -> \(valueArray)")
            
            var tempDictArray: [Dictionary<String, String>] = []
            for v in valueArray {
//                guard let dict = v.value as? Dictionary<String, String> else { continue }
//                tempDictArray.append(dict)
                guard let dict = v.value as? Dictionary<String, String> else { continue }
                tempDictArray.append(dict.union(other: ["selfArticleID": v.key]))
            }
            vc.successLoadDictArray(dictArray: tempDictArray)
            tempDictArray.removeAll(keepingCapacity: true)
        })
    }
    
    // MARK: - 削除
    func removeArcitle(articleID: String, vc: ArticleListViewController) {
        guard let uid = fireUser?.uid else { return }
        let articleIdListRef = rootRef.child("user-list").child(uid).child("article-list")
        
        // 工事中
        articleIdListRef.child(articleID).removeValue(completionBlock: { (error, ref) in
            if let err = error {
                print(err.localizedDescription)
            } else {
                print("正常にdatabaseからremoveされました. id: \(articleID)")
            }
        })
    }
    
    // MARK: - 投稿
    func postNewArcitle(newValue: [String:String], vc: PostFromUIActivityViewController){
        guard let uid = fireUser?.uid else { return }
        let articleIdListRef = rootRef.child("user-list").child(uid).child("article-list")
        
        let newRef = articleIdListRef.childByAutoId()
        let newKey = newRef.key
        
        let newValueWithKey = newValue.union(other: ["selfArticleID": newKey])
        
        articleIdListRef.child(newKey).setValue(newValueWithKey, withCompletionBlock: {(error: Error?, ref) in
            if let err = error {
                // 失敗
                vc.failedGetArcitleArray(message: err.localizedDescription)
            } else {
                // 成功
                vc.successPostNewArcitle()
            }
            
            
        })
        
    }
}
