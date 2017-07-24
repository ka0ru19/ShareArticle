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
    var actionButtonItem: UIBarButtonItem!
    
    var originUrl: URL! // 前のvcから引き継いでくる
    var currentURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.frame = CGRect(x: 0, y: 0,
                               width: self.view.frame.size.width,
                               height: self.view.frame.size.height - ViewSize.navigationbarBottomY - ViewSize.toolbarHeight)
        webView.frame.origin = CGPoint(x: 0, y: ViewSize.navigationbarBottomY)
        webView.allowsBackForwardNavigationGestures = false // スワイプで戻るを禁止(tableViewの戻りとかぶるため)
        webView.uiDelegate = self
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
        
        toolbar.frame = CGRect(x: 0, y: webView.bottomY, width: self.view.frame.width, height: ViewSize.toolbarHeight)
        backButtonItem = UIBarButtonItem(image: IconImage.backImage(isOn: false), style: .plain, target: nil, action: #selector(ReadWebViewController.onTappedBackButton(_:)))
        nextButtonItem = UIBarButtonItem(image: IconImage.nextImage(isOn: false), style: .plain, target: nil, action: #selector(ReadWebViewController.onTappedNextButton(_:)))
        stopButtonItem = UIBarButtonItem(image: IconImage.stopImage(isOn: false), style: .plain, target: nil, action: #selector(ReadWebViewController.onTappedStopButton(_:)))
        loadButtonItem = UIBarButtonItem(image: IconImage.loadImage(isOn: true), style: .plain, target: nil, action: #selector(ReadWebViewController.onTappedLoadButton(_:)))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spaceItem.width = 10
        actionButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(ReadWebViewController.onTappedActionButton(_:)))
        toolbar.items = [backButtonItem, spaceItem, nextButtonItem, spaceItem, stopButtonItem, spaceItem, loadButtonItem, flexibleItem, actionButtonItem]
        self.view.addSubview(toolbar)
        
        setAllControlButtonsStatus()
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
    
    //    @IBAction func onTappedBackButton(_ sender: UIBarButtonItem) {
    //        guard webView.canGoBack else { return }
    //        webView.goBack() // 戻る
    //    }
    //
    //    @IBAction func onTappedNextButton(_ sender: UIBarButtonItem) {
    //        guard webView.canGoForward else { return }
    //        webView.goForward() // 進む
    //    }
    //    @IBAction func onTappedStopButton(_ sender: UIBarButtonItem) {
    //        webView.stopLoading() // 読み込み停止
    //    }
    //
    //    @IBAction func onTappedLoadButton(_ sender: UIBarButtonItem) {
    //        webView.reload() // 再度読み込み
    //    }
    //
    //    @IBAction func onTappedActionButton(_ sender: UIBarButtonItem) {
    //        showUiActivity()
    //    }
    //
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
    
    func onTappedActionButton(_ sender: UIBarButtonItem) {
        showUiActivity()
    }
    
    private func showUiActivity() {
        guard
            let postUrl: URL = webView.url, // self.webView.request?.url,
            postUrl.absoluteString.characters.count != 0 else {
                print("self.webView.request?.urlがない: 読み込みが終わるまで待って。")
                return
        }
        
        let title = webView.title ?? "no-title: cannot get title"
        
        print("postUrl: \(postUrl)")
        
        let activityItems: [Any] = [title, postUrl]
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
    
    private func setNavigatinbarTitle(url: URL?) {
        // vcのタイトルにホスト名を表示する
        guard let url = url else { return }
        if let component = URLComponents(string: url.absoluteString) {
            //            self.navigationController?.navigationBar.topItem!.title = component.host
            self.title = component.host //
        }
    }
}

extension ReadWebViewController: WKUIDelegate {
    @available(iOS 10.0, *)
    func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        return false
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
        //        self.tintColor = isAvailable ? UIColor.blue : UIColor.gray
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
}
