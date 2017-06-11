//
//  ArticleListViewController.swift
//  ShareArticle
//
//  Created by Wataru Inoue on 2017/06/11.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

class ArticleListViewController: UIViewController {
    
    @IBOutlet weak var outputButton: UIBarButtonItem!
    @IBOutlet weak var articleTableView: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var outputSelectedItemsButton: UIBarButtonItem!
    
    let ud = UserDefaults.standard
    
    var articleDictionary: Dictionary<String, [Article]> = [:]
    
    var dateArray = ["2017/06/11","2017/06/10","2017/06/09"]
    var articleArray: [Article] = []
    var articleUdArray: [Dictionary<String, Any>] = [] // udで保存するために型変換した記事配列
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initDict()
        loadPostArrayFromUd()
        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadPostArrayFromUd()
        articleTableView.reloadData()
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toReadWebVC" {
            let nextVC = segue.destination as! ReadWebViewController
        }
    }
    
}

extension ArticleListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //dateArray.count 一旦セクション関係なし
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return dateArray[section]
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleUdArray.count // のちのちarticleArrayにしないといけない日がくるかも
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! ArticleTableViewCell
        cell.urlLabel.text = articleUdArray[indexPath.row]["urlString"] as? String ?? "no-url"
        cell.titleLabel.text = articleUdArray[indexPath.row]["title"] as? String ?? "no-title"
        let date: Date? = articleUdArray[indexPath.row]["date"] as? Date
        cell.timeLabel.text = date?.timeString() ?? "no-date"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toReadWebVC", sender: nil)
    }
}


extension ArticleListViewController {
    
    func initDict() {
        
        ud.removeSuite(named: "articleUdArray")
        articleUdArray = []
        
        var titleArray: [String] = ["mac","ipad","iphone"]
        var urlArray: [URL] = [URL(string: "https://www.apple.com/jp/mac/")!,
                                   URL(string: "https://www.apple.com/jp/ipad/")!,
                                   URL(string: "https://www.apple.com/jp/iphone/")!]
        var dateArray = ["2017/06/11 02:21:58 +0000","2017/06/10 02:21:28 +0000","2017/06/09 02:21:53 +0000"]
        var commentArray: [String] = ["macほしくなった","ipadすげえ","iphone赤いの出てるう"]
        
        var atc:Article!
        for i in 0 ..< titleArray.count {
            atc = Article(title: titleArray[i],
                                 urlString: String(describing: urlArray[i] as URL),
                                 dateString: dateArray[i],
                                 imageNsData: nil,
                                 comment: commentArray[i])
            
            articleUdArray.append(atc.change2UdDict())
        }
        
        print(articleUdArray)
        ud.set(articleUdArray, forKey: "articleUdArray")
    }
    
    func loadPostArrayFromUd() {
        articleArray = []
        if let obj = ud.array(forKey: "articleUdArray") {
            articleUdArray = obj as? [Dictionary<String, Any>] ?? []
            print(articleUdArray)
        } else {
            print("articleUdArray keyでヒットするobjがない")
        }
    }
    
    func initView() {
        
        articleTableView.delegate = self
        articleTableView.dataSource = self
        articleTableView.register(UINib(nibName: "ArticleTableViewCell", bundle: nil),
                                  forCellReuseIdentifier: "articleCell")
        
        articleTableView.rowHeight = UITableViewAutomaticDimension
        articleTableView.estimatedRowHeight = 600
        articleTableView.sectionHeaderHeight = 20
        
        
        // 最初はtoolbarを下に隠しておく
        toolbar.frame.origin.y = self.articleTableView.bottomY
    }
    
}
























