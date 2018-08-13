//
//  FriendCollectionViewController.swift
//  DogBook
//
//  Created by Apple on 2018/8/7.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

private let ImageCellIdentifier = "Cell"


class FriendCollectionViewController: UICollectionViewController {

    @IBOutlet weak var friendLayout: UICollectionViewFlowLayout!
    @IBOutlet var FriendCollectionView: UICollectionView!
    
    let communicator = Communicator()
    var media : Media?
//    let LOGIN_PAGE = "Login"
    private let picker = UIImagePickerController()
    private let cropper = UIImageCropper(cropRatio: 16/9)
    
//    var isLogin : Bool = false
    var dogId = friendIdForMainPage
    var dog : Dog?
    var myArticles : [Article] = []
    var articleImage : [Int:UIImage] = [:]
    var dogInfo : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cropper.delegate = self// Important !!!!!
        media = Media(communicator: communicator)
        
        let width = Int((FriendCollectionView.frame.width - 20) / 3)
        friendLayout.minimumLineSpacing = 8
        friendLayout.itemSize = CGSize(width: width , height: width)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        isLogin = UserDefaults.standard.bool(forKey: "isLogin")
        tabBarController?.tabBar.isHidden = true
        dogId = friendIdForMainPage
        if dogId != -1{
            getMyDog()
            getMyArticles()
            print("showLoginPage 已經登入了 \(dogId)")
            collectionView?.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! FriendCollectionReusableView
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(showInfo))
        
//        let setBackground = UITapGestureRecognizer(target: self, action: #selector(choseBackgroundImage))
        
        
//        header.profileImageView.addGestureRecognizer(tap)
        
        
        print(dogId)
        if dogId != -1{
//            header.setBackgroundImage.addGestureRecognizer(setBackground)
            dogId = friendIdForMainPage
            media?.getImage(GET_PROFILE_PHOTO,
                            header.friendProfileImageView,
                            Key.dogId.rawValue,
                            id: dogId, imageSize: 150)
            
            media?.getImage(GET_PROFILE_BACKGROUND_PHOTO,
                            header.friendBackgroundImageView,
                            Key.dogId.rawValue,
                            id: dogId, imageSize: 150)
            
            header.friendInfoLabel.text = dogInfo
        }
        return header
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return myArticles.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCellIdentifier, for: indexPath) as! FriendCollectionViewCell
        
        guard let articleId = myArticles[indexPath.row].articleId else {
            return cell
        }
        guard let image = articleImage[articleId] else {
            return cell
        }
        
        cell.photoImageView.image = image
        cell.photoImageView.layer.borderWidth = 0.5
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

//    @objc
//    func choseBackgroundImage(){
//        cropper.picker = picker
//        cropper.cropButtonText = "Crop"
//        cropper.cancelButtonText = "Retake"
//
//        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        let takePicAction = UIAlertAction(title: "拍照", style: .default) { (_) in
//            self.picker.sourceType = .camera
//            self.present(self.picker, animated: true, completion: nil)
//        }
//        let pickPicAction = UIAlertAction(title: "從相簿選擇照片", style: .default) { (_) in
//            self.picker.sourceType = .photoLibrary
//            self.present(self.picker, animated: true, completion: nil)
//        }
//        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
//        controller.addAction(takePicAction)
//        controller.addAction(pickPicAction)
//        controller.addAction(cancelAction)
//        self.present(controller, animated: true, completion: nil)
//    }
//
    func getMyArticles(){
        let dogId = friendIdForMainPage
    
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
        
        let dogId = friendIdForMainPage
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


 


    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}



extension FriendCollectionViewController : UIImageCropperProtocol{
    func didCropImage(originalImage: UIImage?, croppedImage: UIImage?) {
        
        guard let image = croppedImage, let imageData = UIImagePNGRepresentation(image) else {
            print("image cast to data fail")
            return
        }
        let base64String = imageData.base64EncodedString()
        
        var data = [String:Any]()
        data["status"] = SET_PROFILE_BACKGROUND_PHOTO
        data["dogId"] = friendIdForMainPage
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
