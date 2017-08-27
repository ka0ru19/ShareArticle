//
//  PostFromUIActivityViewController.swift
//  ShareArticle
//
//  Created by Wataru Inoue on 2017/07/01.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

class PostFromUIActivityViewController: UIViewController {
    
    var postFromUiAc: PostFromUIActivity?
    var activityItems: [Any]?
    
    let textView = UITextView()
    
    var articleTitle: String?
    var articleUrl: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tempTitle: String?
        var tempUrl: URL?
        guard let aItems = activityItems else {
            closeView()
            return
        }
        for item in aItems {
            print(String(describing: type(of: item)))
            if String(describing: type(of: item)) == "__NSCFString" {
                tempTitle = item as? String
                continue
            }
            if String(describing: type(of: item)) == "NSURL" {
                tempUrl = item as? URL
                continue
            }
        }
        guard let url = tempUrl else {
            closeView()
            return
        }
        
        articleTitle = tempTitle
        articleUrl = url.absoluteURL
        print("articleTitle: \(articleTitle ?? "no-Title")")
        print("articleUrl: \(articleUrl)")
        
        
        self.modalPresentationStyle = .overCurrentContext // 背景の透過を許可
        self.view.backgroundColor = UIColor(colorLiteralRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        
        /****** baseのview ******/
        let baseView = UIView(frame: CGRect(x: 0, y: 0, width: 300 , height: 200))
        baseView.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 100) // ここで親viewのpositonを変更できる
        baseView.layer.masksToBounds = true
        baseView.layer.cornerRadius = 10.0
        baseView.backgroundColor = UIColor.green
        
        let inputView = UIView(frame: CGRect(x: 0, y: 0, width: baseView.frame.width , height: baseView.frame.height))
        inputView.frame.origin = baseView.bounds.origin // ここだけはboundsを引いてくる
        inputView.backgroundColor = UIColor(red: 225/255, green: 226/255, blue: 225/255, alpha: 1.0) // rgb(225,226,225)
        
        /****** header、mainInput、optionの base view & separateBar view ******/
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: inputView.bounds.width , height: 36))
        headerView.frame.origin = inputView.frame.origin
        headerView.backgroundColor = UIColor.saRed
        
        let mainHeadSeparateView = UIView(frame: CGRect(x: 0, y: 0, width: inputView.bounds.width, height: 1))
        mainHeadSeparateView.frame.origin = CGPoint(x: inputView.frame.origin.x, y: headerView.bottomY)
        mainHeadSeparateView.backgroundColor = UIColor.gray
        
        let guideTextLabel = UILabel(frame: CGRect(x: 0, y: 0, width: inputView.bounds.width - 4 * 2, height: 20))
        guideTextLabel.frame.origin = CGPoint(x: inputView.frame.origin.x + 4, y: mainHeadSeparateView.bottomY)
        guideTextLabel.backgroundColor = UIColor.clear
        guideTextLabel.text = "記事へのコメントも一緒に保存できるよ:D"
        guideTextLabel.textAlignment = .center
        guideTextLabel.font = UIFont.systemFont(ofSize: CGFloat(12))
        
        let mainInputView = UIView(frame: CGRect(x: 0, y: 0, width: inputView.bounds.width, height: 200))
        mainInputView.frame.origin = CGPoint(x: inputView.frame.origin.x, y: guideTextLabel.bottomY)
        
        /****** header view ******/
        let headerViewsHeight: CGFloat = 30
        let headerViewsOriginY = (headerView.frame.height - headerViewsHeight) / 2
        
        let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 90 , height: headerViewsHeight))
        cancelButton.frame.origin = CGPoint(x: 0, y: headerViewsOriginY)
        cancelButton.addTarget(self, action: #selector(self.closeView), for: .touchUpInside)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        
        let finishButton = UIButton(frame: CGRect(x: 0, y: 0, width: 90 , height: headerViewsHeight))
        finishButton.frame.origin = CGPoint(x: inputView.frame.width -  finishButton.frame.width, y: headerViewsOriginY)
        finishButton.addTarget(self, action: #selector(self.post), for: .touchUpInside)
        finishButton.setTitle("Done", for: .normal)
        finishButton.setTitleColor(UIColor.white, for: .normal)
        
//        let headerImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: headerView.frame.width - 90 - 90 , height: headerViewsHeight))
//        headerImageView.frame.origin = CGPoint(x: cancelButton.bottomX, y: headerViewsOriginY)
        let headerImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: headerViewsHeight , height: headerViewsHeight))
        headerImageView.center = headerView.center
        headerImageView.contentMode = .scaleAspectFit
        headerImageView.image = UIImage(named: "icon_180.png")
        headerImageView.clipsToBounds = true
//        headerImageView.layer.masksToBounds = true
        headerImageView.layer.cornerRadius = 6.0
        
        /****** mainInput view ******/
        print(inputView.bottomY)
        print(guideTextLabel.bottomY)
        let textViewHeight = inputView.bottomY - guideTextLabel.bottomY - 8 * 2
        textView.frame = CGRect(x: 0, y: 0, width: 300 - 8 * 2, height: textViewHeight)
        textView.frame.origin = CGPoint(x: 8, y: 8)
        textView.layer.cornerRadius = 8.0
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.darkGray.cgColor
        textView.text = ""
        textView.becomeFirstResponder()
        
        //        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300 - 4 * 2, height: 60))
        //        titleLabel.frame.origin = CGPoint(x: 4, y: textView.bottomY)
        //        titleLabel.numberOfLines = 2
        //        titleLabel.text = articleTitle
        //
        //        let urlLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300 - 4 * 2, height: 16))
        //        urlLabel.frame.origin = CGPoint(x: 4, y: titleLabel.bottomY)
        //        urlLabel.text = String(describing: articleUrl)
        
        /****** option view ******/
        
        
        /****** view の統合 ******/
        headerView.addSubview(cancelButton)
        headerView.addSubview(finishButton)
        headerView.addSubview(headerImageView)
        mainInputView.addSubview(textView)
        
        inputView.addSubview(headerView)
        inputView.addSubview(mainHeadSeparateView)
        inputView.addSubview(guideTextLabel)
        inputView.addSubview(mainInputView)
        baseView.addSubview(inputView)
        self.view.addSubview(baseView)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func post() {
        print("これを読了した->\(self.activityItems ?? ["error: no activityItems value"])")
        
        // TODO: ここでデータベースに保存
        let ud = UserDefaults.standard
        var articleUdArray = ud.array(forKey: "articleUdArray") as? [[String: Any]] ?? []
        
        var postUdDic: [String:Any] = [:]
        
        
        postUdDic["title"] = articleTitle
        postUdDic["urlString"] = articleUrl.absoluteString
        postUdDic["date"] = Date()
        postUdDic["comment"] = self.textView.text
        articleUdArray.append(postUdDic)
        print(postUdDic)
        
        print("ほぞんするよ")
        print(articleUdArray)
        ud.set(articleUdArray, forKey: "articleUdArray")
        
        closeView()
    }
    
    func closeView() {
        postFromUiAc?.perform()
    }
    
}

extension PostFromUIActivityViewController: UITextViewDelegate {
    // 最初からキーボードを出す
}
