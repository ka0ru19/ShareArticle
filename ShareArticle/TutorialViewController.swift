//
//  TutorialViewController.swift
//  ShareArticle
//
//  Created by Wataru Inoue on 2017/08/27.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController , UIScrollViewDelegate {

    var pageControl: UIPageControl!
    var scrollView: UIScrollView!
    var pageImageArray: [UIImage] = [UIImage(named: "Tutorial01.jpg")!,
                                     UIImage(named: "Tutorial02.jpg")!,
                                     UIImage(named: "Tutorial03.jpg")!,
                                     UIImage(named: "Tutorial04.jpg")!,
                                     UIImage(named: "Tutorial05.jpg")!] // ここで宣言する
    
    enum udKey: String {
        case isFirstTime = "isFirstTime"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalPresentationStyle = .overCurrentContext // 背景の透過を許可
        self.view.backgroundColor = UIColor(colorLiteralRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        
        let width = self.view.frame.maxX
        let height = self.view.frame.maxY
//        let pageSizeNum = self.pageImageArray.count
        
        // scrollViewの作成
        scrollView = UIScrollView(frame: self.view.frame)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: CGFloat(pageImageArray.count) * width, height: 0)
        self.view.addSubview(scrollView)
        
        // 各ページの作成
        for i in 0 ..< pageImageArray.count {
            let img = pageImageArray[i]
            let iv = UIImageView(image: img)
            iv.contentMode = .scaleAspectFill
            iv.frame = CGRect(x: CGFloat(i) * width, y: 0, width: width, height: height - 50)
            scrollView.addSubview(iv)
        }
        
        // UIPageControllの作成
        pageControl = UIPageControl(frame: CGRect(x: 0, y: height - 50, width: width, height: 50))
        pageControl.backgroundColor = UIColor.gray
        pageControl.numberOfPages = pageImageArray.count
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false
        self.view.addSubview(pageControl)
        
        // 閉じるボタンの追加
        let button = UIButton(frame: CGRect(x: width - 50, y: 100, width: 40, height: 40))
        button.backgroundColor = UIColor.gray
        button.addTarget(self, action: #selector(TutorialViewController.closeButtonTapped), for: .touchUpInside)
        button.setTitle("X", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 20.0
        self.view.addSubview(button)
        
        let ud = UserDefaults.standard
        ud.set(false, forKey: udKey.isFirstTime.rawValue)
        ud.synchronize()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if fmod(scrollView.contentOffset.x, scrollView.frame.maxX) == 0 {
            pageControl.currentPage = Int(scrollView.contentOffset.x/scrollView.frame.maxX)
        }
    }
    
    // 初回起動時かどうかの確認
    public func isFirstTime() -> Bool{
        return UserDefaults.standard.bool(forKey: udKey.isFirstTime.rawValue)
    }
}
