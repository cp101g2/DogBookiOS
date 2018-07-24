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
    @IBOutlet weak var closeImageView: UIImageView!
    @IBOutlet weak var infoView: UIView!
    
    let communicator = Communicator()
    var media : Media?
    var dogId : Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissInfo))
        closeImageView.addGestureRecognizer(tap)
        infoView.addGestureRecognizer(tap)
        
        media = Media(communicator: communicator)
        dogId = UserDefaults.standard.integer(forKey: Key.dogId.rawValue )
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getMyDog()
        media?.getImage(GET_PROFILE_PHOTO,
                        profileImageView,
                        Key.dogId.rawValue, id: dogId,
                        imageSize: 150)
        
        media?.getImage(GET_PROFILE_BACKGROUND_PHOTO,
                        backgroundImageView,
                        Key.dogId.rawValue,
                        id: dogId, imageSize: 150)
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
        dismiss(animated: true)
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
}
