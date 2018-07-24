//
//  AddDogViewController.swift
//  DogBook
//
//  Created by 李一正 on 2018/7/23.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class AddDogViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameInputText: UITextField!
    @IBOutlet weak var genderInputText: UITextField!
    @IBOutlet weak var birthdayInputText: UITextField!
    @IBOutlet weak var varietyInputText: UITextField!
    @IBOutlet weak var ageInputText: UITextField!
    
    private let picker = UIImagePickerController()
    private let cropper = UIImageCropper(cropRatio: 1/1)
    let gender = ["隱藏","公","母"]
    let variety = ["黃金獵犬","柯基"]
    let communicator = Communicator()
    
    var whichInput : String?
    var pickerView = UIPickerView()
    var postImage : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cropper.delegate = self
        pickerView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        profileImageView.isUserInteractionEnabled = true
        let setProfileImage = UITapGestureRecognizer(target: self, action: #selector(setImage))
        profileImageView.addGestureRecognizer(setProfileImage)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func genderInput(_ sender: UITextField) {
        whichInput = "gender"
        showGenderPicker()
    }
    
    @IBAction func birthdayInput(_ sender: UITextField) {
        showDatePicker()
    }
    
    @IBAction func varietyInput(_ sender: UITextField) {
        whichInput = "variety"
        showVarietyPicker()
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func sendBtnPressed(_ sender: Any) {
        sendData()
        dismiss(animated: true)
    }
    
    
    func showGenderPicker(){
//        pickerView = UIPickerView()
        genderInputText.inputView = pickerView
    }
    
    func showDatePicker(){
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.date = NSDate() as Date
        datePicker.addTarget(self, action: #selector(show(datePicker:)), for: .valueChanged)
        birthdayInputText.inputView = datePicker
    }
    
    func showVarietyPicker(){
//        pickerView = UIPickerView()
        varietyInputText.inputView = pickerView
    }
    
    @objc
    func show(datePicker:UIDatePicker){
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd"
        birthdayInputText.text = dateFormater.string(from: datePicker.date)
    }
    
    @objc
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
    
    func sendData() {
        let ownerId = UserDefaults.standard.integer(forKey: "ownerId")
        
        guard let name = nameInputText.text,
            let gender = genderInputText.text,
            let birthday = birthdayInputText.text,
            let variety = varietyInputText.text,
            let ageText = ageInputText.text,let age = Int(ageText) else {
            return
        }
        
        let dog = Dog(ownerId: ownerId, dogId: nil, name: name, gender: gender, variety: variety, birthday: birthday, age: age)
        
        guard let uploadData = try? JSONEncoder().encode(dog) else {
            return
        }
        
        communicator.doPost(url: DogServlet, data: uploadData, status: ADD_DOG, kind: "dog") { (result) in
            
            guard let result = result,let jsonIn = (try? JSONSerialization.jsonObject(with: result, options: [] )) as? [String:Int] else {
                return
            }
            
            guard let dogId = jsonIn["dogId"] else {
                return
            }
            
            UserDefaults.standard.set(dogId, forKey: "dogId")
            self.sendImage(dogId: dogId)
        }
        
    }
    
    func sendImage(dogId:Int){
        guard let image = postImage, let imageData = UIImagePNGRepresentation(image) else {
            print("image cast to data fail")
            return
        }
        let base64String = imageData.base64EncodedString()
        
        var data = [String:Any]()
        data["status"] = SET_PROFILE_PHOTO
        data["dogId"] = dogId
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

extension AddDogViewController : UIImageCropperProtocol,UIPickerViewDelegate,UIPickerViewDataSource {
    
    func didCropImage(originalImage: UIImage?, croppedImage: UIImage?) {
        print("hello")
        postImage = croppedImage
        profileImageView.image = croppedImage
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if whichInput == "gender" {
            return gender.count
        } else {
            return variety.count
        }
        
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if whichInput == "gender" {
            return gender[row]
        } else {
            return variety[row]
        }
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if whichInput == "gender" {
            genderInputText.text = gender[row]
        } else {
            varietyInputText.text = variety[row]
        }
        
    }
}
