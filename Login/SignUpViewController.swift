//
//  SignUpViewController.swift
//  DogBook
//
//  Created by 李一正 on 2018/7/22.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailInputText: UITextField!
    @IBOutlet weak var passwordInputText: UITextField!
    @IBOutlet weak var nameInputText: UITextField!
    @IBOutlet weak var genderInputText: UITextField!
    @IBOutlet weak var birthdayInputText: UITextField!
    @IBOutlet weak var varietyInputText: UITextField!
    
    
    let communicator = Communicator()
    
    private let picker = UIImagePickerController()
    private let cropper = UIImageCropper(cropRatio: 1/1)
    
    let gender = ["隱藏","公","母"]
    let variety = ["黃金獵犬","柯基"]
    
    var whichInput : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        profileImageView.isUserInteractionEnabled = true
        let setProfileImage = UITapGestureRecognizer(target: self, action: #selector(setImage))
        profileImageView.addGestureRecognizer(setProfileImage)
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func sendBtnPressed(_ sender: UIButton) {
       
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
    
    func showGenderPicker(){
        var pickerView = UIPickerView()
        pickerView.delegate = self
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
        var pickerView = UIPickerView()
        pickerView.delegate = self
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
    
    
    
    
    func signUp(){
        
        guard let email = emailInputText.text else {
            return
        }
        guard let password = passwordInputText.text else {
            return
        }
        
        let owner = Owner(id: nil, email: email, password: password)
        
        guard let data = try? JSONEncoder().encode(owner) else {
            return
        }
        
        communicator.doPost(url: OwnerServlet, data: data , status: SIGN_UP, kind: "owner") { (result) in
            
            guard let result = result,let data = (try? JSONSerialization.jsonObject(with: result, options: [])) as? [String:Any] else {
                return
            }
            let ownerId = data["ownerId"]
            
            UserDefaults.standard.set(true, forKey: "isLogin")
            UserDefaults.standard.set(ownerId, forKey: "ownerId")
            
        }
        
        
    }
   
}
extension SignUpViewController : UIImageCropperProtocol{
    func didCropImage(originalImage: UIImage?, croppedImage: UIImage?) {
        profileImageView.image = croppedImage
    }
}
extension SignUpViewController : UIPickerViewDelegate,UIPickerViewDataSource {
    
    
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

