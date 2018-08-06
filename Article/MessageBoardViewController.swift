//
//  MessageBoardViewController.swift
//  DogBook
//
//  Created by 李一正 on 2018/7/29.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class MessageBoardViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageInput: UITextField!
    @IBOutlet weak var sendMessageButton: UIButton!
    
    let communicator = Communicator()
    var messages = [Message]()
    var friendNames = [Int:String]()
    var friendImages = [Int:UIImage]()
    var articleId = -1
    var imageHeight : CGFloat! = 0
    var contentHeight : CGFloat! = 0
    var messageBottomConstraint : NSLayoutConstraint?
    var sendButtonBottomConstraint : NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .singleLine
        
        tabBarController?.tabBar.isHidden = true
        
        messageBottomConstraint = NSLayoutConstraint(item: messageInput, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -10)
        
        sendButtonBottomConstraint = NSLayoutConstraint(item: sendMessageButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -10)
        
        view.addConstraint(messageBottomConstraint!)
        view.addConstraint(sendButtonBottomConstraint!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotificaion), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotificaion), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        getMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if articleId == -1 {
            return
        }
    }
    
    
    @IBAction func sendMessageBtnPressed(_ sender: UIButton) {
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
            self.tableView.reloadData()
        }
        
    }
    
    func sendMessage(){
        let dogId = UserDefaults.standard.integer(forKey: "dogId")
        
        guard let content = messageInput.text else {
            return
        }
        let message = Message(id: nil, dogId: dogId, articleId: articleId, content: content)
        
        messageInput.text = ""
        
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
extension MessageBoardViewController : UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height : CGFloat!
        if contentHeight == 0 || imageHeight == 0 {
            return 0
        }
        if contentHeight > imageHeight {
            height = contentHeight + 30 + 20
            return height
        } else {
            height = imageHeight + 20
            return height
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageBoardTableViewCell
        
        guard let dogId = messages[indexPath.row].dogId else {
            return cell
        }
        cell.friendNameLabel.text = friendNames[dogId]
        cell.friendImageView.image = friendImages[dogId]
        cell.messageContentLabel.text = messages[indexPath.row].content
        
        self.contentHeight = cell.messageContentLabel.frame.size.height
        self.imageHeight = cell.friendImageView.frame.size.height
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        messageInput.endEditing(true)
    }
    
}
