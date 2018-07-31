//
//  AddArticleViewController.swift
//  DogBook
//
//  Created by 李一正 on 2018/7/28.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class AddArticleViewController: UIViewController {
    
    @IBOutlet weak var articleContentLabel: UITextView!
    @IBOutlet weak var articleImageView: UIImageView!
    
    private let picker = UIImagePickerController()
    private let cropper = UIImageCropper(cropRatio: 1/1)
    let communicator = Communicator()
    var articleImage : UIImage!
    var dogId : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cropper.delegate = self
        dogId = UserDefaults.standard.integer(forKey: "dogId")
    }
    
    @IBAction func chooseImageButton(_ sender: UIButton) {
        print("hello")
        setImage()
    }
    @IBAction func createArticle(_ sender: UIBarButtonItem) {
        
        
        if articleImage == nil && articleContentLabel.text == "" {
            return
        }
        
        let content = articleContentLabel.text
        let location = "here"
        let status = 1
        let article = Article(dogId: dogId, status: status, articleId: nil, content: content, location: location, mediaId: nil)

        guard let articleData = try? JSONEncoder().encode(article) else {
            return
        }

        let jsonString = String(data: articleData, encoding: .utf8)
        let imageBase64 = imageToBase64()

        var data = [String:Any]()
        data["status"] = CREATE_ARTICLE
        data["article"] = jsonString
        data["media"] = imageBase64
        data["type"] = 1

        communicator.doPost(url: ArticleServlet, data: data) { (result) in

            guard let result = result else {
                return
            }

            guard let output = try? JSONSerialization.jsonObject(with: result, options: []) as! [String:Any] else {
                return
            }
            print(output["Success"])

            self.navigationController?.popToRootViewController(animated: true)
        }
        
        
    }
    
    
    
    func setImage(){
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
    
    func imageToBase64() -> String?{
        guard let image = articleImage, let imageData = UIImagePNGRepresentation(image) else {
            print("image cast to data fail")
            return nil
        }
        let base64String = imageData.base64EncodedString()
        return base64String
    }
    
}

extension AddArticleViewController : UIImageCropperProtocol{
    
    func didCropImage(originalImage: UIImage?, croppedImage: UIImage?) {
//        postImage = croppedImage
        let imageWidth = originalImage?.size.width
        let r = self.view.frame.size.width / imageWidth!
        let width = self.view.frame.size.width
        let height = (originalImage?.size.height)! * r
        let imageFrame = CGRect(x: 0, y: 252, width: width, height: height)
        let image = originalImage?.resize(willSetWidth: width)
        articleImageView.frame = imageFrame
        articleImage = image
        articleImageView.image = image
        
    }
}
