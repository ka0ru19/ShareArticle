//
//  ArticleListViewController.swift
//  ShareArticle
//
//  Created by Wataru Inoue on 2017/06/11.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

class ArticleListViewController: UIViewController {
    
//    @IBOutlet weak var outputButton: UIBarButtonItem!
    @IBOutlet weak var articleTableView: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var outputSelectedItemsButton: UIBarButtonItem!
    
    let ud = UserDefaults.standard
    
    var articleDictionary: Dictionary<String, [Article]> = [:]
    var articleArray: [Article] = []
    
    var articleDateStringArray: [String] = [] // 記事の日付を管理する配列: セクションのタイトルで使う
    var articleByDateArray: [[Article]]  = [] // セクション分けして記事を表示するのに使う
    
    var checkedArticleByDateArray: [[Bool]] = []
    
    var isEditingTableView = false
    
    var selectedUrl: URL!
    
    // デバック用のダミーデータ
    var dateArray = ["2017/06/11","2017/06/10","2017/06/09"]
    var articleUdArray: [Dictionary<String, Any>] = [] // udで保存するために型変換した記事配列
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initDict()
        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadArticleArrayFromUd()
        articleTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toReadWebVC" {
            let nextVC = segue.destination as! ReadWebViewController
            nextVC.originUrl = self.selectedUrl
        }
    }
    
    // 「出力」ボタン
    func onTappedOutputButton(_ sender: UIBarButtonItem) {
        isEditingTableView = !isEditingTableView // スイッチ
        controlCheckedArticleArray()
        setNavigationBarContents()
    }
    
    // 「記事をマークダウンに変換」ボタン
    @IBAction func onTappedChangeToMarkDownButton(_ sender: UIBarButtonItem) {
        changeArticlesToMarkDown(targetArray: articleArray)
    }
    
    // Actionボタン
    @IBAction func onTappedActionButton(_ sender: UIBarButtonItem) {
    }
    
}

extension ArticleListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return articleDateStringArray.count // セクションの数
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return articleDateStringArray[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleByDateArray[section].count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! ArticleTableViewCell
        
        cell.titleLabel.text = articleByDateArray[indexPath.section][indexPath.row].title
        cell.urlLabel.text = String(describing: articleByDateArray[indexPath.section][indexPath.row].url as URL)
        cell.timeLabel.text = articleByDateArray[indexPath.section][indexPath.row].date.timeString()
        if let comment = articleByDateArray[indexPath.section][indexPath.row].comment {
            if comment != "" {
                cell.commentLabel.text = comment
            } else {
                cell.commentLabel.isHidden = true
            }
        } else {
            print("articleArrayByDateArray[indexRow.section][indexPath.row][\"comment\"]自体がnil: やばい")
        }
        cell.thumbnailImageView.backgroundColor = UIColor.cyan
        
        cell.accessoryType = .none
        // セルが選択された時の背景色を消す
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditingTableView {
            let cell = tableView.cellForRow(at: indexPath)
            if cell?.accessoryType == .checkmark {
                cell?.accessoryType = .none
            } else {
                cell?.accessoryType = .checkmark
            }
        } else {
            let urlStr = articleUdArray[indexPath.row]["urlString"] as? String ?? "no urlText value"
            selectedUrl = URL(string: urlStr)
            performSegue(withIdentifier: "toReadWebVC", sender: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // スワイプで削除された時
            articleByDateArray[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if articleByDateArray[indexPath.section].count == 0 {
                articleDateStringArray.remove(at: indexPath.section)
                articleByDateArray.remove(at: indexPath.section)
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            }
            
            setArticlesUdFromArray(from: articleByDateArray)
        }
    }
}

extension ArticleListViewController: UINavigationControllerDelegate {
    
    func initDict() { // デバック用にダミーデータを入れる
        ud.removeSuite(named: "articleUdArray")
        articleUdArray = []
        
        var titleArray: [String] = ["mac","ipad","iphone"]
        var urlArray: [URL] = [URL(string: "https://www.apple.com/jp/mac/")!,
                               URL(string: "https://www.apple.com/jp/ipad/")!,
                               URL(string: "https://www.apple.com/jp/iphone/")!]
        var dateArray = ["2017/06/11 04:11:58 +0900","2017/06/10 04:10:28 +0900","2017/06/12 04:12:53 +0900"]
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
    
    func loadArticleArrayFromUd() {
        articleArray = []
        if let obj = ud.array(forKey: "articleUdArray") {
            articleUdArray = obj as? [Dictionary<String, Any>] ?? []
            print(articleUdArray)
        } else {
            print("articleUdArray keyでヒットするobjがない")
        }
        
        // articleArrayに代入
        for articleUd in articleUdArray {
            if let article = Article(from: articleUd) {
                articleArray.append(article)
            }
        }
        
        if articleArray.count == 0 { return }
        
        // 日付でソート(新しい順)
        articleArray.sort { $1.date < $0.date }
        
        // セクションわけのために日付ごとに記事を分ける
        var currentDateString: String = articleArray[0].date.dateString() // "yyyy/MM/dd"
        var currentArticleArray: [Article] = []
        articleDateStringArray = [currentDateString] // ["yyyy/MM/dd"]
        articleByDateArray = [] // [[Article]]
        for article in articleArray {
            let thisDateString = article.date.dateString()
            if currentDateString != thisDateString {
                articleByDateArray.append(currentArticleArray)
                currentArticleArray = []
                currentDateString = thisDateString
                articleDateStringArray.append(currentDateString)
            }
            currentArticleArray.append(article)
        }
        if currentArticleArray.count > 0 {
            articleByDateArray.append(currentArticleArray)
        }
        print(articleDateStringArray)
        print(articleByDateArray)
    }
    
    func initView() {
        articleTableView.delegate = self
        articleTableView.dataSource = self
        articleTableView.register(UINib(nibName: "ArticleTableViewCell", bundle: nil),
                                  forCellReuseIdentifier: "articleCell")
        
        articleTableView.rowHeight = UITableViewAutomaticDimension
        articleTableView.estimatedRowHeight = 600
        articleTableView.sectionHeaderHeight = 20
        articleTableView.tableFooterView = UIView(frame: .zero)
        articleTableView.separatorInset = UIEdgeInsetsMake(0, 8, 0, 0) // 文字の頭に合わせている
        
        setNavigationBarContents()
        
        // 最初はtoolbarを下に隠しておく
        toolbar.frame.origin.y = self.articleTableView.bottomY
    }
    
    // isEditingTableViewに応じてnavigationControllerの要素を変更
    func setNavigationBarContents() {
        guard let navigationController = self.navigationController else {
            print("self.navigationController?がない")
            return
        }
        guard let navigationBarTopItem = navigationController.navigationBar.topItem else {
            print("navigationController.navigationBar.topItem?がない")
            return
        }
        
        if isEditingTableView {
            let rightBarButtonItem = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(onTappedOutputButton(_:)))
            self.navigationItem.rightBarButtonItem = rightBarButtonItem
            navigationBarTopItem.title = "記事を選択"
        } else {
            let rightBarButtonItem = UIBarButtonItem(title: "出力", style: .plain, target: self, action: #selector(onTappedOutputButton(_:)))
            self.navigationItem.rightBarButtonItem = rightBarButtonItem
            navigationBarTopItem.title = ""
        }
        
    }
    
    // [記事]をマークダウン形式の文字列に変換
    func changeArticlesToMarkDown(targetArray: [Article]) {
        var markdownText: String = ""
        var markdownSentence: String!
        for article in targetArray {
            let textStr = article.title ?? "no-title"
            let urlStr = String(describing: article.url as URL) // asがないとoptinalになる
            let commentStr = article.comment ?? ""
            var commentStrBlock = ""
            if commentStr != "" {
                let sentenceArray: [String] = commentStr.components(separatedBy: "\n")
                for sentence in sentenceArray {
                    commentStrBlock += "  - " + sentence + "\n"
                }
            }
            markdownSentence = "- [" + textStr + "](" + urlStr + ")\n" + commentStrBlock
            markdownText += markdownSentence
        }
        
        print(markdownText)
        
        let actionSheet = UIAlertController(title: "マークダウン形式で保存します", message: "出力先を選択してください", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let action1 = UIAlertAction(title: "クリップボードにコピーする", style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction!) in
            let board = UIPasteboard.general // クリップボード呼び出し
            board.setValue(markdownText, forPasteboardType: "public.text") // クリップボードに貼り付け
        })
        
        let action2 = UIAlertAction(title: "他のアプリに出力する", style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction!) in
            self.showUiActivity(text: markdownText)
        })
        
        let cancel = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler: {
            (action: UIAlertAction!) in
            print("キャンセルをタップした時の処理")
        })
        
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(cancel)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // [[Article]]からudに保存する
    func setArticlesUdFromArray(from targetArrayOfArray: [[Article]]) {
        articleArray = targetArrayOfArray.joined().map {$0} // 結合: [[Article]] -> [Article]
        
        ud.removeSuite(named: "articleUdArray")
        articleUdArray = []
        
        for article in articleArray {
            articleUdArray.append(article.change2UdDict())
        }
        
        ud.set(articleUdArray, forKey: "articleUdArray")
    }
    
    func showUiActivity(text: String) {
        let activityItems: [Any] = [text]
        print(text)
        let appActivity = [PostFromUIActivity()]
        let activitySheet = UIActivityViewController(activityItems: activityItems, applicationActivities: appActivity)
        let excludeActivity: [UIActivityType] = [
            PostFromUIActivity().activityType!,
            UIActivityType.print,
            UIActivityType.postToWeibo,
            UIActivityType.postToTencentWeibo
        ]
        activitySheet.excludedActivityTypes = excludeActivity
        present(activitySheet, animated: true, completion: {() -> Void in
        })
    }
    
    func controlCheckedArticleArray() {
        //取得したメモリ空間は残して、配列のすべての要素を削除する。
        checkedArticleByDateArray.removeAll(keepingCapacity: true)
        
        
    }
}
