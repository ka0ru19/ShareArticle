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
        
        webView.loadRequest(URLRequest(url: originUrl))
        
        setAllControlButtonsStatus()
    }
    
    deinit {
        self.webView.delegate = nil
        self.webView.stopLoading()
        self.webView.loadHTMLString("", baseURL: nil)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        print("deinit ReadWebViewController")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTappedBackButton(_ sender: UIBarButtonItem) {
        guard webView.canGoBack else { return }
        webView.goBack() // 戻る
    }
    
    @IBAction func onTappedNextButton(_ sender: UIBarButtonItem) {
        guard webView.canGoForward else { return }
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
        guard
            let postUrl: URL = self.webView.request?.url,
            postUrl.absoluteString.characters.count != 0 else {
            print("self.webView.request?.urlがない: 読み込みが終わるまで待って。")
            return
        }
        
        let title = self.webView.stringByEvaluatingJavaScript(from: "document.title") ?? "no-title: cannot get title"
        
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
    
    }

private extension ReadWebViewController {
    func setAllControlButtonsStatus() {
        // webviewの状態に応じて、3つ全てのボタンの色と操作許可を変更
        backButton.setState(isAvailable: webView.canGoBack)
        nextButton.setState(isAvailable: webView.canGoForward)
        stopButton.setState(isAvailable: webView.isLoading)
        
    }
}
extension ReadWebViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        setAllControlButtonsStatus()
        currentURL = self.webView.request?.url ?? URL(string: "https://www.google.com/")!
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
