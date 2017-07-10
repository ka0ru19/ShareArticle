//
//  ArticleTableViewCell.swift
//  ShareArticle
//
//  Created by Wataru Inoue on 2017/06/11.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var checkMarkImageView: UIImageView!
    
    @IBOutlet weak var articleStackViewBaseView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        articleStackViewBaseView.layer.borderWidth = 0.5
        articleStackViewBaseView.layer.borderColor = UIColor.black.cgColor
        articleStackViewBaseView.layer.cornerRadius = 4.0
        articleStackViewBaseView.clipsToBounds = true
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setCheck(isSetCheck: Bool) {
        if isSetCheck {
            checkMarkImageView.backgroundColor = UIColor.blue
        } else {
            checkMarkImageView.backgroundColor = UIColor.lightGray
        }
    }
    
    func setNoCheck() {
        checkMarkImageView.backgroundColor = UIColor.white
    }
}
