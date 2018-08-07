//
//  MyArticleTableViewCell.swift
//  DogBook
//
//  Created by 李一正 on 2018/8/5.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class MyArticleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var myProfileImageView: UIImageView!
    @IBOutlet weak var myNameLabel: UILabel!
    @IBOutlet weak var myArticleContentLabel: UILabel!
    @IBOutlet weak var myArticleImageView: UIImageView!
    @IBOutlet weak var myArticleLikeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
