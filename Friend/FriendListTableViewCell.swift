//
//  FriendListTableViewCell.swift
//  DogBook
//
//  Created by Apple on 2018/7/24.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class FriendListTableViewCell: UITableViewCell {

    @IBOutlet weak var varietyLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var friendImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
