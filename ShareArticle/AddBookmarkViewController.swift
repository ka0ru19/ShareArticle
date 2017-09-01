//
//  AddBookmarkViewController.swift
//  ShareArticle
//
//  Created by Wataru Inoue on 2017/08/31.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

class AddBookmarkViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    
    var pageInfo: [Any] = [] // 前のviewで必ず値をもらってくる: [String, URL]の配列
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard
            let title = pageInfo[0] as? String,
            let url = pageInfo[1] as? URL else {
                return
        }
        
        titleTextField.borderStyle = .line
        titleTextField.text = title
        
        urlTextField.borderStyle = .none
        urlTextField.text = url.absoluteString
        urlTextField.isEnabled = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        
        // 追加して大丈夫かどうかのバリデーション
        
        guard let titleText = titleTextField.text ,
            let urlText = urlTextField.text else { return }
        
        if titleText == "" || urlText == ""  {
            print("何か文字を入力しないと保存できないよ")
            return
        }
        
        // 追加の処理
        let ud = UserDefaults.standard
        var bookmarkDictArray = ud.array(forKey: "bookmarkDictArray") as? [Dictionary<String, String>] ?? []
        bookmarkDictArray.append(["title": titleText, "urlText": urlText])
        print(bookmarkDictArray)
        ud.set(bookmarkDictArray, forKey: "bookmarkDictArray")
        
        let alert = UIAlertController(title: "完了", message: "ブックマークにこのページを保存しました", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: { (_) -> Void in
            self.dismiss(animated: true, completion: nil)
            
        })
        
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
}
