//
//  ChatFriendTableViewController.swift
//  DogBook
//
//  Created by 李一正 on 2018/8/1.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class ChatFriendTableViewController: UITableViewController {

    let communicator = Communicator()
    var rooms : [Room] = []
    var friends : [Int:Dog] = [:]
    var friendImages : [Int:UIImage] = [:]
    var roomsLastChat : [Int:String] = [:]
    var myDogId = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        

        myDogId = UserDefaults.standard.integer(forKey: "dogId")
        getRooms()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rooms.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatFriend", for: indexPath) as! ChatFriendTableViewCell
        
        guard let roomId = rooms[indexPath.row].roomId else {
            return cell
        }
        guard let friend = friends[roomId] else {
            return cell
        }
        
        cell.chatFriendImageView.image = friendImages[roomId]
        cell.chatFriendNameLabel.text = "\(friend.name!)"
        cell.lastChatLabel.text = roomsLastChat[roomId]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height : CGFloat = 50 + 10 + 10
        return height
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as? ChatRoomViewController
        guard let row = tableView.indexPathForSelectedRow?.row else {
            return
        }
        let room = rooms[row]
        controller?.room = room
        controller?.friend = friends[room.roomId!]
        controller?.friendImage = friendImages[room.roomId!]
    }
    
    // MARK :- get remote data
 
    func getRooms(){
        var data = [String:Any]()
        data["status"] = SHOW_ROOMS
        data["dogId"] = myDogId
        
        communicator.doPost(url: ChatServlet, data: data) { (result) in
            guard let result = result else {
                return
            }
            
            guard let output = try? JSONDecoder().decode([Room].self, from: result) else {
                return
            }
            
            self.rooms = output
            for room in output {
                self.getRoomLastChat(roomId: room.roomId!)
                self.getFriendInfo(roomId : room.roomId!,dogOne: room.dogOne!, dogTwo: room.dogTwo!)
            }
        }
    }
    
    func getRoomLastChat(roomId : Int){
        var data = [String:Any]()
        data["status"] = GET_LAST_CHAT
        data["roomId"] = roomId
        
        communicator.doPost(url: ChatServlet, data: data) { (result) in
            guard let result = result else {
                return
            }
            guard let chat = try? JSONDecoder().decode(Chat.self, from: result) else {
                return
            }
            guard let chatText = chat.message else {
                return
            }
            self.roomsLastChat[roomId] = chatText
            
        }
        
    }
    
    func getFriendInfo(roomId : Int,dogOne:Int ,dogTwo :Int){
        var friendId : Int!
        if dogOne == myDogId {
            friendId = dogTwo
        } else {
            friendId = dogOne
        }
        
        let dog = Dog(ownerId: nil, dogId: friendId, name: nil, gender: nil, variety: nil, birthday: nil, age: nil)
        
        guard let uploadData = try? JSONEncoder().encode(dog) else {
            return
        }
        
        communicator.doPost(url: DogServlet, data: uploadData, status: GET_DOG_INFO, kind: "dog") { (result) in
            
            guard let result = result else {
                return
            }
            
            guard var dog = try? JSONDecoder().decode(Dog.self, from: result) else {
                return
            }
            
            dog.dogId = friendId
            self.friends[roomId] = dog
            self.getFriendImage(roomId: roomId,friendId: friendId)
        }
        
    }
    
    func getFriendImage(roomId: Int ,friendId : Int){
        var data = [String:Any]()
        data["status"] = GET_PROFILE_PHOTO
        data["dogId"] = friendId
        data["imageSize"] = 50
        
        communicator.doPost(url: MediaServlet, data: data) { (result) in
            guard let result = result else {
                return
            }
            
            guard let image = UIImage(data: result) else {
                return
            }
            
            self.friendImages[roomId] = image
            if self.friendImages.count == self.rooms.count {
                self.tableView.reloadData()
            }
        }
        
    }

}
