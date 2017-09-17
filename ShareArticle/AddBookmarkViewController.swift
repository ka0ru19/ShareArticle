//
//  AddBookmarkViewController.swift
//  ShareArticle
//
//  Created by Wataru Inoue on 2017/08/31.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

class AddBookmarkViewController: UIViewController {
    
    let titleTextField = UITextField(frame: CGRect.zero) // ブックマークのタイトルを入力する
    let urlTextField = UITextField(frame: CGRect.zero) // urlを表示する 編集不能
    var pageInfo: [Any] = [] // 前のviewで必ず値をもらってくる: [String, URL]の配列
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let navigationController = self.navigationController else { return }
        navigationController.navigationBar.barTintColor = UIColor.lightRed
        navigationController.navigationBar.tintColor = UIColor.black
        
        guard
            let title = pageInfo[0] as? String,
            let url = pageInfo[1] as? URL else {
                return
        }
        
        // MARK: navigatioinBarの設定
        let leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped(_:)))
        self.navigationItem.leftBarButtonItems = [leftBarButtonItem]
        let rightBarButtonItem = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(saveButtonTapped(_:)))
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem]
        navigationController.navigationBar.topItem?.title = "ブックマークに追加"
        
        // viewの設定
        let margin: CGFloat = 16
        let largeMargin : CGFloat = margin * 3
        let width = self.view.frame.width - margin * 2
        
        titleTextField.frame = CGRect(x: margin, y: ViewSize.navigationbarBottomY + margin, width: width, height: 36)
        titleTextField.borderStyle = .line
        titleTextField.text = title
        titleTextField.textAlignment = .left
        titleTextField.contentVerticalAlignment = .bottom
        titleTextField.becomeFirstResponder()
        
        urlTextField.frame = CGRect(x: margin, y: titleTextField.bottomY + margin, width: width, height: 30)
        urlTextField.font = UIFont.systemFont(ofSize: 12)
        urlTextField.borderStyle = .none
        urlTextField.text = url.absoluteString
        urlTextField.isEnabled = false
        
        let guideImageView = UIImageView() //
        let guideImage = UIImage(named: "bookmark_access.png")!
        let largeWidth = self.view.frame.width - largeMargin * 2
        let height = largeWidth / guideImage.size.width * guideImage.size.height
        guideImageView.frame = CGRect(x: largeMargin, y: urlTextField.bottomY + largeMargin, width: largeWidth, height: height)
        guideImageView.image = guideImage
        guideImageView.layer.borderColor = UIColor.saRed.cgColor
        guideImageView.layer.borderWidth = 1.0
        
        self.view.addSubview(titleTextField)
        self.view.addSubview(urlTextField)
        self.view.addSubview(guideImageView)
        
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
        ud.set(bookmarkDictArray, forKey: "bookmarkDictArray")
        
        let alert = UIAlertController(title: "完了", message: "ブックマークにこのページを保存しました", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: { (_) -> Void in
            self.dismiss(animated: true, completion: nil)
            
        })

        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
}
