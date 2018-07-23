//
//  LoginViewController.swift
//  DogBook
//
//  Created by 李一正 on 2018/7/17.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailInputText: UITextField!
    @IBOutlet weak var passwordInputText: UITextField!
    
    let communicator = Communicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    @IBAction func LoginBtnPressed(_ sender: UIButton) {
        // 從TaxtField取得資料
        guard let email = emailInputText.text,let password = passwordInputText.text else {
            assertionFailure("inputEmail's is nil")
            return
        }
        
        let owner = Owner(id: 0,email: email,password: password)
        
        // 準備將資料轉為JSON
        guard let uploadData = try? JSONEncoder().encode(owner) else {
            assertionFailure("JSON encode Fail")
            return
        }
        communicator.doPost(url: OwnerServlet, data: uploadData, status: SIGN_IN, kind: "owner") { (result) in
            guard let result = result else {
                assertionFailure("get data fail")
                return
            }
            
            guard let output = try? JSONDecoder().decode(LoginDetil.self, from: result) else {
                assertionFailure("get output fail")
                return
            }
            // 將資料存入UserDefaults
            UserDefaults.standard.set(output.isLogin, forKey: "isLogin")
            UserDefaults.standard.set(output.ownerId, forKey: "ownerId")
            UserDefaults.standard.set(output.dogId, forKey: "dogId")
            
            
            if UserDefaults.standard.bool(forKey: "isLogin") {
                self.dismiss(animated: true, completion: nil)
            } else {
                print("登入失敗 \(UserDefaults.standard.bool(forKey: "isLogin"))" )
            }
        }
        
    }


}
