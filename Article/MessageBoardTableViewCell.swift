//
//  MessageBoardTableViewCell.swift
//  DogBook
//
//  Created by 李一正 on 2018/7/29.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class MessageBoardTableViewCell: UITableViewCell {

    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var messageContentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
