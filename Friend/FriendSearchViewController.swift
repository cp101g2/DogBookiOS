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
    
    var AllDogId : [Int] = []
    
    var AllDog:Dog?
    
    var AllDogInfoDictionary = [Int:Dog]()
    
    var currentAllDogInfoDictionary = [Int:Dog]()
    
    
    //////////////////////////////////////////
    var friendImageDictionary = [Int:UIImage]()
    
    var currentFriendImageDictionary = [Int:DogMediaAction]()
    
    var friendImage:DogMediaAction?
    
    ///////////////////////////////////////
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        nameSearchBar.delegate = self
        
        alterLayout() //固定search bar
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        downloadFriendList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        print(" 朋友數量\(friendInfoDictionary.count)")
        //        print(" 朋友清單\(friendInfoDictionary)")
        
        return currentAllDogInfoDictionary.count
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendSearchCell", for: indexPath) as? FriendSearchTableViewCell else {
            return UITableViewCell()
        }
        
        let friendId = self.AllDogId[indexPath.row]
        
        //        print("\(self.currentFriendInfoDictionary)")
        let friend = self.currentAllDogInfoDictionary[friendId]
        let image = self.friendImageDictionary[friendId]
        //        let friendImage = self.currentFriendImageDictionary[friendId]
        
        //        print("\(indexPath.row),\(friendId)")
        
        cell.nameLabel.text = friend?.name
        //        cell.ageLabel.text = String(format: "%01d", (friend?.age)!) + "歲"
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
            currentAllDogInfoDictionary = [:]
            //            currentFriendImageDictionary = [:]
            downloadFriendList()
            return
        }
        
        
        currentAllDogInfoDictionary = AllDogInfoDictionary.filter({ friend -> Bool in
            (friend.value.name?.lowercased().contains(searchText.lowercased()))!
            
        })
        
        //        for key in currentFriendInfoDictionary {
        ////
        //            currentFriendId.append(key.key)
        //        }
        self.AllDogInfoDictionary = currentAllDogInfoDictionary
        //        self.friendImageDictionary = currentFriendImageDictionary
        
        self.AllDogId = []
        for friend in self.AllDogInfoDictionary {
            self.AllDogId.append(friend.key)
        }
        
        //        for friend in self.friendImageDictionary {
        //            self.friendId.append(friend.key)
        //        }
        print("搜尋結果\(currentAllDogInfoDictionary)")
        tableView.reloadData()
        
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
            print(output)
            output.dogId = dogId
            self.AllDogId.append(dogId)
            
            self.AllDogInfoDictionary[dogId] = output
            self.currentAllDogInfoDictionary[dogId] = output
            
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
    
    
    func downloadFriendList(){
        self.AllDogId = []
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
            print("\(output.count)")
            for friendId in output {
                
                self.getFriendInfo(dogId: friendId.dogId!)
                self.getFriendImage(dogId: friendId.dogId!)
                
            }
            
            //            DispatchQueue.main.async {
            //
            //                )
            //            }
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
