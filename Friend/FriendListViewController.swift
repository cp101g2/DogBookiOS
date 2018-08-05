//
//  FriendListViewController.swift
//  DogBook
//
//  Created by Apple on 2018/7/24.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class FriendListViewController: UIViewController,  UITableViewDelegate, UISearchBarDelegate, UITableViewDataSource {
    
    let communicator = Communicator()
    
    var friendId : [Int] = []
    
    
    
    var friendInfoDictionary = [Int:Dog]()
    var currentFriendInfoDictionary = [Int:Dog]()
    var friendImageDictionary = [Int:UIImage]()
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameSearchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        tableView.reloadData()
        tableView.delegate = self
        tableView.dataSource = self
        nameSearchBar.delegate = self
        getFriendIdList()
        //固定search bar
        alterLayout()
        
        // Do any additional setup after loading the view.
    }
    
    //加了好友後刷新
    @objc
    func reloadList() {
        
        print("接收成功")
        currentFriendInfoDictionary = [:]
        getFriendIdList()
        self.tableView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return currentFriendInfoDictionary.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendListCell", for: indexPath) as? FriendListTableViewCell else {
            return UITableViewCell()
        }
        
        let friendId = self.friendId[indexPath.row]
        let image = self.friendImageDictionary[friendId]
        
        guard let friend = self.currentFriendInfoDictionary[friendId] else {
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
        
        
        cell.friendImageView.layer.cornerRadius = cell.friendImageView.bounds.width/2
        cell.friendImageBorderView.layer.borderWidth = 2
        cell.friendImageBorderView.layer.cornerRadius = cell.friendImageBorderView.bounds.width/2
        
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
            currentFriendInfoDictionary = [:]
            getFriendIdList()
            return
        }
        
        currentFriendInfoDictionary = friendInfoDictionary.filter({ friend -> Bool in
            (friend.value.name?.lowercased().contains(searchText.lowercased()))!
        })
        
        self.friendInfoDictionary = currentFriendInfoDictionary
        self.friendId = []
        
        for friend in self.friendInfoDictionary {
            self.friendId.append(friend.key)
        }
        print("搜尋結果\(currentFriendInfoDictionary)")
        tableView.reloadData()
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func getFriendIdList() {
        self.friendId = []
        // 準備將資料轉為JSON
        let dogId = UserDefaults.standard.integer(forKey: "dogId")
        let action = GetMyFriendList(action: GET_FRIEND_INFO, dogId: dogId)
        
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
                
                self.getFriendInfo(dogId: friendId.dogId)
                self.getFriendImage(dogId: friendId.dogId)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                
            }
        }
    }
    
    func getFriendInfo (dogId:Int){
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
            
            output.dogId = dogId
            self.friendId.append(dogId)
            
            self.friendInfoDictionary[dogId] = output
            self.currentFriendInfoDictionary[dogId] = output
            
            self.friendInfoDictionary.removeValue(forKey: UserDefaults.standard.integer(forKey: "dogId"))
            self.currentFriendInfoDictionary.removeValue(forKey: UserDefaults.standard.integer(forKey: "dogId"))
            if let index = self.friendId.index(of: UserDefaults.standard.integer(forKey: "dogId")) {
                self.friendId.remove(at: index)
            }
            
          
            
            self.tableView.reloadData()
        }
        
     
        
        
    }
    
    
    
    func getFriendImage(dogId: Int){
        
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
            self.friendImageDictionary[dogId] = image
            self.tableView.reloadData()
            
        }
    }
    
    
}
