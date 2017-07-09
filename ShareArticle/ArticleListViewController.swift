//
//  ArticleListViewController.swift
//  ShareArticle
//
//  Created by Wataru Inoue on 2017/06/11.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

class ArticleListViewController: UIViewController {
    
    @IBOutlet weak var articleTableView: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var outputSelectedItemsButton: UIBarButtonItem!
    
    let ud = UserDefaults.standard
    
    var articleDictionary: Dictionary<String, [Article]> = [:]
    
    var articleDateStringArray: [String] = [] // 記事の日付を管理する配列: セクションのタイトルで使う
    var articleByDateArray: [[Article]]  = [] // セクション分けして記事を表示するのに使う
    
    var checkedArticleByDateArray: [[Bool]] = []
    
    var isEditingTableView = false
    
    var selectedUrl: URL!
    
    var articleUdArray: [Dictionary<String, Any>] = [] // udで保存するために型変換した記事配列
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        initDict() // データベースの初期化、ダミーデータの挿入
        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadArticleArrayFromUd()
        articleTableView.reloadData() // 毎回reloadする必要はないよね
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
    
    // MARK: Addボタン
    func onTappedAddButton(_ sender: UIBarButtonItem) {
        showUrlTextInputAlert()
    }
    
    // MARK: 「出力」ボタン
    func onTappedOutputButton(_ sender: UIBarButtonItem) {
        isEditingTableView = !isEditingTableView // スイッチ
        
        animateToolBar()
        controlCheckedArticleArray()
        setNavigationBarContents()
        articleTableView.reloadData()
    }
    
    // MARK: 「記事をマークダウンに変換」ボタン
    @IBAction func onTappedChangeToMarkDownButton(_ sender: UIBarButtonItem) {
        changeArticlesToMarkDown()
    }
    
    // MARK: Actionボタン
    @IBAction func onTappedActionButton(_ sender: UIBarButtonItem) {
    }
    
}

// MARK: - データ操作
extension ArticleListViewController {
    // MARK: [記事]をマークダウン形式の文字列に変換
    func changeArticlesToMarkDown() {
        // 選択された記事のみを書き出す
        var targetArray: [Article] = []
        for d in 0 ..< articleByDateArray.count {
            for a in 0 ..< articleByDateArray[d].count {
                if checkedArticleByDateArray[d][a] {
                    targetArray.append(articleByDateArray[d][a])
                }
            }
        }
        
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
        
        let actionSheet = UIAlertController(title: "マークダウン形式で保存します", message: "出力先を選択してください", preferredStyle: .actionSheet)
        
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
    
    // MARK: 選択された記事を管理する
    func controlCheckedArticleArray() {
        if !isEditingTableView { return }
        
        //取得したメモリ空間は残して、配列のすべての要素を削除する。
        checkedArticleByDateArray.removeAll(keepingCapacity: true)
        
        // 全てfalseでarticleByDateArrayと同じ要素構成の[[Bool]]配列を作成
        var tmepBoolArray: [Bool] = []
        for d in 0 ..< articleByDateArray.count {
            for a in 0 ..< articleByDateArray[d].count {
                tmepBoolArray.append(true)
                if a == articleByDateArray[d].count - 1 {
                    checkedArticleByDateArray.append(tmepBoolArray)
                    tmepBoolArray.removeAll(keepingCapacity: true)
                }
            }
        }
        print(checkedArticleByDateArray)
    }
}

// MARK: - データベース連携操作
extension ArticleListViewController {
    func initDict() { // デバック用にダミーデータを入れる
        ud.removeSuite(named: "articleUdArray")
        articleUdArray = []
        
        // デバック用のダミーデータ
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
                          comment: commentArray[i])
            
            articleUdArray.append(atc.change2UdDict())
        }
        
//        print(articleUdArray)
        ud.set(articleUdArray, forKey: "articleUdArray")
    }
    
    // MARK: udから読み込む
    func loadArticleArrayFromUd() {
        
        if let obj = ud.array(forKey: "articleUdArray") {
            articleUdArray = obj as? [Dictionary<String, Any>] ?? []
//            print(articleUdArray)
        } else {
            print("articleUdArray keyでヒットするobjがない")
        }
        
        // articleArrayに代入
        var articleArray: [Article] = [] // udから全ての記事を持ってくる
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
        
        var newArticleByDateArray:[[Article]] = [] // [[Article]]
        for article in articleArray {
            let thisDateString = article.date.dateString()
            if currentDateString != thisDateString {
                newArticleByDateArray.append(currentArticleArray)
                currentArticleArray = []
                currentDateString = thisDateString
                articleDateStringArray.append(currentDateString)
            }
            currentArticleArray.append(article)
        }
        if currentArticleArray.count > 0 {
            newArticleByDateArray.append(currentArticleArray)
        }
        
        articleByDateArray = newArticleByDateArray
        
        newArticleByDateArray.removeAll(keepingCapacity: true)
        articleArray.removeAll(keepingCapacity: true)
        
//        print(articleDateStringArray)
//        print(articleByDateArray)
    }
    
    // [[Article]]からudに保存する
    func setArticlesUdFromArray(from targetArrayOfArray: [[Article]]) {
        let articleArray = targetArrayOfArray.joined().map {$0} // 結合: [[Article]] -> [Article]
        
        ud.removeSuite(named: "articleUdArray")
        articleUdArray = []
        
        for article in articleArray {
            articleUdArray.append(article.change2UdDict())
        }
        
        ud.set(articleUdArray, forKey: "articleUdArray")
    }
}

// MARK: - tableView操作
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
        let article = articleByDateArray[indexPath.section][indexPath.row]
        
        cell.titleLabel.text = article.title
        cell.titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        let url = article.url as URL
        cell.urlLabel.text = String(describing: url)
        cell.timeLabel.text = article.date.timeString()
        if let comment = article.comment {
            if comment != "" {
                cell.commentLabel.text = comment
            } else {
                cell.commentLabel.isHidden = true
            }
        } else {
            print("article.comment自体がnil: やばい")
        }
        
        if let image = article.image {
            cell.thumbnailImageView.image = image
        } else {
            cell.thumbnailImageView.image = nil
            article.requestSetImageOnTableView(imageView: cell.thumbnailImageView, tableView: self.articleTableView)
        }
        
        if isEditingTableView {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        // セルが選択された時の背景色を消す
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditingTableView {
            checkedArticleByDateArray[indexPath.section][indexPath.row] = !checkedArticleByDateArray[indexPath.section][indexPath.row]
            
            let cell = tableView.cellForRow(at: indexPath)
            if checkedArticleByDateArray[indexPath.section][indexPath.row] {
                cell?.accessoryType = .checkmark
            } else {
                cell?.accessoryType = .none
            }
        } else {
            selectedUrl = articleByDateArray[indexPath.section][indexPath.row].url as URL
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isEditingTableView // 出力記事の選択中はスワイプ削除禁止
    }
}

// MARK: - view操作
extension ArticleListViewController: UINavigationControllerDelegate {
    
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
        toolbar.frame.origin.y = self.view.bottomY
    }
    
    func animateToolBar() {
        if isEditingTableView {
            // 編集モード
            UIView.animate(withDuration: 0.2, animations: {
                self.articleTableView.frame.size.height -= self.toolbar.frame.size.height
                self.toolbar.frame.origin.y = self.view.bottomY - self.toolbar.frame.size.height
            })
        } else {
            //通常モード
            UIView.animate(withDuration: 0.2, animations: {
                self.articleTableView.frame.size.height += self.toolbar.frame.size.height
                self.toolbar.frame.origin.y = self.view.bottomY
            })
        }
    }
    
    // MARK: isEditingTableViewに応じてnavigationControllerの要素を変更
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
            self.navigationItem.leftBarButtonItem = nil
            let rightBarButtonItem = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(onTappedOutputButton(_:)))
            self.navigationItem.rightBarButtonItem = rightBarButtonItem
            navigationBarTopItem.title = "記事を選択"
        } else {
            let leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onTappedAddButton(_:)))
            self.navigationItem.leftBarButtonItem = leftBarButtonItem
            let rightBarButtonItem = UIBarButtonItem(title: "出力", style: .plain, target: self, action: #selector(onTappedOutputButton(_:)))
            self.navigationItem.rightBarButtonItem = rightBarButtonItem
            navigationBarTopItem.title = ""
        }
    }
    
    func showUiActivity(text: String) {
        let activityItems: [Any] = [text]
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
    
    func showUrlTextInputAlert() {
        // MARK: テキストフィールド付きアラート表示
        let alert = UIAlertController(title: "URLからページを開きます", message: "URLを入力してください", preferredStyle: .alert)
        let placeholderText = "https://www.google.com/"
        
        // 「開く」ボタンの設定
        let openAction = UIAlertAction(title: "開く", style: .default, handler: {
            (action:UIAlertAction!) -> Void in
            if let textFields = alert.textFields {
                for textField in textFields {
                    let textFieldText = textField.text ?? ""
                    let urlString = textFieldText != "" ? textFieldText : placeholderText
                    print(urlString)
                    self.requestOpenWebView(urlString: urlString)
                }
            }
        })
        alert.addAction(openAction)
        
        // キャンセルボタンの設定
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        // テキストフィールドを追加
        alert.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
            textField.attributedPlaceholder = NSAttributedString(string: placeholderText,
                                                                 attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        })
        
        alert.view.setNeedsLayout() // シミュレータの種類によっては、これがないと警告が発生
        
        // アラートを画面に表示
        self.present(alert, animated: true, completion: nil)
    }
    
    func showCannotOpenUrlAlert() {
        // MARK: 任意のurlを開けなかったときのalert
        let alert = UIAlertController(title: "ページを開けませんでした", message: "URLが正しくありませんでした", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - urlのバリデーションなど
extension ArticleListViewController {
    
    func requestOpenWebView(urlString: String) {
        if verifyUrl(urlString: urlString) {
            selectedUrl = URL(string: urlString)
            performSegue(withIdentifier: "toReadWebVC", sender: nil)
        } else {
            showCannotOpenUrlAlert()
            print("urlが正しくありませんでした")
        }
    }
  
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url  = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
}
