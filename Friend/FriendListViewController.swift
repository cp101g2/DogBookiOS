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
    
//    var friend:Dog?
    
    var friendInfoDictionary = [Int:Dog]()
    
    var currentFriendInfoDictionary = [Int:Dog]()
    
    
    //////////////////////////////////////////
    var friendImageDictionary = [Int:UIImage]()
    
    var currentFriendImageDictionary = [Int:DogMediaAction]()
    
    var friendImage:DogMediaAction?
    
    ///////////////////////////////////////
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameSearchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        nameSearchBar.delegate = self
        
        alterLayout() //固定search bar
        getFriendIdList()
        // Do any additional setup after loading the view.
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

        //        print("\(self.currentFriendInfoDictionary)")
        let friend = self.currentFriendInfoDictionary[friendId]
        let image = self.friendImageDictionary[friendId]
        //        let friendImage = self.currentFriendImageDictionary[friendId]

        //        print("\(indexPath.row),\(friendId)")

        cell.nameLabel.text = friend?.name
                cell.ageLabel.text = String(format: "%01d", (friend?.age)!) + "歲"
        cell.genderLabel.text = friend?.gender
        cell.varietyLabel.text = friend?.variety

        cell.friendImageView.image = image

        
        
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
            //            currentFriendImageDictionary = [:]
            getFriendIdList()
            return
        }
        
        
        currentFriendInfoDictionary = friendInfoDictionary.filter({ friend -> Bool in
            (friend.value.name?.lowercased().contains(searchText.lowercased()))!
            
        })
        
        //        for key in currentFriendInfoDictionary {
        ////
        //            currentFriendId.append(key.key)
        //        }
        self.friendInfoDictionary = currentFriendInfoDictionary
        //        self.friendImageDictionary = currentFriendImageDictionary
        
        self.friendId = []
        for friend in self.friendInfoDictionary {
            self.friendId.append(friend.key)
        }
        
        //        for friend in self.friendImageDictionary {
        //            self.friendId.append(friend.key)
        //        }
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
        //(2
//        var data = [String:Any]()
//        data["status"] = GET_FRIEND_INFO
//        data["dogId"] = dogId
//
//        communicator.doPost(url: <#T##String#>, data: data) { (<#Data?#>) in
//            <#code#>
//        }
//
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
                print("\(self.friendId.count)")
            }
            
            
            
        }
    }
    
    
    func getFriendInfo (dogId:Int){
        let dog = Dog(ownerId: nil, dogId: dogId, name: nil, gender: nil, variety: nil, birthday: nil, age: nil)
        let action = GetDogInfo(status: GET_DOG_INFO, dog: dog)
        
        // 轉為JSON
        guard let data = try? JSONEncoder().encode(dog) else {
            assertionFailure("JSON encode Fail")
            return
        }
        
        communicator.doPost(url: <#T##String#>, data: data, status: GET_DOG_INFO, kind: "dog") { (<#Data?#>) in
            <#code#>
        }
        
        
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
            
            self.tableView.reloadData()
            
        }
        
    }
    
    
    func getFriendImage(dogId: Int){
        //        let dogId = self.friendId[indexPath.row]
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
            
            print("圖片\(result)")
        }
    }


}
