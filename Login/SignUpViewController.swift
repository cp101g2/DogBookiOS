//
//  SignUpViewController.swift
//  DogBook
//
//  Created by 李一正 on 2018/7/22.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailInputText: UITextField!
    @IBOutlet weak var passwordInputText: UITextField!

    let communicator = Communicator()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func sendBtnPressed(_ sender: UIButton) {
       signUp()
    }
    
    
    
    func signUp(){
        
        guard let email = emailInputText.text,email != "" else {
            return
        }
        guard let password = passwordInputText.text,password != "" else {
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


