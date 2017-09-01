//
//  WelcomeViewController.swift
//  ShareArticle
//
//  Created by Wataru Inoue on 2017/08/30.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func tutorialButtonTapped(_ sender: UIButton) {
        // 画面遷移
        let sb = UIStoryboard(name: "Tutorial", bundle: nil)
        guard let vc = sb.instantiateInitialViewController() else { return }
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {

        //MARK: - 匿名としてログイン
        Auth.auth().signInAnonymously(completion: { (user: User?, error: Error?) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            if let user = user {
                let userLoginTypeDescriptionText = user.isAnonymous ? "Anonymous": user.email ?? "user isnt Anonymous but has no email."
                print("userを取得しました. uid: \(user.uid), type: \(userLoginTypeDescriptionText)")
                // TODO: 初回起動時で以前アプリをインストールした経験があったら、以前のデータを消すか選択して、消せる
                // 画面遷移
                let sb = UIStoryboard(name: "Main", bundle: nil)
                guard let vc = sb.instantiateInitialViewController() else { return }
                self.present(vc, animated: true, completion: nil)
            } else {
                print("userを取得できませんでした")
            }
        })

    }


}
