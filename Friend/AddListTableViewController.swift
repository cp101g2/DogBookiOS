//
//  AddListTableViewController.swift
//  DogBook
//
//  Created by Apple on 2018/7/27.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class AddListTableViewController: UITableViewController {

    
    let communicator = Communicator()
    
    var addFriendId : [Int] = []
    var addFriendInfoDictionary = [Int:Dog]()
    var addFriendImageDictionary = [Int:UIImage]()
    
  
    override func viewDidLoad() {
        super.viewDidLoad()

//       NotificationCenter.default.addObserver(self, selector: #selector(reloadList), name: NSNotification.Name(rawValue: "load"), object: nil)
//
        
        addFriendId = []
        addFriendInfoDictionary = [:]
        addFriendImageDictionary = [:]
        downloadCheckList()
      
    }
    
//    //加了好友後刷新
//    @objc
//    func reloadList() {
//        
//        
//        addFriendId = []
//        addFriendInfoDictionary = [:]
//        addFriendImageDictionary = [:]
//        downloadCheckList()
//        
//    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

  

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return addFriendInfoDictionary.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddListCell", for: indexPath) as? AddListTableViewCell else {
            return UITableViewCell()
        }
       //         Configure the cell...
        
        let addFriendId = self.addFriendId[indexPath.row]
        let image = self.addFriendImageDictionary[addFriendId]
        
        guard let dog = self.addFriendInfoDictionary[addFriendId] else {
            return UITableViewCell()
        }
        cell.nameLabel.text = dog.name
        cell.ageLabel.text = String(format: "%01d", (dog.age)!) + "歲"
   
        cell.varietyLabel.text = dog.variety
        cell.friendImageView.image = image
        
        if dog.gender == "女" {
            cell.genderImageView.image = UIImage(named: "female")
        } else if dog.gender == "男" {
            cell.genderImageView.image =  UIImage(named: "male")
        }
//
        cell.addConfirmedBtn.tag = dog.dogId!
        cell.addConfirmedBtn.addTarget(self, action: #selector(addFriendConfirmed), for: UIControlEvents.touchUpInside)
        return cell
    }
  

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func downloadCheckList() {
   
        let inviteDogId = UserDefaults.standard.integer(forKey: "dogId")
        let action = AddFriend(action: GET_FRIENDLIST_FROM_CHECKLIST, inviteDogId: inviteDogId)
        
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
            guard let output = try? JSONDecoder().decode([Dog].self, from: result) else {
                assertionFailure("get output fail")
                return
            }
            
            for dog in output {
                self.addFriendId.append(dog.dogId!)
                self.getFriendImage(dogId: dog.dogId!)
                self.addFriendInfoDictionary[dog.dogId!] = dog
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
            self.addFriendImageDictionary[dogId] = image
                self.tableView.reloadData()
        }
    }
    
 
    
    @objc
    func addFriendConfirmed (sender: UIButton) {
    
       
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        
        deleteFriendFromChecklist(dogId: sender.tag)
        addFriendtoRelationship(dogId: sender.tag)
        sender.isUserInteractionEnabled = false
        sender.tintColor = UIColor.gray
        sender.alpha = 0.4
        sender.setTitle("已同意", for: .normal)
        tableView.reloadData()
    }
    
    

    
    
    
    func deleteFriendFromChecklist (dogId: Int) {

        let inviteDogId = UserDefaults.standard.integer(forKey: "dogId")
        let action = DeleteFriend(action: DELETE_FRIEND, dogId: dogId, inviteDogId: inviteDogId)
        
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
            
        }
        self.tableView.reloadData()
    }
    
    
    func addFriendtoRelationship(dogId: Int) {
        
        let inviteDogId = UserDefaults.standard.integer(forKey: "dogId")
        let action = AddFriendToFriendship(action: ADD_FRIEND, myDogId: inviteDogId, friendId: dogId)
        
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
            
        }
        self.tableView.reloadData()
    }
    
    
    
    
    
    
    

}
