//
//  AddListTableViewCell.swift
//  DogBook
//
//  Created by Apple on 2018/7/27.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class AddListTableViewCell: UITableViewCell {
    @IBOutlet weak var addConfirmedBtn: UIButton!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var varietyLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var friendImageView: UIImageView!
    
    @IBOutlet weak var genderImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
