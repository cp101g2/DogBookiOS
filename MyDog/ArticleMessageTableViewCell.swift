//
//  ArticleMessageTableViewCell.swift
//  DogBook
//
//  Created by 李一正 on 2018/8/5.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class ArticleMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messagerImageView: UIImageView!
    @IBOutlet weak var messagerNameLabel: UILabel!
    @IBOutlet weak var messagerContentLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
