//
//  BookmarkViewController.swift
//  ShareArticle
//
//  Created by Wataru Inoue on 2017/08/31.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

class BookmarkViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let ud = UserDefaults.standard
    
    var bookmarkDictArray: [Dictionary<String, String>] = []
    
    var prevVC: ArticleListViewController? // 前の画面でvalueをもらってくる想定
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard
            let navigationController = self.navigationController,
            let navigationBarTopItem = navigationController.navigationBar.topItem else {
                return
        }
        
        navigationController.navigationBar.barTintColor = UIColor.lightRed
        navigationController.navigationBar.tintColor = UIColor.black
        navigationBarTopItem.title = "ブックマーク"

        
        bookmarkDictArray = ud.array(forKey: "bookmarkDictArray") as? [Dictionary<String, String>] ?? []

        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: .zero)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension BookmarkViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarkDictArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        let bookmarkDict = bookmarkDictArray[indexPath.row]
        
        cell.textLabel?.text = bookmarkDict["title"]
        cell.detailTextLabel?.text = bookmarkDict["urlText"]
        cell.detailTextLabel?.textColor = UIColor.gray
        
        return cell
    }
}
extension BookmarkViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let prevVC = prevVC else {
            self.dismiss(animated: true, completion: nil)
            return 
        }
        
        self.dismiss(animated: true, completion: {
            if let urlText = self.bookmarkDictArray[indexPath.row]["urlText"] {
            prevVC.selectedUrl = URL(string: urlText)
            prevVC.performSegue(withIdentifier: "toReadWebVC", sender: nil)
            }
        })
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            bookmarkDictArray.remove(at: indexPath.row)
            ud.set(bookmarkDictArray, forKey: "bookmarkDictArray")
            ud.synchronize()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}
