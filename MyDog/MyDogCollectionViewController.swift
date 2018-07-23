//
//  MyDogCollectionViewController.swift
//  DogBook
//
//  Created by 李一正 on 2018/7/17.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

private let ImageCellIdentifier = "Cell"

class MyDogCollectionViewController: UICollectionViewController {

    let communicator = Communicator()
    let LOGIN_PAGE = "Login"
    private let picker = UIImagePickerController()
    private let cropper = UIImageCropper(cropRatio: 16/9)

    var isLogin : Bool = false
    var dogId = -1
    var dog : Dog?
    var myArticles : [Article] = []
    var profileImage : UIImage?
    var backgroundImage : UIImage?
    var articleImage : [Int:UIImage] = [:]
    var dogInfo : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cropper.delegate = self// Important !!!!!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        isLogin = UserDefaults.standard.bool(forKey: "isLogin")
        dogId = UserDefaults.standard.integer(forKey: "dogId")
        if !isLogin{
            //跳至登入頁面
            let storyboard = UIStoryboard(name: "MyDogStoryboard", bundle: nil)
            
            if let controller = storyboard.instantiateViewController(withIdentifier: LOGIN_PAGE) as? LoginViewController {
                present(controller, animated: true)
            }
        } else if isLogin , dogId != -1{
            let id = UserDefaults.standard.integer(forKey: "dogId")
            getMyDog()
            getDogImage()
            getBackgroundImage()
            getMyArticles()
            print("showLoginPage 已經登入了 \(id)")
        }
    }

    @IBAction func unwindSegue(_ sender: UIStoryboardSegue){}
    
    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! MyDogInfoCollectionReusableView
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showInfo))
        
        let setBackground = UITapGestureRecognizer(target: self, action: #selector(choseBackgroundImage))
        
        
        header.profileImageView.addGestureRecognizer(tap)
        
        if isLogin ,dogId != -1{
            header.setBackgroundImage.addGestureRecognizer(setBackground)
            header.profileImageView.image = profileImage
            header.backgroundImageView.image = backgroundImage
            header.infoLabel.text = dogInfo
        }
        
        return header
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return myArticles.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCellIdentifier, for: indexPath) as! MyDogImageCollectionViewCell
        
        guard let articleId = myArticles[indexPath.row].articleId else {
            return cell
        }
        guard let image = articleImage[articleId] else {
            return cell
        }
        
        cell.articleImageView.image = image
        
        return cell
    }
    
    @objc
    func showInfo(){
        let dogId = UserDefaults.standard.integer(forKey: "dogId")
        if isLogin , dogId != -1{
            let storyboard = UIStoryboard(name: "MyDogStoryboard", bundle: nil)
            
            if let controller = storyboard.instantiateViewController(withIdentifier: "Info") as? InfoViewController {
                
                controller.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
                controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                controller.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                
                
                present(controller, animated: true)
            }
            
        } else {
            print("will add dog")
        }
        
    }
    
    @objc
    func choseBackgroundImage(){
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
    
    func getMyArticles(){
        let dogId = UserDefaults.standard.integer(forKey: "dogId")
        
        var data = [String:Any]()
        data["status"] = GET_MY_ARTICLES
        data["dogId"] = dogId
        // 送資料 and 解析回傳的JSON資料
        communicator.doPost(url: ArticleServlet, data: data) { (result) in
            guard let result = result else {
                assertionFailure("get data fail")
                return
            }
            
            guard let output = try? JSONDecoder().decode([Article].self, from: result) else {
                assertionFailure("get output fail")
                return
            }
            print(output.count)
            self.myArticles = output
            
            for article in output {
                self.getMyArticleImage(articleId: article.articleId! ,mediaId: article.mediaId!)
            }
        }
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

            self.dogInfo = name
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
            
            self.profileImage = image
            self.collectionView?.reloadData()
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
            
            self.backgroundImage = image
            self.collectionView?.reloadData()
        }
        
    }
    
    func getMyArticleImage(articleId: Int ,mediaId:Int){
        
        var data = [String:Any]()
        data["status"] = GET_ARTICLES
        data["mediaId"] = mediaId
        data["imageSize"] = Int(UIScreen.main.nativeBounds.width)
        // 送資料 and 解析回傳的JSON資料
        communicator.doPost(url: MediaServlet, data: data) { (result) in
            guard let result = result else {
                assertionFailure("get data fail")
                return
            }
            
            guard let image = UIImage.init(data: result) else {
                return
            }
            
            self.articleImage[articleId] = image
            self.collectionView?.reloadData()
        }

    }
    
}
extension MyDogCollectionViewController : UIImageCropperProtocol{
    func didCropImage(originalImage: UIImage?, croppedImage: UIImage?) {
        
        guard let image = croppedImage, let imageData = UIImagePNGRepresentation(image) else {
            print("image cast to data fail")
            return
        }
        let base64String = imageData.base64EncodedString()
        
//        print(base64String)
        var data = [String:Any]()
        data["status"] = SET_PROFILE_BACKGROUND_PHOTO
        data["dogId"] = UserDefaults.standard.integer(forKey: "dogId")
        data["media"] = base64String
        data["type"] = 1
//        imageView.image = croppedImage
        communicator.doPost(url: MediaServlet, data: data) { (result) in
            guard let result = result else {
                return
            }
            
            print("status: \(result)")
        }
        
    }
}
