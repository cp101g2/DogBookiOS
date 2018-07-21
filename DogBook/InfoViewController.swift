//
//  InfoViewController.swift
//  DogBook
//
//  Created by 李一正 on 2018/7/21.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLable: UILabel!
    @IBOutlet var infoView: UIView!
    
    let communicator = Communicator()
    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissInfo))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoView.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getMyDog()
        getDogImage()
        getBackgroundImage()
    }
    
    @IBAction func signOutBtnPressed(_ sender: Any) {
        
        UserDefaults.standard.set(false, forKey: "isLogin")
        UserDefaults.standard.set(-1, forKey: "dogId")
        UserDefaults.standard.set(-1, forKey: "ownerId")
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
    }
    
    @objc
    func dismissInfo(){
        print("hello")
//        self.dismiss(animated: true)
    }
    
    func getMyDog(){
        
        let dogId = UserDefaults.standard.integer(forKey: "dogId")
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
            print("\(name)")
            
            self.nameLabel.text = name
        }
        
    }
    
    func getDogImage(){
        var data = [String:Any]()
        data["status"] = GET_PROFILE_PHOTO
        data["dogId"] = UserDefaults.standard.integer(forKey: "dogId")
        data["imageSize"] = 150
        
        // 送資料 and 解析回傳的JSON資料
        communicator.doPost(url: MediaServlet, data: data) { (result) in
            guard let result = result else {
                assertionFailure("get data fail")
                return
            }
            
            guard let image = UIImage.init(data: result) else {
                return
            }
            
            self.profileImageView.image = image
        }
    }
    
    func getBackgroundImage(){
        var data = [String:Any]()
        data["status"] = GET_PROFILE_BACKGROUND_PHOTO
        data["dogId"] = UserDefaults.standard.integer(forKey: "dogId")
        data["imageSize"] = Int(UIScreen.main.nativeBounds.width)
        
        communicator.doPost(url: MediaServlet, data: data) { (result) in
            guard let result = result else {
                assertionFailure("get data fail")
                return
            }
            
            guard let image = UIImage.init(data: result) else {
                return
            }
            
            self.backgroundImageView.image = image
        }
        
    }

}
