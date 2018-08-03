//
//  ChatFriendTableViewCell.swift
//  DogBook
//
//  Created by 李一正 on 2018/8/1.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class ChatFriendTableViewCell: UITableViewCell {

    @IBOutlet weak var chatFriendImageView: UIImageView!
    @IBOutlet weak var chatFriendNameLabel: UILabel!
    @IBOutlet weak var lastChatLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
