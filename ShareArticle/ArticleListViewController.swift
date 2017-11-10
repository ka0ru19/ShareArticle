
//  ArticleListViewController.swift
//  ShareArticle
//
//  Created by Wataru Inoue on 2017/06/11.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

class ArticleListViewController: UIViewController {
    
    let articleTableView = UITableView()
    let toolbar = UIToolbar()
    let ud = UserDefaults.standard
    
    var articleArray: [Article] = []
    var articleDateStringArray: [String] = [] // 記事の日付を管理する配列: セクションのタイトルで使う
    var articleByDateArray: [[Article]]  = [] // セクション分けして記事を表示するのに使う
    
    var checkedArticleByDateArray: [[Bool]] = [] // チェックが入っているものを管理
    
    var isEditingTableView = false // 出力のチェックを入力中
    
    var currentArticleCount = 0 // 現在表示中の記事の数
    let addArticleNum = 20 // 追加で表示する記事の数
    
    var selectedUrl: URL!
    
    enum SelectArticleType {
        case all
        case notAll
        case today
        case yesterday
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
        // 初回起動かチェック
        if let isFirst = UserDefaults.standard.object(forKey: "isFirst") as? Bool {
            if !isFirst {
                // 2回目移行は通常の処理
                return
            }
        }
        
        // 初回のみTutorialを表示
        let sb = UIStoryboard(name: "Tutorial", bundle: nil)
        guard let naviVc = sb.instantiateInitialViewController() as? TutorialViewController else { return }
        self.present(naviVc, animated: true, completion: nil)
        return
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        FirebaseAuthManager().signInAnonymously(vc: self)
        
        //MARK: - もし未投稿のものがあればこのタイミングで投稿
        let suiteName: String = "group.com.wataru.ShareArticle"
        let keyName: String = "shareData"
        guard let ud: UserDefaults = UserDefaults(suiteName: suiteName) else { return }
//        print(ud.array(forKey: keyName))
        guard let shareDataArray: [[String: Any]] = ud.array(forKey: keyName) as? [[String : Any]] else { return }
        var newValues: [[String: String]] = []
        
        // dateだけDate型なので、Stringにキャストして[[String: String]] を作る
        for value in shareDataArray {
            let tempDict: [String: String] = [
                "title" : value["title"] as? String ?? "",
                "url": value["url"] as? String ?? "",
                "date": (value["date"] as? Date ?? Date()).string(),
                "comment": value["comment"] as? String ?? "",
            ]
            newValues.append(tempDict)
        }
        // 投稿処理を投げる
        FirebaseDatabaseManager().postNewArcitles(newValueArray: newValues, vc: self)
        // 一旦udから削除。投稿に失敗すると、失敗した記事だけ別のudに保存される
        ud.removeObject(forKey: keyName)
        ud.synchronize()
        
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
    
    // MARK: ブックマークボタン
    func openBookmarkButton(_ sender: UIBarButtonItem) {
        openBookmarkVC()
    }
    
    // MARK: 「出力」ボタン
    func onTappedOutputButton(_ sender: UIBarButtonItem) {
        isEditingTableView = !isEditingTableView // スイッチ
        
        animateToolBar()
        controlCheckedArticleArray(isCheckAll: false)
        setNavigationBarContents()
        articleTableView.reloadData()
    }
    
    // MARK: 「条件選択」ボタン
    func onTappedKindSelectButton(_ sender: UIBarButtonItem) {
        showKindSelectAlert()
    }
    
    // MARK: 「記事をマークダウンに変換」ボタン
    func onTappedChangeToMarkDownButton(_ sender: UIBarButtonItem) {
        changeArticlesToMarkDown()
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
        
        if targetArray.count == 0 {
            let alert = UIAlertController(title: "記事がありません", message: "変換したい記事を選択してください", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        var markdownText: String = ""
        var markdownSentence: String!
        for article in targetArray {
            let textStr = article.title ?? "no-title"
            let urlStr = article.url.absoluteString
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
        
        let action1 = UIAlertAction(title: "クリップボードにコピーする", style: .default, handler: { _ in
            let board = UIPasteboard.general // クリップボード呼び出し
            board.setValue(markdownText, forPasteboardType: "public.text") // クリップボードに貼り付け
            
            let alert = UIAlertController(title: "マークダウンに変換完了", message: "クリップボードにコピーしました", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil)) // 「OK」ボタンの設定
            self.present(alert, animated: true, completion: nil) // アラートを画面に表示
            
        })
        
        let action2 = UIAlertAction(title: "他のアプリに出力する", style: .default, handler: { _ in
            self.showUiActivity(text: markdownText)
        })
        
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { _ in
            print("キャンセルをタップした時の処理")
        })
        
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(cancel)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: 選択された記事を管理する配列の初期化
    func controlCheckedArticleArray(isCheckAll: Bool) {
        if !isEditingTableView { return }
        
        //取得したメモリ空間は残して、配列のすべての要素を削除する。
        checkedArticleByDateArray.removeAll(keepingCapacity: true)
        
        // 全てfalseでarticleByDateArrayと同じ要素構成の[[Bool]]配列を作成
        var tmepBoolArray: [Bool] = []
        for d in 0 ..< articleByDateArray.count {
            for a in 0 ..< articleByDateArray[d].count {
                tmepBoolArray.append(isCheckAll)
                if a == articleByDateArray[d].count - 1 {
                    checkedArticleByDateArray.append(tmepBoolArray)
                    tmepBoolArray.removeAll(keepingCapacity: true)
                }
            }
        }
        print(checkedArticleByDateArray)
    }
    
    // MARK: 記事を条件で一括選択
    func selectArticle(type: SelectArticleType) {
        
        let calendar = Calendar(identifier: .gregorian)
        switch type {
        case .today:
            do {
                guard
                    let headDateString: String = articleDateStringArray.first,
                    let headDate: Date = Date(dateString: headDateString, dateFormat: "yyyy/MM/dd") else { return }
                
                if calendar.isDateInToday(headDate) {
                    print("先頭のarrayが今日の記事だった場合")
                    for i in 0 ..< checkedArticleByDateArray[0].count {
                        self.checkedArticleByDateArray[0][i] = true
                    }
                } else {
                    print("先頭のarrayは今日の記事ではなかったので何も選択しない。さよなら。")
                }
                
            }
            break
        case .yesterday:
            do {
                guard
                    let headDateString: String = articleDateStringArray.first,
                    let headDate: Date = Date(dateString: headDateString, dateFormat: "yyyy/MM/dd") else { return }
                if calendar.isDateInYesterday(headDate) {
                    print("先頭のarrayが昨日の記事だった場合")
                    for i in 0 ..< checkedArticleByDateArray[0].count {
                        self.checkedArticleByDateArray[0][i] = true
                    }
                    break
                }
                
                if articleDateStringArray.count < 1 { break }
                guard let headNextDate: Date = Date(dateString: articleDateStringArray[1], dateFormat: "yyyy/MM/dd") else { return }
                if calendar.isDateInYesterday(headNextDate) {
                    print("先頭の次ののarrayが昨日の記事だった場合")
                    for i in 0 ..< checkedArticleByDateArray[1].count {
                        self.checkedArticleByDateArray[1][i] = true
                    }
                    break
                }
                print("先頭と2番めのarrayは昨日の記事ではなかったので何も選択しない。さよなら。")
            }
            break
        case .all:
            do {
                for d in 0 ..< checkedArticleByDateArray.count {
                    for a in 0 ..< checkedArticleByDateArray[d].count {
                        self.checkedArticleByDateArray[d][a] = true
                    }
                }
            }
            break
        case .notAll:
            do {
                for d in 0 ..< checkedArticleByDateArray.count {
                    for a in 0 ..< checkedArticleByDateArray[d].count {
                        self.checkedArticleByDateArray[d][a] = false
                    }
                }
            }
            break
        }
        articleTableView.reloadData()
        
    }
}

// MARK: - Firebaseのcomplition
extension ArticleListViewController {
    
    // MARK: Firebase Managerから記事の辞書型を取得してから1回呼ばれる
    public func successLoadDictArray(dictArray: [Dictionary<String, String>]) {
        var newArticleArray: [Article] = []
        
        for d in dictArray {
            guard let newArticle = Article(from: d) else { continue }
            newArticleArray.append(newArticle)
        }
        
        print("articleArray \(articleArray)")
        articleArray = articleArray.replace(newArray: newArticleArray) // キャッシュを引き継ぎ
        if articleArray.count == 0 { return }
        
        // 日付でソート(新しい順)
        articleArray.sort { $1.date < $0.date }
        
        // 更新する最初のindex num
        //        let startIndex = currentArticleCount
        // 読み込む数
        //        let addCount = articleArray.count - startIndex < addArticleNum ? articleArray.count - startIndex : addArticleNum
        //        let currentArticleCount = startIndex + addCount
        
        //        var currentDateString: String = ""
        //        var currentArticleArray: [Article] = []
        //        // セクションわけのために日付ごとに記事を分ける
        //        if let currentLastArticleArray = articleByDateArray.last {
        //            // 追加読み込み時
        //            currentDateString = currentLastArticleArray.first?.date.dateString() // "yyyy/MM/dd"
        //            currentArticleArray = (articleByDateArray.last?)! //
        //
        //            } else {
        //            // 初回読み込み時
        //            currentDateString = articleArray[0].date.dateString() // "yyyy/MM/dd"
        //            articleDateStringArray = [currentDateString] // ["yyyy/MM/dd"]
        //
        //        }
        
        
        // セクションわけのために日付ごとに記事を分ける
        var currentDateString: String = articleArray[0].date.dateString() // "yyyy/MM/dd"
        var currentArticleArray: [Article] = []
        articleDateStringArray = [currentDateString] // ["yyyy/MM/dd"]
        
        var newArticleByDateArray:[[Article]] = [] // 同じ日付同士の記事を管理する配列
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
        
        articleTableView.reloadData()
        
        newArticleByDateArray.removeAll(keepingCapacity: true)
        
        // サムネイルセットのリクエスト
        for j in 0 ..< articleByDateArray.count {
            for i in 0 ..< articleByDateArray[j].count {
                let ip = IndexPath(row: i, section: j)
                articleByDateArray[j][i].requestSetImage(reloadTargetTableView: self.articleTableView, indexPath: ip)
            }
        }
        
    }
    
    public func failedGetArcitleArray(message: String) {
        print(message)
    }
    
    public func successSignInAnonymously() {
        FirebaseDatabaseManager().getArcitleArray(vc: self)
    }
    
    public func failedSignInAnonymously(message: String) {
        print(message)
        FirebaseDatabaseManager().checkConectedNetwork(vc: self)
    }
    
    public func successConectedNetwork() {
        successSignInAnonymously()
    }
    
    public func failedConectedNetwork() {
        // ネットワーク接続がありませんAlertを出す
        let alert = UIAlertController(title: "通信エラー", message: "ネットワーク接続がありません", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "再試行", style: .default, handler: { _ in
            FirebaseAuthManager().signInAnonymously(vc: self)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func successPostNewArcitle() {
        print("successPostNewArcitleが呼ばれたよ")
    }
    
    func failedPostNewArcitle(message: String, faildValue: [String: String]) {
        print(message)
        let ud = UserDefaults.standard
        let pastFaildArray = ud.array(forKey: "paseFaildArray") ?? []
        ud.set(pastFaildArray + [faildValue], forKey: "paseFaildArray")
        ud.synchronize()
    }
}

// MARK: - tableView操作
extension ArticleListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return articleDateStringArray.count
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
        
        cell.urlLabel.text = article.url.absoluteString
        cell.timeLabel.text = article.date.timeString()
        if let comment = article.comment {
            if comment != "" {
                cell.commentLabel.isHidden = false
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
            cell.thumbnailImageView.image = UIImage(named: "thumbnail_noImage.png")
            print("サムネイルなし: \(indexPath.row): \(article.title ?? "no-title")")
        }
        
        if isEditingTableView {
            cell.setCheck(isSetCheck: checkedArticleByDateArray[indexPath.section][indexPath.row])
        } else {
            cell.setNoCheck()
        }
        
        // セルが選択された時の背景色を消す
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditingTableView {
            // 出力中のとき
            checkedArticleByDateArray[indexPath.section][indexPath.row] = !checkedArticleByDateArray[indexPath.section][indexPath.row]
            
            let cell = tableView.cellForRow(at: indexPath) as! ArticleTableViewCell
            cell.setCheck(isSetCheck: checkedArticleByDateArray[indexPath.section][indexPath.row])
            
        } else {
            // 通常時
            selectedUrl = articleByDateArray[indexPath.section][indexPath.row].url as URL
            performSegue(withIdentifier: "toReadWebVC", sender: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // スワイプで削除された時
            
            if let removeKey = articleByDateArray[indexPath.section][indexPath.row].selfArticleID {
                FirebaseDatabaseManager().removeArcitle(articleID: removeKey, vc: self)
            }
            
            articleByDateArray[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if articleByDateArray[indexPath.section].count == 0 {
                articleDateStringArray.remove(at: indexPath.section)
                articleByDateArray.remove(at: indexPath.section)
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isEditingTableView // 出力記事の選択中はスワイプ削除禁止
    }
}

// MARK: - scrollView操作
extension ArticleListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let distanceFromBottom = scrollView.contentSize.height - scrollView.contentOffset.y
        if distanceFromBottom < scrollView.frame.size.height {
            // tableviewが下までスクロールした時
            print("you reached end of the table")
        }
    }
}

// MARK: - view操作
extension ArticleListViewController: UINavigationControllerDelegate {
    
    func initView() {
        articleTableView.frame = CGRect(x: 0, y: ViewSize.navigationbarBottomY,
                                        width: self.view.frame.width, height: self.view.frame.height - ViewSize.navigationbarBottomY)
        articleTableView.delegate = self
        articleTableView.dataSource = self
        articleTableView.register(UINib(nibName: "ArticleTableViewCell", bundle: nil),
                                  forCellReuseIdentifier: "articleCell")
        
        articleTableView.rowHeight = UITableViewAutomaticDimension
        articleTableView.estimatedRowHeight = 600
        articleTableView.sectionHeaderHeight = 20
        articleTableView.tableFooterView = UIView(frame: .zero) // 空白cellのセパレータを非表示
        articleTableView.separatorInset = UIEdgeInsetsMake(0, 8, 0, 0) // 文字の頭に合わせている
        
        self.view.addSubview(articleTableView)
        
        setNavigationBarContents()
        
        toolbar.frame = CGRect(x: 0, y: self.view.bottomY, width: self.view.frame.width, height: ViewSize.toolbarHeight)
        let markDownItem = UIBarButtonItem(title: "記事をマークダウンに変換", style: .plain, target: nil, action: #selector(ArticleListViewController.onTappedChangeToMarkDownButton(_:)))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexibleItem, markDownItem, flexibleItem ]
        // 最初はtoolbarを下に隠しておく
        toolbar.frame.origin.y = self.view.bottomY
        toolbar.tintColor = UIColor.black
        toolbar.barTintColor = UIColor.lightRed
        
        self.view.addSubview(toolbar)
    }
    
    func animateToolBar() {
        if isEditingTableView {
            // 出力モード
            UIView.animate(withDuration: 0.2, animations: {
                self.articleTableView.frame.size.height -= ViewSize.toolbarHeight
                self.toolbar.frame.origin.y = self.view.bottomY - self.toolbar.frame.size.height
            })
        } else {
            //通常モード
            UIView.animate(withDuration: 0.2, animations: {
                self.articleTableView.frame.size.height += ViewSize.toolbarHeight
                self.toolbar.frame.origin.y = self.view.bottomY
            })
        }
    }
    
    // MARK: isEditingTableViewに応じてnavigationControllerの要素を変更
    func setNavigationBarContents() {
        guard
            let navigationController = self.navigationController,
            let navigationBarTopItem = navigationController.navigationBar.topItem else {
                return
        }
        
        navigationController.navigationBar.barTintColor = UIColor.lightRed
        navigationController.navigationBar.tintColor = UIColor.black
        
        if isEditingTableView {
            let leftBarButtonItem = UIBarButtonItem(title: "条件選択", style: .plain, target: self, action: #selector(onTappedKindSelectButton(_:)))
            self.navigationItem.leftBarButtonItems = [leftBarButtonItem]
            let rightBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: self, action: #selector(onTappedOutputButton(_:)))
            self.navigationItem.rightBarButtonItems = [rightBarButtonItem]
            self.navigationItem.titleView = nil
            navigationBarTopItem.title = "記事を選択"
        } else {
            let leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onTappedAddButton(_:)))
            let bookmarkBarButtonItem = UIBarButtonItem(image: UIImage(named: "bookmark_normal.png"), style: .plain, target: self, action: #selector(openBookmarkButton(_:)))
            self.navigationItem.leftBarButtonItems = [leftBarButtonItem, bookmarkBarButtonItem]
            
            let rightBarButtonItem = UIBarButtonItem(title: "出力", style: .plain, target: self, action: #selector(onTappedOutputButton(_:)))
            let spaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            spaceItem.width = leftBarButtonItem.width + bookmarkBarButtonItem.width - rightBarButtonItem.width + 45 // 45は調整のため
            self.navigationItem.rightBarButtonItems = [rightBarButtonItem, spaceItem]
            navigationBarTopItem.title = ""
            let uiImageView = UIImageView(image: UIImage(named: "Posty_logo_1440_360.png"))
            uiImageView.frame.size.height = ViewSize.navigationbarHeight * 0.75
            uiImageView.frame.size.width = ViewSize.navigationbarHeight * 0.75 * 3
            uiImageView.contentMode = .scaleAspectFit
            self.navigationItem.titleView = uiImageView
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
        present(activitySheet, animated: true, completion: nil)
    }
    
    func showUrlTextInputAlert() {
        // MARK: テキストフィールド付きアラート表示
        let alert = UIAlertController(title: "URLからページを開きます", message: "URLを入力してください", preferredStyle: .alert)
        let placeholderText = "https://www.google.com/"
        
        // 「開く」ボタンの設定
        let openAction = UIAlertAction(title: "開く", style: .default, handler: { _ in
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
        alert.addTextField(configurationHandler: { textField in
            textField.attributedPlaceholder = NSAttributedString(string: placeholderText,
                                                                 attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        })
        
        alert.view.setNeedsLayout() // シミュレータの種類によっては、これがないと警告が発生
        
        // アラートを画面に表示
        self.present(alert, animated: true, completion: nil)
    }
    
    func openBookmarkVC() {
        // 画面遷移
        let sb = UIStoryboard(name: "Bookmark", bundle: nil)
        guard let naviVc = sb.instantiateInitialViewController() as? UINavigationController else { return }
        guard let vc = naviVc.topViewController as? BookmarkViewController else { return }
        vc.prevVC = self
        self.present(naviVc, animated: true, completion: nil)
        
    }
    func showKindSelectAlert() {
        let actionSheet = UIAlertController(title: "一括で記事を選択します", message: "条件を選択してください", preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "今日保存した記事", style: .default, handler: { _ in
            self.selectArticle(type: .today)
        })
        let action2 = UIAlertAction(title: "昨日保存した記事", style: .default, handler: { _ in
            self.selectArticle(type: .yesterday)
        })
        let action3 = UIAlertAction(title: "保存した全ての記事", style: .default, handler: { _ in
            self.selectArticle(type: .all)
        })
        
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(action3)
        actionSheet.addAction(cancel)
        
        self.present(actionSheet, animated: true, completion: nil)
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
        if let urlString = urlString, let url = URL(string: urlString) {
            
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
}
