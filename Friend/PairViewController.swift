//
//  PairViewController.swift
//  DogBook
//
//  Created by Apple on 2018/7/24.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit
import GameplayKit

struct test: Codable {
    var name:String
    var imageID: String
    var variety: String
}


class PairViewController: UIViewController {
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var imageViewBorder: UIImageView!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var dogIdLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var varietyLabel: UILabel!
    
    let communicator = Communicator()
    
    var friendId : [Int] = []
    var AllUserId : [Int] = []
    //選到的陌生人ID
    var currentStrangerId = 0
    
    var StrangerInfoDictionary = [Int:Dog]()
    var StrangerImageDictionary = [Int:UIImage]()
    var StrangerBackgroundImageDictionary = [Int:UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //         NotificationCenter.default.addObserver(self, selector: #selector(reloadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        backgroundView.layer.borderWidth = 2
        backgroundView.layer.cornerRadius = 10
        imageViewBorder.layer.borderWidth = 2
        imageViewBorder.layer.cornerRadius = imageViewBorder.bounds.width/2
        //下載全部user, 下載Friends , Alluser - Friends = Strangers
        downloadAllUserIdList()
        getFriendIdList()
        
        
    }
    
    
    //    //加了好友後刷新
    //    @objc
    //    func reloadList() {
    //
    //
    //        self.StrangerInfoDictionary = [:]
    //        self.StrangerImageDictionary = [:]
    //
    //        downloadAllUserIdList()
    //        getFriendIdList()
    //
    //    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //找下一個陌生人
    @IBAction func byn(_ sender: Any) {
        likeButton.isUserInteractionEnabled = true
//        likeButton.setTitle("LIKE", for: .normal)
        likeButton.alpha = 1.0
        random()
    }
    
    
    //送交友邀請
    @IBAction func sendInviteBtnPressed(_ sender: Any) {
        
        //         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        
        likeButton.isUserInteractionEnabled = false
        //        likeButton.tintColor = UIColor.gray
        likeButton.alpha = 0.4
        //      likeButton.titleLabel?.font.withSize(2.0)
//        likeButton.setTitle("已送出", for: .normal)
        
        sendInvite()
    }
    
    
    func sendInvite() {
        
        let dogId = UserDefaults.standard.integer(forKey: "dogId")
        var data = [String:Any]()
        data["action"] = ADD_FRIEND_TO_CHECKLIST
        data["dogId"] = dogId
        data["inviteDogId"] =  self.currentStrangerId
        communicator.doPost(url: FriendServlet, data: data) { (result) in
            guard let result = result else {
                assertionFailure("get data fail")
                return
            }
            guard let output = (try? JSONSerialization.jsonObject(with: result, options: [])) as? [String:Int] else {
                return
            }
        }
    }
    
    
    
    
    func random () {
        
        let shuffledDistribution = GKShuffledDistribution(lowestValue: 0, highestValue: self.AllUserId.count - 1)
        
        let index  = shuffledDistribution.nextInt()
        let dogId = self.AllUserId[index]
        
        
        photoView.image = self.StrangerImageDictionary[dogId]
        varietyLabel.text = self.StrangerInfoDictionary[dogId]?.variety
        backgroundView.image = self.StrangerBackgroundImageDictionary[dogId]
        nameLabel.text = self.StrangerInfoDictionary[dogId]?.name
        dogIdLabel.text = "\((self.StrangerInfoDictionary[dogId]?.dogId)!)"
        self.currentStrangerId = (self.StrangerInfoDictionary[dogId]?.dogId)!
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    //下載所有user -> 下載user info -> 扣掉朋友 -->陌生人
    func downloadAllUserIdList(){
        self.AllUserId = []
        // 準備將資料轉為JSON
        let dogId = UserDefaults.standard.integer(forKey: "dogId")
        let dog = Dog(ownerId: nil, dogId: dogId, name: nil, gender: nil, variety: nil, birthday: nil, age: nil)
        let action = GetAllDog(status: GET_All_Dog, dog: dog)
        // 準備將資料轉為JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = .init()
        
        // 轉為JSON
        guard let uploadData = try? encoder.encode(action) else {
            assertionFailure("JSON encode Fail")
            return
        }
        // 送資料 and 解析回傳的JSON資料
        communicator.doPost(url: DogServlet, data: uploadData) { (result) in
            
            guard let result = result else {
                assertionFailure("get data fail")
                return
            }
            guard let output = try? JSONDecoder().decode([Dog].self, from: result) else {
                assertionFailure("get output fail")
                return
            }
            
            for friendId in output {
                
                self.getAllUserInfo(dogId: friendId.dogId!)
                self.getAllUserImage(dogId: friendId.dogId!)
                self.getBackgroundImage(dogId: friendId.dogId!)
                
            }
        }
    }
    
    
    func getAllUserInfo (dogId:Int){
        let dog = Dog(ownerId: nil, dogId: dogId, name: nil, gender: nil, variety: nil, birthday: nil, age: nil)
        let action = GetDogInfo(status: GET_DOG_INFO, dog: dog)
        
        // 準備將資料轉為JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = .init()
        
        // 轉為JSON
        guard let uploadData = try? encoder.encode(action) else {
            assertionFailure("JSON encode Fail")
            return
        }
        // 送資料 and 解析回傳的JSON資料
        communicator.doPost(url: DogServlet, data: uploadData) { (result) in
            
            guard let result = result else {
                assertionFailure("get data fail")
                return
            }
            guard var output = try? JSONDecoder().decode(Dog.self, from: result) else {
                assertionFailure("get output fail")
                return
            }
            print(output)
            output.dogId = dogId
            self.AllUserId.append(dogId)
            self.StrangerInfoDictionary[dogId] = output
            
            self.StrangerInfoDictionary.removeValue(forKey: UserDefaults.standard.integer(forKey: "dogId"))
            if let index = self.AllUserId.index(of: UserDefaults.standard.integer(forKey: "dogId")) {
                self.AllUserId.remove(at: index)
            }
            
            for friendId in self.friendId {
                self.StrangerInfoDictionary.removeValue(forKey: friendId)
                
                if let index = self.AllUserId.index(of: friendId) {
                    self.AllUserId.remove(at: index)
                    
                }
            }
            
            
            
        }
        
    }
    
    
    func getFriendIdList() {
        self.friendId = []
        // 準備將資料轉為JSON
        let dogId = UserDefaults.standard.integer(forKey: "dogId")
        let action = GetMyFriendList(action: GET_FRIEND_INFO, dogId: dogId)
        //(2
        //        var data = [String:Any]()
        //        data["status"] = GET_FRIEND_INFO
        //        data["dogId"] = dogId
        //
        //        communicator.doPost(url: <#T##String#>, data: data) { (<#Data?#>) in
        //            <#code#>
        //        }
        // 準備將資料轉為JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = .init()
        
        // 轉為JSON
        guard let uploadData = try? encoder.encode(action) else {
            assertionFailure("JSON encode Fail")
            return
        }
        // 送資料 and 解析回傳的JSON資料
        communicator.doPost(url: FriendServlet, data: uploadData) { (result) in
            
            guard let result = result else {
                assertionFailure("get data fail")
                return
            }
            guard let output = try? JSONDecoder().decode([GetMyFriendList].self, from: result) else {
                assertionFailure("get output fail")
                return
            }
            
            
            for friendId in output {
                self.friendId.append(friendId.dogId)
            }
            
            print("朋友ＩＤ：\(self.friendId)")
            
        }
        
    }
    
    //拿圖片
    func getAllUserImage(dogId: Int){
        let action = DogMediaAction(status: GET_PROFILE_PHOTO, dogId: dogId,imageSize : 150)
        // 準備將資料轉為JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = .init()
        // 轉為JSON
        guard let uploadData = try? encoder.encode(action) else {
            assertionFailure("JSON encode Fail")
            return
        }
        // 送資料 and 解析回傳的JSON資料
        communicator.doPost(url: MediaServlet, data: uploadData) { (result) in
            
            guard let result = result else {
                assertionFailure("get data fail")
                return
            }
            
            guard let image = UIImage.init(data: result) else {
                return
            }
            self.StrangerImageDictionary[dogId] = image
        }
    }
    
    //拿圖片
    func getBackgroundImage(dogId: Int){
        let action = DogMediaAction(status: GET_PROFILE_BACKGROUND_PHOTO, dogId: dogId,imageSize : 150)
        // 準備將資料轉為JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = .init()
        // 轉為JSON
        guard let uploadData = try? encoder.encode(action) else {
            assertionFailure("JSON encode Fail")
            return
        }
        // 送資料 and 解析回傳的JSON資料
        communicator.doPost(url: MediaServlet, data: uploadData) { (result) in
            
            guard let result = result else {
                assertionFailure("get data fail")
                return
            }
            
            guard let image = UIImage.init(data: result) else {
                return
            }
            self.StrangerBackgroundImageDictionary[dogId] = image
        }
    }
    
    
    
    
}
