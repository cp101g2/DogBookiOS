//
//  FriendSearchViewController.swift
//  DogBook
//
//  Created by Apple on 2018/7/24.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class FriendSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameSearchBar: UISearchBar!
    let communicator = Communicator()
    
    var friendId : [Int] = []
    var AllUserId : [Int] = []
    
    var AllUserInfoDictionary = [Int:Dog]()
    var currentAllUserInfoDictionary = [Int:Dog]()
    var allUserImageDictionary = [Int:UIImage]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        nameSearchBar.delegate = self
        
        alterLayout() //固定search bar
        
//         NotificationCenter.default.addObserver(self, selector: #selector(reloadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    //加了好友後刷新
//    @objc
//    func reloadList() {
//        
//        self.AllUserInfoDictionary = [:]
//        self.currentAllUserInfoDictionary = [:]
//  
//        downloadAllUserIdList()
//        getFriendIdList()
//        self.tableView.reloadData()
//    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadAllUserIdList()
        getFriendIdList()
       
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return currentAllUserInfoDictionary.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendSearchCell", for: indexPath) as? FriendSearchTableViewCell else {
            return UITableViewCell()
        }
        
        let AllUserId = self.AllUserId[indexPath.row]
        
       
        
        let image = self.allUserImageDictionary[AllUserId]
     
        guard let friend = self.currentAllUserInfoDictionary[AllUserId] else {
        
            return UITableViewCell()
        }
        
        cell.nameLabel.text = friend.name
        cell.ageLabel.text = String(format: "%01d", (friend.age)!) + "歲"
      
        cell.varietyLabel.text = friend.variety
        
        cell.friendImageView.image = image
        
        if friend.gender == "女" {
            cell.genderImageView.image = UIImage(named: "female")
        } else if friend.gender == "男" {
            cell.genderImageView.image =  UIImage(named: "male")
        }
        
        
        cell.addFriendBtn.tag = (friend.dogId)!
        
        cell.currentAllUserInfoDictionary = self.currentAllUserInfoDictionary
      
        cell.addFriendBtn.addTarget(self, action: #selector(addBtnPressed), for: UIControlEvents.touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nameSearchBar
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //固定searchbar
    func alterLayout() {
        tableView.tableHeaderView = UIView()
        //        friendListTableView.estimatedSectionHeaderHeight = 40
    }
    
    //searchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard !searchText.isEmpty else{
            currentAllUserInfoDictionary = [:]
            
            downloadAllUserIdList()
            getFriendIdList()
            return
        }
        
        
        currentAllUserInfoDictionary = AllUserInfoDictionary.filter({ friend -> Bool in
            (friend.value.name?.lowercased().contains(searchText.lowercased()))!
            
        })
    
        self.AllUserInfoDictionary = currentAllUserInfoDictionary
        self.AllUserId = []
        
        for friend in self.AllUserInfoDictionary {
            self.AllUserId.append(friend.key)
        }
        
        print("搜尋結果\(currentAllUserInfoDictionary)")
        tableView.reloadData()
        
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
            
            self.AllUserInfoDictionary[dogId] = output
            self.currentAllUserInfoDictionary[dogId] = output
            
            
            for friendId in self.friendId {
             print(friendId)
            self.AllUserInfoDictionary.removeValue(forKey: friendId)
            }
            
       
             for friendId in self.friendId {
                self.currentAllUserInfoDictionary.removeValue(forKey: friendId)
            }
            for friendId in self.friendId {
                if let index = self.AllUserId.index(of: friendId) {
                    self.AllUserId.remove(at: index)
                }
            }
            
            self.currentAllUserInfoDictionary.removeValue(forKey: UserDefaults.standard.integer(forKey: "dogId"))
            self.tableView.reloadData()
            
        }
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
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
            }
   
            self.tableView.reloadData()
          
        }
    }
    
    func getFriendIdList() {
        
        self.friendId = []
        // 準備將資料轉為JSON
        let dogId = UserDefaults.standard.integer(forKey: "dogId")
        let action = GetMyFriendList(action: GET_FRIEND_INFO, dogId: dogId)

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
   
        }
    }
    
   
    
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
            self.allUserImageDictionary[dogId] = image
            self.tableView.reloadData()
        }
    }
    
    
    //按加入好友後
   @objc
    func addBtnPressed(sender: UIButton){
    
//     NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
    
    addFriend(inviteDogId: sender.tag)
    //Button 不能按 灰色 透明度 改文字
    sender.isUserInteractionEnabled = false
    sender.tintColor = UIColor.gray
    sender.alpha = 0.4
    sender.setTitle("已邀請", for: .normal)
    }
 

    func addFriend (inviteDogId: Int){
      
        let dogId = UserDefaults.standard.integer(forKey: "dogId")
        
        var data = [String:Any]()
        data["action"] = ADD_FRIEND_TO_CHECKLIST
        data["dogId"] = dogId
        data["inviteDogId"] = inviteDogId
        
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

    
    
    
    
 
}
