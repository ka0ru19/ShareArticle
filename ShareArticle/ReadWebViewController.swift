//
//  ReadWebViewController.swift
//  ShareArticle
//
//  Created by Wataru Inoue on 2017/06/11.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit
import WebKit

class ReadWebViewController: UIViewController, WKNavigationDelegate {
    
    //    @IBOutlet weak var webView: UIWebView!
    let webView = WKWebView()
    let progressView = UIProgressView()
    let toolbar = UIToolbar()
    
    var backButtonItem: UIBarButtonItem!
    var nextButtonItem: UIBarButtonItem!
    var stopButtonItem: UIBarButtonItem!
    var loadButtonItem: UIBarButtonItem!
    var addBookmarkButtonItem: UIBarButtonItem!
    var actionButtonItem: UIBarButtonItem!
    
    var originUrl: URL! // 前のvcから引き継いでくる
    var currentURL: URL!
    
    var beginingPoint = CGPoint.zero // スクロール開始地点
    var isViewShowed: Bool = true // スクロールによるViewの表示/非表示を管理
    var isMovingToolbar: Bool = false // 表示が切り替わっている最中
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    }
    
    deinit {
        self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
        self.webView.removeObserver(self, forKeyPath: "loading")
        self.webView.stopLoading()
        self.webView.loadHTMLString("", baseURL: nil)
        self.progressView.setProgress(0.0, animated: true) // プログレスバーを消す
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        print("deinit ReadWebViewController")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        setNavigatinbarTitle(url: webView.url)
        if keyPath == "estimatedProgress"{
            //estimatedProgressが変更されたときに、setProgressを使ってプログレスバーの値を変更する。
            self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }else if keyPath == "loading"{
            UIApplication.shared.isNetworkActivityIndicatorVisible = webView.isLoading
            setAllControlButtonsStatus()
            if webView.isLoading {
                self.progressView.setProgress(0.1, animated: true)
            }else{
                //読み込みが終わったら0に
                self.progressView.setProgress(0.0, animated: false)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func onTappedBackButton(_ sender: UIBarButtonItem) {
        guard webView.canGoBack else { return }
        webView.goBack() // 戻る
    }
    
    func onTappedNextButton(_ sender: UIBarButtonItem) {
        guard webView.canGoForward else { return }
        webView.goForward() // 進む
    }
    func onTappedStopButton(_ sender: UIBarButtonItem) {
        webView.stopLoading() // 読み込み停止
    }
    
    func onTappedLoadButton(_ sender: UIBarButtonItem) {
        webView.reload() // 再度読み込み
    }
    
    func onTappedAddBookmarkButton(_ sender: UIBarButtonItem) {
        showAddBookMarkAlert()
    }
    
    func onTappedActionButton(_ sender: UIBarButtonItem) {
        showUiActivity()
    }
    
    
    private func setNavigatinbarTitle(url: URL?) {
        // vcのタイトルにホスト名を表示する
        guard let url = url else { return }
        if let component = URLComponents(string: url.absoluteString) {
            self.title = component.host
        }
    }
}

extension ReadWebViewController {
    
    func initView() {
        webView.frame = CGRect(x: 0, y: 0,
                               width: self.view.frame.size.width,
                               height: self.view.frame.size.height - ViewSize.navigationbarBottomY - ViewSize.toolbarHeight)
        webView.frame.origin = CGPoint(x: 0, y: ViewSize.navigationbarBottomY)
        webView.allowsBackForwardNavigationGestures = false // スワイプで戻るを禁止(tableViewの戻りとかぶるため)
        webView.uiDelegate = self
        webView.scrollView.delegate = self
        webView.navigationDelegate = self
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        self.view.addSubview(webView)
        
        //プログレスバーを生成(NavigationBar下)
        progressView.frame = CGRect(x: 0, y: self.navigationController!.navigationBar.frame.size.height  - 2,
                                    width: self.view.frame.size.width, height: 2)
        progressView.progressViewStyle = .bar
        self.navigationController?.navigationBar.addSubview(progressView)
        
        webView.load(URLRequest(url: originUrl))
        
        // ツールバーを生成
        toolbar.frame = CGRect(x: 0, y: webView.bottomY, width: self.view.frame.width, height: ViewSize.toolbarHeight)
        toolbar.barTintColor = UIColor.lightRed
        toolbar.tintColor = UIColor.black
        backButtonItem = UIBarButtonItem(image: IconImage.backImage(isOn: false), style: .plain, target: self, action: #selector(ReadWebViewController.onTappedBackButton(_:)))
        nextButtonItem = UIBarButtonItem(image: IconImage.nextImage(isOn: false), style: .plain, target: self, action: #selector(ReadWebViewController.onTappedNextButton(_:)))
        stopButtonItem = UIBarButtonItem(image: IconImage.stopImage(isOn: false), style: .plain, target: self, action: #selector(ReadWebViewController.onTappedStopButton(_:)))
        loadButtonItem = UIBarButtonItem(image: IconImage.loadImage(isOn: true), style: .plain, target: self, action: #selector(ReadWebViewController.onTappedLoadButton(_:)))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        spaceItem.width = 10
        addBookmarkButtonItem = UIBarButtonItem(image: IconImage.addBookmarkImage(), style: .plain, target: self, action: #selector(ReadWebViewController.onTappedAddBookmarkButton(_:)))
        actionButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(ReadWebViewController.onTappedActionButton(_:)))
        toolbar.items = [backButtonItem, spaceItem, nextButtonItem, spaceItem, stopButtonItem, spaceItem, loadButtonItem, flexibleItem, addBookmarkButtonItem, spaceItem, actionButtonItem]
        self.view.addSubview(toolbar)
        
        setAllControlButtonsStatus()
    }
    
    func showAddBookMarkAlert() {
        guard let pageInfoArray = getPageInfo() else {
            return
        }
        let sb = UIStoryboard(name: "AddBookmark", bundle: nil)
        guard let naviVc = sb.instantiateInitialViewController() as? UINavigationController else { return }
        guard let addBookmarkVc = naviVc.topViewController as? AddBookmarkViewController else { return }
        addBookmarkVc.pageInfo = pageInfoArray
        present(naviVc, animated: true, completion: nil)
    }
    
    func showUiActivity() {
        guard let activityItems = getPageInfo() else {
            return
        }
        let appActivity = [PostFromUIActivity()]
        let activitySheet = UIActivityViewController(activityItems: activityItems, applicationActivities: appActivity)
        let excludeActivity: [UIActivityType] = [
            UIActivityType.print,
            UIActivityType.postToWeibo,
            UIActivityType.postToTencentWeibo
        ]
        activitySheet.excludedActivityTypes = excludeActivity
        present(activitySheet, animated: true, completion: {() -> Void in
        })
    }

    // 閲覧中のページのurlとタイトルを取得するメソッド、できなかったらnilを返す
    private func getPageInfo() -> [Any]? {
        guard
            let postUrl: URL = webView.url, // self.webView.request?.url,
            postUrl.absoluteString.characters.count != 0,
            let title = webView.title,
            title.characters.count != 0 else {
                print("self.webView.request?.url || webView.titleがない")
                return nil
        }
        print("title: \(title), postUrl: \(postUrl).")
        return [title, postUrl]
    }
}

extension ReadWebViewController: WKUIDelegate {
    @available(iOS 10.0, *)
    func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        return false
    }
}

// MARK: - スクロールの状態を管理
extension ReadWebViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        beginingPoint = scrollView.contentOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPoint = scrollView.contentOffset
        let contentSize = scrollView.contentSize
        let frameSize = scrollView.frame
        let maxOffSet = contentSize.height - frameSize.height
        
        if currentPoint.y >= maxOffSet {
            showToolbarAnimate()
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else if beginingPoint.y < currentPoint.y {
            // スクロールダウンした時
            hideToolbarAnimate()
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }else{
            // スクロールアップした時
            print("Scrolled up")
            showToolbarAnimate()
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    // MARK: - webViewを縮小し、naviBarとtoolBarを表示する
    func showToolbarAnimate() {
        if isViewShowed || isMovingToolbar{ return }
        isMovingToolbar = true
        self.toolbar.frame.origin.y = self.view.frame.size.height
        self.webView.frame.origin.y = ViewSize.statusBarBottomY
        self.webView.frame.size.height = self.view.frame.size.height - ViewSize.statusBarBottomY
        UIView.animate(withDuration: 0.2, animations: {
            self.toolbar.frame.origin.y -= ViewSize.toolbarHeight
            self.webView.frame.origin.y += ViewSize.navigationbarHeight
            self.webView.frame.size.height -= ViewSize.navigationbarHeight + ViewSize.toolbarHeight
        }, completion: { _ in
            self.isViewShowed = true
            self.isMovingToolbar = false
        })
    }
    
    // MARK: - webViewを画面いっぱいにし、naviBarとtoolBarを非表示にする
    func hideToolbarAnimate() {
        if !isViewShowed || isMovingToolbar{ return }
        isMovingToolbar = true
        self.toolbar.frame.origin.y = self.view.frame.size.height - ViewSize.toolbarHeight
        self.webView.frame.origin.y = ViewSize.navigationbarBottomY
        self.webView.frame.size.height = self.view.frame.size.height - ViewSize.navigationbarBottomY - ViewSize.toolbarHeight
        UIView.animate(withDuration: 0.2, animations: {
            self.toolbar.frame.origin.y += ViewSize.toolbarHeight
            self.webView.frame.origin.y -= ViewSize.navigationbarHeight
            self.webView.frame.size.height += ViewSize.navigationbarHeight + ViewSize.toolbarHeight
        }, completion: { _ in
            self.isViewShowed = false
            self.isMovingToolbar = false
        })
    }
}

extension ReadWebViewController {
    func setAllControlButtonsStatus() {
        // webviewの状態に応じて、3つ全てのボタンの色と操作許可を変更
        guard let back = backButtonItem,
            let next = nextButtonItem,
            let stop = stopButtonItem else { return }
        back.setState(isAvailable: webView.canGoBack)
        back.image = IconImage.backImage(isOn: webView.canGoBack)
        next.setState(isAvailable: webView.canGoForward)
        next.image = IconImage.nextImage(isOn: webView.canGoForward)
        stop.setState(isAvailable: webView.isLoading)
        stop.image = IconImage.stopImage(isOn: webView.isLoading)
    }
}

private extension UIBarButtonItem {
    func setState(isAvailable: Bool) {
        self.isEnabled = isAvailable
    }
}

struct IconImage {
    static func backImage(isOn: Bool) -> UIImage {
        return isOn ? UIImage(named: "back_on.png")! : UIImage(named: "back_off.png")!
    }
    
    static func nextImage(isOn: Bool) -> UIImage {
        return isOn ? UIImage(named: "next_on.png")! : UIImage(named: "next_off.png")!
    }
    
    static func stopImage(isOn: Bool) -> UIImage {
        return isOn ? UIImage(named: "stop_on.png")! : UIImage(named: "stop_off.png")!
    }
    
    static func loadImage(isOn: Bool) -> UIImage {
        return isOn ? UIImage(named: "reload_on.png")! : UIImage(named: "reload_off.png")!
    }
    
    static func addBookmarkImage() -> UIImage {
        return UIImage(named: "bookmark_add.png")!
    }
}
