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
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var signOutIconImageView: UIImageView!
    @IBOutlet weak var changeProfileIconImageView: UIImageView!
    @IBOutlet weak var walkOutIconImageView: UIImageView!
    
    private let picker = UIImagePickerController()
    private let cropper = UIImageCropper(cropRatio: 1/1)
    
    let communicator = Communicator()
    var lastNavigation : UINavigationController!
    var media : Media?
    var dog : Dog?
    var profileImage : UIImage!
    var backgroundImage : UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cropper.delegate = self
        let walkOutTap = UITapGestureRecognizer(target: self, action: #selector(walkOut))
        let changProfileImageTap = UITapGestureRecognizer(target: self, action: #selector(changeProfileImage))
        let signOutTap = UITapGestureRecognizer(target: self, action: #selector(signOut))
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissInfo))
        
        walkOutIconImageView.addGestureRecognizer(walkOutTap)
        changeProfileIconImageView.addGestureRecognizer(changProfileImageTap)
        signOutIconImageView.addGestureRecognizer(signOutTap)
        infoView.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        profileImageView.image = profileImage
        backgroundImageView.image = backgroundImage
        guard let dog = dog else {
            print("dog is nil")
            return
        }
        
        guard let name = dog.name,
            let variety = dog.variety,
            let gender = dog.gender ,
            let age = dog.age ,
            let birthday = dog.birthday else {
                
            return
        }
        nameLabel.text = name
        
        infoLable.text = "品種：\(variety) \n 性別：\(gender) \n 年紀：\(age) \n 生日：\(birthday)"
    }
    
    @IBAction func walkOutBtnPressed(_ sender: Any) {
        walkOut()
    }
    
    @IBAction func changeProImageBtnPressed(_ sender: Any) {
        changeProfileImage()
    }
    
    @IBAction func signOutBtnPressed(_ sender: Any) {
        signOut()
    }
    
    @objc
    func walkOut(){
        let nextVC = UIStoryboard(name: "MyDogStoryboard", bundle: nil).instantiateViewController(withIdentifier: "Walk") as! WalkViewController
        nextVC.myDogId = UserDefaults.standard.integer(forKey: "dogId")
        lastNavigation.pushViewController(nextVC, animated: true)
        dismiss(animated: false)
    }
    
    @objc
    func changeProfileImage(){
        cropper.picker = picker
        cropper.cropButtonText = "Crop"
        cropper.cancelButtonText = "Retake"
        
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePicAction = UIAlertAction(title: "拍照", style: .default) { (_) in
            self.picker.sourceType = .camera
            self.present(self.picker, animated: true, completion: nil)
        }
        let pickPicAction = UIAlertAction(title: "從相簿選擇照片", style: .default) { (_) in
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(takePicAction)
        controller.addAction(pickPicAction)
        controller.addAction(cancelAction)
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc
    func signOut(){
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
}

extension InfoViewController : UIImageCropperProtocol{
    func didCropImage(originalImage: UIImage?, croppedImage: UIImage?) {
        
        profileImageView.image = croppedImage
        guard let image = croppedImage, let imageData = UIImagePNGRepresentation(image) else {
            print("image cast to data fail")
            return
        }
        let base64String = imageData.base64EncodedString()
        
        var data = [String:Any]()
        data["status"] = SET_PROFILE_PHOTO
        data["dogId"] = UserDefaults.standard.integer(forKey: "dogId")
        data["media"] = base64String
        data["type"] = 1
        communicator.doPost(url: MediaServlet, data: data) { (result) in
            guard let result = result else {
                return
            }
            
            print("status: \(result)")
            self.dismiss(animated: true)
        }
    }
}
