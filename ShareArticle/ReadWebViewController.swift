//
//  ReadWebViewController.swift
//  ShareArticle
//
//  Created by Wataru Inoue on 2017/06/11.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

class ReadWebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var stopButton: UIBarButtonItem!
    @IBOutlet weak var loadButton: UIBarButtonItem!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    var originUrl: URL! // 前のvcから引き継いでくる
    var currentURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        
        let urlRequest = NSURLRequest(url: originUrl)
        // urlをネットワーク接続が可能な状態にしている（らしい）
        
        webView.loadRequest(urlRequest as URLRequest)
        // 実際にwebViewにurlからwebページを引っ張ってくる。
        
        setAllControlButtonsStatus()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onTappedBackButton(_ sender: UIBarButtonItem) {
        if !webView.canGoBack { return }
        webView.goBack() // 戻る
    }
    
    @IBAction func onTappedNextButton(_ sender: UIBarButtonItem) {
        if !webView.canGoForward { return }
        webView.goForward() // 進む
    }
    @IBAction func onTappedStopButton(_ sender: UIBarButtonItem) {
        webView.stopLoading() // 読み込み停止
    }
    
    @IBAction func onTappedLoadButton(_ sender: UIBarButtonItem) {
        webView.reload() // 再度読み込み
    }
    
    @IBAction func onTappedActionButton(_ sender: UIBarButtonItem) {
        showUiActivity()
    }
    
    private func showUiActivity() {
        let title = self.webView.stringByEvaluatingJavaScript(from: "document.title") ?? "no-title: cannot get title"
        let postURL = self.webView.request?.url ?? URL(string: "https://www.google.co.jp/")!
        print(postURL)
        let activityItems: [Any] = [title, postURL]
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
}

extension ReadWebViewController {
    func setAllControlButtonsStatus() {
        // webviewの状態に応じて、3つ全てのボタンの色と操作許可を変更
        setBackButtonStatus()
        setNextButtonStatus()
        setStopButtonStatus()
        
    }
    
    func setBackButtonStatus() {
        backButton.setState(isAvailable: webView.canGoBack)
    }
    
    func setNextButtonStatus() {
        nextButton.setState(isAvailable: webView.canGoForward)
    }
    func setStopButtonStatus() {
        stopButton.setState(isAvailable: webView.isLoading)
    }
    
    
}

extension ReadWebViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        setAllControlButtonsStatus()
        currentURL = self.webView.request?.url ?? URL(string: "https://www.google.co.jp/")!
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        setAllControlButtonsStatus()
    }
}

private extension UIBarButtonItem {

    func setState(isAvailable: Bool) {

        self.isEnabled = isAvailable
        self.tintColor = isAvailable ? UIColor.blue : UIColor.gray
    }
}
