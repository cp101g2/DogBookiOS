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

    @IBOutlet weak var myDogLayout: UICollectionViewFlowLayout!
    @IBOutlet var myDogCollectionView: UICollectionView!
    
    let communicator = Communicator()
    var media : Media?
    let LOGIN_PAGE = "Login"
    private let picker = UIImagePickerController()
    private let cropper = UIImageCropper(cropRatio: 16/9)

    var isLogin : Bool = false
    var dogId = -1
    var dog : Dog?
    var myArticles : [Article] = []
    var articleImage : [Int:UIImage] = [:]
    var dogInfo : String?
    var profileImage : UIImage?
    var backgroundImage : UIImage?
    var meter : Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cropper.delegate = self// Important !!!!!
        media = Media(communicator: communicator)
        
        let width = Int((myDogCollectionView.frame.width - 20) / 3)
        myDogLayout.minimumLineSpacing = 8
        myDogLayout.itemSize = CGSize(width: width , height: width)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        isLogin = UserDefaults.standard.bool(forKey: "isLogin")
        dogId = UserDefaults.standard.integer(forKey: "dogId")
        if !isLogin{
            //跳至登入頁面
            let storyboard = UIStoryboard(name: "LoginStoryboard", bundle: nil)
            
            if let controller = storyboard.instantiateViewController(withIdentifier: LOGIN_PAGE) as? LoginViewController {
                present(controller, animated: true)
            }
        } else if isLogin , dogId != -1{
            getMyDog()
            getMyArticles()
            getMeter()
            print("showLoginPage 已經登入了 \(dogId)")
            collectionView?.reloadData()
        }
    }
    
    @IBAction func unwindSegue(_ sender: UIStoryboardSegue){}
    
    @IBAction func showMyEventButton(_ sender: UIBarButtonItem) {
        let nextVC = UIStoryboard(name: "MyDogStoryboard", bundle: nil).instantiateViewController(withIdentifier: "Calendar") as! EventViewController
        nextVC.myDogId = dogId
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! MyDogInfoCollectionReusableView
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showInfo))
        
        let setBackground = UITapGestureRecognizer(target: self, action: #selector(choseBackgroundImage))
        
        
        header.profileImageView.addGestureRecognizer(tap)
        
        
        print(dogId)
        
        if isLogin ,dogId != -1{
            header.setBackgroundImage.addGestureRecognizer(setBackground)
            dogId = UserDefaults.standard.integer(forKey: "dogId")
            
            getImage(status: GET_PROFILE_PHOTO,
                     key: "dogId", id: dogId,
                     imageSize: 150,
                     outsideImageView: header.profileImageView)
            
            getImage(status: GET_PROFILE_BACKGROUND_PHOTO,
                     key: "dogId", id: dogId, imageSize: 150,
                     outsideImageView: header.backgroundImageView)
            
            header.infoLabel.text = dogInfo
            guard let meter = meter else {
                return header
            }
            
            header.meterLabel.text = "\(String(format: "%.1f", meter)) 公尺"
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let nextVC = UIStoryboard(name: "MyDogStoryboard", bundle: nil).instantiateViewController(withIdentifier: "myArticle") as! MyArticleViewController
        let article = myArticles[indexPath.row]
        
        nextVC.myDog = dog!
        nextVC.myProfileImage = profileImage
        nextVC.article = article
        nextVC.articlImage = articleImage[article.articleId!]
        
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc
    func showInfo(){
        let dogId = UserDefaults.standard.integer(forKey: "dogId")
        if isLogin , dogId != -1{
            let storyboard = UIStoryboard(name: "MyDogStoryboard", bundle: nil)
            
            if let controller = storyboard.instantiateViewController(withIdentifier: "Info") as? InfoViewController {
                
                controller.dog = dog
                controller.profileImage = profileImage
                controller.backgroundImage = backgroundImage
                controller.lastNavigation = navigationController
                controller.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
                controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                controller.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                
                
                present(controller, animated: true)
            }
            
        } else {
            let storyboard = UIStoryboard(name: "MyDogStoryboard", bundle: nil)
            
            if let controller = storyboard.instantiateViewController(withIdentifier: "AddDog") as? AddDogViewController {
                present(controller, animated: true)
            }
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
            self.dog = output
            guard let name = output.name else {
                return
            }
            print("\(name)")

            self.dogInfo = name
        }
        
    }
    
    func getImage(status:String,
                  key:String,
                  id:Int,
                  imageSize:Int,
                  outsideImageView:UIImageView){
        
        unowned var insideImageView = outsideImageView
        var data = [String:Any]()
        data["status"] = status
        data[key] = id
        data["imageSize"] = imageSize
        
        // 送資料 and 解析回傳的JSON資料
        communicator.doPost(url: MediaServlet, data: data) { (result) in
            guard let result = result else {
                assertionFailure("get data fail")
                return
            }
            
            guard let image = UIImage.init(data: result) else {
                return
            }
            if status == GET_PROFILE_PHOTO {
                self.profileImage = image
            } else {
                self.backgroundImage = image
            }
            insideImageView.image = image
        }
    }
    
    func getMyArticleImage(articleId: Int ,mediaId:Int){
        
        var data = [String:Any]()
        data["status"] = GET_ARTICLES
        data["mediaId"] = mediaId
        data["imageSize"] = Int(UIScreen.main.nativeBounds.width)/3
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
    
    func getMeter(){
        var data = [String:Any]()
        data["status"] = GET_METER
        data["dogId"] = dogId
        
        communicator.doPost(url: DogServlet, data: data) { (result) in
            guard let result = result else {
                return
            }
            print(result)
            
            guard let output = try? JSONSerialization.jsonObject(with: result, options: []) as? [String:Double] else {
                print("cast fail")
                return
            }
            guard let meter = output!["meter"] else {
                return
            }
            self.meter = meter
            
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
        
        var data = [String:Any]()
        data["status"] = SET_PROFILE_BACKGROUND_PHOTO
        data["dogId"] = UserDefaults.standard.integer(forKey: "dogId")
        data["media"] = base64String
        data["type"] = 1
        communicator.doPost(url: MediaServlet, data: data) { (result) in
            guard let result = result else {
                return
            }
            
            print("status: \(result)")
        }
        
    }
}
