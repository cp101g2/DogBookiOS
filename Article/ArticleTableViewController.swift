//
//  ArticleTableViewController.swift
//  DogBook
//
//  Created by 李一正 on 2018/7/25.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class ArticleTableViewController: UITableViewController {
    
    let communicator = Communicator()
    let cell = "ArticleCell"
    let textFontSize:CGFloat = 16.0
    let contentMargin:CGFloat = 30
    
    
    var articles : [Article]?
    var articleImages = [Int:UIImage]()
    var authorImages = [Int:UIImage]()
    var authorNames = [Int:String]()
    var likeCount = [Int:Int]()
    var isLike = [Int:Bool]()
    var messageBoardSize = [Int:Int]()
    var dogId : Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        dogId = UserDefaults.standard.integer(forKey: "dogId")
        articles = []
        articleImages = [:]
        authorImages = [:]
        authorNames = [:]
        likeCount = [:]
        isLike = [:]
        messageBoardSize = [:]
        getArticles()
    }
    
    @IBAction func openMessageBoard(_ sender: UIButton) {
        print(sender.tag)
        let nextVC = UIStoryboard(name: "ArticleStoryboard", bundle: nil).instantiateViewController(withIdentifier: "messageBoard") as! MessageBoardViewController
        nextVC.articleId = sender.tag
        let navigation = UINavigationController(rootViewController: nextVC)
        self.show(navigation, sender: nil)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cell, for: indexPath) as! ArticleTableViewCell
        
        let article = articles![indexPath.row]
        
        guard let authorId = article.dogId else {
            return cell
        }
        guard let articleId = article.articleId else {
            return cell
        }
        guard let likes = likeCount[articleId] else {
            return cell
        }
        guard let isLike = isLike[articleId] else {
            return cell
        }
        guard let messageSize = messageBoardSize[articleId] else {
            return cell
        }
        
        cell.tag = articleId
        cell.isLike = isLike
        
        if isLike {
            cell.likeImageView.image = UIImage(named: "favorite_black_24pt")
        }
        
        cell.authorImageView.image = authorImages[authorId]
        cell.likeCountLabel.text = "\(likes) likes"
        cell.messageBoardBtn.setTitle("留言(\(messageSize))", for: .normal)
        cell.messageBoardBtn.tag = articleId
        guard let authorImage = authorImages[authorId]?.resize(willSetWidth: 50.0, willSetHeight: 50.0) else {
            print("author get image or resize fail")
            return cell
        }
        
        let cellFrameWidth = self.view.frame.size.width
        
        guard let articleImage = articleImages[articleId]?.resize(willSetWidth: cellFrameWidth) else {
            print("article get image or resize fail")
            return cell
        }
        
        cell.authorLabel.text = authorNames[authorId]
        cell.authorImageView.image = authorImage
        cell.articleLabel.text = article.content
        cell.articleImageView.image = articleImage
        
        let imageWidth = cell.articleImageView.image?.size.width
        let r = self.view.frame.size.width / imageWidth!
        
        let width = self.view.frame.size.width
        let height = (cell.articleImageView.image?.size.height)! * r
        
        let imageFrame = CGRect(x: 0, y: 0, width: width, height: height)
        let labelFrme = CGRect(x: 0, y: 0, width: width - 32, height: textFontSize)
        
        cell.articleImageView.frame = imageFrame
        cell.authorImageView.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
        cell.articleLabel.frame = labelFrme
        
        
        cell.likeImageView.addGestureRecognizer(cell.likeTap)
        cell.isLike = false
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let articles = articles else {
            return 0
        }
        return articles.count
    }

    
    func getArticles(){
        var data = [String:Any]()
        data["status"] = GET_ARTICLES
        data["dogId"] = dogId
        
        communicator.doPost(url: ArticleServlet, data: data) { (result) in
            
            guard let result = result,let output = try? JSONDecoder().decode([Article].self, from: result)  else {
                return
            }
            self.articles = output
            print(output.count)
            for article in output {
                guard let authorId = article.dogId,let articleId = article.articleId,let mediaId = article.mediaId  else {
                    return
                }
                self.getAuthorInfo(dogId: authorId)
                self.getLikeCount(articleId: articleId)
                self.getIsLike(articleId: articleId)
                self.getAuthorImage(dogId: authorId)
                self.getArticleImage(articleId: articleId, mediaId: mediaId)
                self.getMessagesSize(articleId: articleId)
            }
        
        }
    }
    
    func getAuthorInfo(dogId : Int){
        let dog = Dog(ownerId: nil, dogId: dogId, name: nil, gender:  nil, variety:nil,birthday:nil ,age: nil)
        
        // 轉為JSONData
        guard let uploadData = try? JSONEncoder().encode(dog) else {
            assertionFailure("JSON encode Fail")
            return
        }
        // 送資料 and 解析回傳的JSON資料
        communicator.doPost(url: DogServlet, data: uploadData, status: GET_DOG_INFO, kind: "dog") { (result) in
            
            guard let result = result else {
                assertionFailure("get data fail")
                return
            }
            guard let output = try? JSONDecoder().decode(Dog.self, from: result) else {
                return
            }
            guard let name = output.name else {
                return
            }

            self.authorNames[dogId] = name
//            self.tableView.reloadData()
        }
        
        
    }
    
    func getAuthorImage(dogId : Int){
        
        var data = [String:Any]()
        data["status"] = GET_PROFILE_PHOTO
        data["dogId"] = dogId
        data["imageSize"] = 50
        
        communicator.doPost(url: MediaServlet, data: data) { (result) in
            guard let result = result else {
                assertionFailure("get data fail")
                return
            }
            
            guard let image = UIImage.init(data: result) else {
                return
            }
            
            self.authorImages[dogId] = image
//            self.tableView.reloadData()
        }
        
    }
    
    func getArticleImage(articleId: Int ,mediaId:Int){
        
        var data = [String:Any]()
        data["status"] = GET_ARTICLES
        data["mediaId"] = mediaId
        data["imageSize"] = UIScreen.main.nativeBounds.width
        // 送資料 and 解析回傳的JSON資料
        communicator.doPost(url: MediaServlet, data: data) { (result) in
            guard let result = result else {
                assertionFailure("get data fail")
                return
            }
            
            guard let image = UIImage.init(data: result) else {
                return
            }
            
            self.articleImages[articleId] = image
            print(self.articleImages.count)
            if self.articleImages.count == self.articles?.count {
                print("有哦")
                self.tableView.reloadData()
            }
        }
        
    }
    
    func getLikeCount(articleId: Int){
        
        var data = [String:Any]()
        data["status"] = GET_LIKE_COUNT
        data["articleId"] = articleId
        
        communicator.doPost(url: ArticleServlet, data: data) { (result) in
            
            guard let result = result else {
                return
            }
            
            guard let output = try? JSONSerialization.jsonObject(with: result, options: []) as! [String:Int] else {
                return
            }
            let likeCount = output["likeCount"]
            self.likeCount[articleId] = likeCount
            
        }
        
    }
    
    func getIsLike(articleId:Int){
        var data = [String:Any]()
        data["status"] = SELECT_LIKE
        data["articleId"] = articleId
        data["dogId"] = dogId
        
        communicator.doPost(url: ArticleServlet, data: data) { (result) in
            
            guard let result = result else {
                return
            }
            
            guard let output = try? JSONSerialization.jsonObject(with: result, options: []) as? [String:Bool] else {
                return
            }
            
            let isLike = output!["isLike"]
            self.isLike[articleId] = isLike
        }
    }
    
    func getMessagesSize(articleId : Int){
        var data = [String:Any]()
        data["status"] = GET_MESSAGE_BOARD
        data["articleId"] = articleId
        communicator.doPost(url: ArticleServlet, data: data) { (result) in
            guard let result = result else {
                return
            }
            guard let output = try? JSONDecoder().decode([Message].self, from: result) else {
                return
            }
            
            self.messageBoardSize[articleId] = output.count
        }
    }
    
    
}

