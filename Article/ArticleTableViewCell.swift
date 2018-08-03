//
//  ArticleTableViewCell.swift
//  DogBook
//
//  Created by 李一正 on 2018/7/27.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var authorImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var articleLabel: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!
    
    @IBOutlet weak var messageBoardBtn: UIButton!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var likeCountLabel: UILabel!
    
    let communicator = Communicator()
    
    var likeTap : UITapGestureRecognizer!
    var articleId : Int!
    var isLike : Bool!
    var likeCount : Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        likeTap = UITapGestureRecognizer(target: self, action: #selector(like))
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @objc
    func like(){
        if isLike {
            isLike = false
            deleteLike()
            likeCount = likeCount - 1
            likeImageView.image = UIImage(named: "favorite_border_black_24pt")
        } else {
            isLike = true
            addLike()
            likeCount = likeCount + 1
            likeImageView.image = UIImage(named: "favorite_black_24pt")
        }
        likeCountLabel.text = "\(likeCount) likes"
        print("alread add.\(self.tag)")
    }
    
    func addLike(){
        let dogId = UserDefaults.standard.integer(forKey: "dogId")
        var data = [String:Any]()
        data["status"] = ADD_LIKE
        data["articleId"] = self.tag
        data["dogId"] = dogId
        
        communicator.doPost(url: ArticleServlet, data: data) { (result) in
            
        }
        
    }
    
    func deleteLike(){
        let dogId = UserDefaults.standard.integer(forKey: "dogId")
        var data = [String:Any]()
        data["status"] = DELETE_LIKE
        data["articleId"] = self.tag
        data["dogId"] = dogId
        
        communicator.doPost(url: ArticleServlet, data: data) { (result) in
            
        }
        
    }
    
}
