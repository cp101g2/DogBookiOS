//
//  ChatRoomViewController.swift
//  DogBook
//
//  Created by 李一正 on 2018/8/1.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class ChatRoomViewController: UIViewController {
    
    @IBOutlet weak var roomTableView: UITableView!
    @IBOutlet weak var roomTitle: UINavigationItem!
    @IBOutlet weak var messageInputField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    let communictor = Communicator()
    let textFontSize : CGFloat = 10
    
    
    var friend : Dog!
    var room : Room!
    var friendImage : UIImage?
    var chats : [Chat] = []
    var myDogId : Int = -1
    var labelHeight : CGFloat = 0
    var imageHeight : CGFloat = 0
    var messageBottomConstraint : NSLayoutConstraint?
    var sendButtonBottomConstraint : NSLayoutConstraint?
    
    var isBottom = false
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true

        myDogId = UserDefaults.standard.integer(forKey: "dogId")
        roomTableView.delegate = self
        roomTitle.title = "\(friend.name!)"
        getChatsRecording(roomId: room.roomId!)
        
        messageBottomConstraint = NSLayoutConstraint(item: messageInputField, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        
        sendButtonBottomConstraint = NSLayoutConstraint(item: sendButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        
        view.addConstraint(messageBottomConstraint!)
        view.addConstraint(sendButtonBottomConstraint!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotificaion), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotificaion), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showMessage), name: Notification.Name.init("chat"), object: nil)
        
        

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // send message
    
    @IBAction func sendMessageButtonPressed(_ sender: UIButton) {
        
        guard let message = messageInputField.text else {
            return
        }
        
        guard let roomId = room?.roomId else {
            return
        }
        
        let chat = Chat(chatId: 0, senderId: myDogId, receiverId: 0, chatroomId: roomId, message: message, type: "chat")
        
        // 準備將資料轉為JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = .init()
        
        // 轉為JSON
        guard let uploadData = try? encoder.encode(chat) else {
            assertionFailure("JSON encode Fail")
            return
        }
        
        guard let jsonString = String(data : uploadData, encoding: .utf8) else {
            assertionFailure("cast jsonString fail")
            return
        }
        AppDelegate.chatWebsocketClient.sendMessage(jsonString)
        messageInputField.text = ""
        chats.append(chat)
        isBottom = false
        roomTableView.reloadData()
        
    }
    
    
    
    
    // MARK :- keyboard
    
    @objc
    func handleKeyboardNotificaion(notification:NSNotification){
        if let userInfo = notification.userInfo {
            let keybaordFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
            let isKeyboardshowing = notification.name
            
            if isKeyboardshowing == Notification.Name.UIKeyboardWillShow {
                messageBottomConstraint?.constant = -keybaordFrame.height
                sendButtonBottomConstraint?.constant = -keybaordFrame.height
            } else {
                messageBottomConstraint?.constant = 0
                sendButtonBottomConstraint?.constant = 0
            }
            
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }) { (completed) in
                let indexPath = IndexPath(item: self.chats.count-1, section: 0)
                self.roomTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
            
        }
    }
    
    
    // MARK :- get remote data
    func getChatsRecording(roomId : Int){
        var data = [String:Any]()
        data["status"] = GET_CHATS_RECODING
        data["roomId"] = roomId
        
        communictor.doPost(url: ChatServlet, data: data) { (result) in
            guard let result = result else {
                return
            }
            guard let chats = try? JSONDecoder().decode([Chat].self, from: result) else {
                return
            }
            
            self.chats = chats
            self.roomTableView.reloadData()
            
        }
    }
    
    @objc
    func showMessage(_ notification : Notification){
        guard let chat = notification.userInfo?["message"] as? Chat else {
            return
        }
        if chat.chatroomId == room?.roomId {
            chats.append(chat)
            isBottom = false
            roomTableView.reloadData()
        }
        
    }

}
extension ChatRoomViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let chat = chats[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatRoomTableViewCell
        
        
        let maxWidth = cell.frame.width
        
        let chatView = ChatView(chat:chat,maxWidth:maxWidth,offsetY:20)
        
        for view in cell.subviews {
            view.removeFromSuperview()
        }
        cell.addSubview(chatView)
        if chat.senderId != myDogId {
            let imageFrame = CGRect(x: 10, y: 16, width: 48, height: 48)
            let friendImageView = UIImageView(frame: imageFrame)
            friendImageView.image = friendImage!
            friendImageView.clipsToBounds = true
            friendImageView.layer.cornerRadius = 24
            cell.addSubview(friendImageView)
        }
        
        labelHeight = chatView.frame.height
        
        if indexPath.row != chats.count-1 && !isBottom{
            let indexPath = IndexPath(item: self.chats.count-1, section: 0)
            self.roomTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        } else {
            self.isBottom = true
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let hight : CGFloat = labelHeight + 30

        return hight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        messageInputField.endEditing(true)
    }
    
    
    
}
