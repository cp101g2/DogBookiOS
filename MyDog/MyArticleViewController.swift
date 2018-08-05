//
//  MyArticleViewController.swift
//  DogBook
//
//  Created by 李一正 on 2018/8/5.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class MyArticleViewController: UIViewController {

    @IBOutlet weak var myArticleTableView: UITableView!
    @IBOutlet weak var myMessageInputField: UITextField!
    @IBOutlet weak var myMessageSendBtn: UIButton!
    
    let communicator = Communicator()
    var messages = [Message]()
    var friendNames = [Int:String]()
    var friendImages = [Int:UIImage]()
    var articleId = -1
    var imageHeight : CGFloat! = 0
    var contentHeight : CGFloat! = 0
    var messageBottomConstraint : NSLayoutConstraint?
    var sendButtonBottomConstraint : NSLayoutConstraint?
    var likeCount = 0
    var myProfileImage : UIImage!
    var articlImage : UIImage!
    var article : Article!
    var myDog : Dog!
    let data = [0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myArticleTableView.delegate = self
        articleId = article.articleId!
        
        messageBottomConstraint = NSLayoutConstraint(item: myMessageInputField, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -10)
        
        sendButtonBottomConstraint = NSLayoutConstraint(item: myMessageSendBtn, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -10)
        
        view.addConstraint(messageBottomConstraint!)
        view.addConstraint(sendButtonBottomConstraint!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotificaion), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotificaion), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        getMessages()
        getLikeCount(articleId:articleId)
    }
    @IBAction func sendMyMessage(_ sender: UIButton) {
        sendMessage()
    }
    // MARK :- keyboard
    
    @objc
    func handleKeyboardNotificaion(notification:NSNotification){
        if let userInfo = notification.userInfo {
            let keybaordFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
            let isKeyboardshowing = notification.name
            
            if isKeyboardshowing == Notification.Name.UIKeyboardWillShow {
                messageBottomConstraint?.constant = -keybaordFrame.height-10
                sendButtonBottomConstraint?.constant = -keybaordFrame.height-10
            } else {
                messageBottomConstraint?.constant = -10
                sendButtonBottomConstraint?.constant = -10
            }
            
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }) { (completed) in
                
            }
            
        }
    }
    
    // MARK :- get remote data
    func getMessages(){
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
            
            self.messages = output
            
            for message in output {
                self.getFriendInfo(dogId: message.dogId!)
                self.getFriendImage(dogId: message.dogId!)
            }
        }
    }
    
    
    func getFriendInfo(dogId : Int){
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
            
            self.friendNames[dogId] = name
        }
    }
    
    func getFriendImage(dogId : Int){
        
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
            
            self.friendImages[dogId] = image
            self.myArticleTableView.reloadData()
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
            
            guard let count = output["likeCount"] else {
                return
            }
            self.likeCount = count
            
        }
        
    }
    func sendMessage(){
        let dogId = UserDefaults.standard.integer(forKey: "dogId")
        
        guard let content = myMessageInputField.text else {
            return
        }
        let message = Message(id: nil, dogId: dogId, articleId: articleId, content: content)
        
        myMessageInputField.text = ""
        
        guard let uploadData = try? JSONEncoder().encode(message) else{
            return
        }
        
        communicator.doPost(url: ArticleServlet, data: uploadData, status: SEND_MESSAGE, kind: "message") { (result) in
            
            guard let result = result else {
                return
            }
            
            guard let output = try? JSONSerialization.jsonObject(with: result, options: []) as? [String:String] else {
                return
            }
            
            if output!["Success"] == "success" {
                self.messages = []
                self.friendNames = [:]
                self.friendImages = [:]
                self.getMessages()
            }
            
        }
    }
}
extension MyArticleViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count + messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! MyArticleTableViewCell
            
            cell.myNameLabel.text = myDog.name!
            cell.myProfileImageView.image = myProfileImage
            cell.myArticleContentLabel.text = article.content
            
            let cellFrameWidth = cell.frame.size.width
            
            guard let articleImage = articlImage?.resize(willSetWidth: cellFrameWidth) else {
                print("article get image or resize fail")
                return cell
            }
            cell.myArticleImageView.image = articleImage
            
            let imageWidth = cell.myArticleImageView.image?.size.width
            let r = self.view.frame.size.width / imageWidth!
            
            let width = self.view.frame.size.width
            let height = (cell.myArticleImageView.image?.size.height)! * r
            
            let imageFrame = CGRect(x: 0, y: 0, width: width, height: height)
            
            cell.myProfileImageView.frame = imageFrame
            
            cell.myArticleLikeLabel.text = "\(likeCount) likes"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! ArticleMessageTableViewCell
            
            let message = messages[indexPath.row-1]
            guard let friendId = message.dogId else {
                print("get friendId fail")
                return cell
            }
            
            cell.messagerImageView.image = friendImages[friendId]
            cell.messagerNameLabel.text = friendNames[friendId]
            cell.messagerContentLabel.text = message.content
            
            self.contentHeight = cell.messagerContentLabel.frame.size.height
            self.imageHeight = cell.messagerImageView.frame.size.height
            
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myMessageInputField.endEditing(true)
    }
    
    
}
