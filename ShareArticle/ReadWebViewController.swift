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
    
    var originUrl: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        
        let urlRequest = NSURLRequest(url: originUrl)
        // urlをネットワーク接続が可能な状態にしている（らしい）
        
        webView.loadRequest(urlRequest as URLRequest)
        // 実際にwebViewにurlからwebページを引っ張ってくる。
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onTappedActionButton(_ sender: UIBarButtonItem) {
        showUiActivity()
    }
    
    private func showUiActivity() {
        let title = self.webView.stringByEvaluatingJavaScript(from: "document.title") ?? "no-title: cannot get title"
        
        let currentURL = self.webView.request?.url ?? URL(string: "https://www.google.co.jp/")!
        print(currentURL)
        let activityItems: [Any] = [title, currentURL]
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

extension ReadWebViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
