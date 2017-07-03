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
        guard let postUrl = self.webView.request?.url else {
            print("self.webView.request?.urlがない: 読み込みが終わるまで待って。")
            return
        }
        if String(describing: postUrl) == "" {
            print("urlがない")
            return
        }
//        let postUrl = self.webView.request?.url ?? originUrl
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

extension ReadWebViewController {
    func setAllControlButtonsStatus() {
        // webviewの状態に応じて、3つ全てのボタンの色と操作許可を変更
        setBackButtonStatus()
        setNextButtonStatus()
        setStopButtonStatus()
        
    }
    
    func setBackButtonStatus() {
        if webView.canGoBack {
            backButton.isEnabled = true
            backButton.tintColor = UIColor.blue
        } else {
            backButton.isEnabled = false
            backButton.tintColor = UIColor.gray
        }
    }
    
    func setNextButtonStatus() {
        if webView.canGoForward {
            nextButton.isEnabled = true
            nextButton.tintColor = UIColor.blue
        } else {
            nextButton.isEnabled = false
            nextButton.tintColor = UIColor.gray
        }

    }
    func setStopButtonStatus() {
        if webView.isLoading {
            stopButton.isEnabled = true
            stopButton.tintColor = UIColor.blue
        } else {
            stopButton.isEnabled = false
            stopButton.tintColor = UIColor.gray
        }
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
