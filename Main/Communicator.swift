//
//  Communicator.swift
//  UserAccount
//
//  Created by 李一正 on 2018/7/8.
//  Copyright © 2018年 lee. All rights reserved.
//

import Foundation

class Communicator {
    
    typealias DataHandler = (Data?) -> Void
    var outputString : String?
    var output : Data? = nil
    
    
    
    func doPost( url : String ,data : Data, dataHandler : @escaping DataHandler){
        // 準備URL
        guard let url = URL(string: url) else {
            assertionFailure("url nil")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // POST 出去 及 取得回傳資料
        let task = URLSession.shared.uploadTask(with: request, from: data) { (output, response, error) in
            
            if let error = error {
                assertionFailure("error :\(error)")
                return
            }
            // 確認server回應狀況
            guard let response = response as? HTTPURLResponse,(200...299).contains(response.statusCode) else {
                assertionFailure("server error")
                return
            }
            // 準備要回傳的資料
            DispatchQueue.main.async {
                dataHandler(output)
            }
        }
        task.resume()
    }
    
    // 傳字典進入的
    func doPost( url : String ,data :  [String : Any], dataHandler : @escaping DataHandler){
        
        // 準備URL
        guard let url = URL(string: url) else {
            assertionFailure("url nil")
            return
        }
        
        guard let requestJson = try? JSONSerialization.data(withJSONObject: data) else{
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // POST 出去 及 取得回傳資料
        let task = URLSession.shared.uploadTask(with: request, from: requestJson) { (output, response, error) in
            
            if let error = error {
                assertionFailure("error :\(error)")
                return
            }
            // 確認server回應狀況
            guard let response = response as? HTTPURLResponse,(200...299).contains(response.statusCode) else {
                assertionFailure("server error")
                return
            }
            // 準備要回傳的資料
            DispatchQueue.main.async {
                dataHandler(output)
            }
        }
        task.resume()
    }

    
    // 可用帶入的 status,kind 制成 字典後送出
    func doPost(url : String,
                  data : Data,
                  status : String,
                  kind : String,
                  dataHandler : @escaping DataHandler){
        
        // 將要送出的 data 轉為 jsonString
        let jsonString = String(data: data, encoding: .utf8)
        
        //制成字典
        var jsonData = [String:Any]()
        jsonData["status"] = status
        jsonData[kind] = jsonString
        
        // 準備URL
        guard let url = URL(string: url) else {
            assertionFailure("url nil")
            return
        }
        //        print("\(jsonData)")
        
        guard let requestJson = try? JSONSerialization.data(withJSONObject: jsonData) else{
            print("cast json fail : \(jsonData)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // POST 出去 及 取得回傳資料
        let task = URLSession.shared.uploadTask(with: request, from: requestJson) { (output, response, error) in
            
            if let error = error {
                assertionFailure("error :\(error)")
                return
            }
            // 確認server回應狀況
            guard let response = response as? HTTPURLResponse,(200...299).contains(response.statusCode) else {
                assertionFailure("server error")
                return
            }
            // 準備要回傳的資料
            DispatchQueue.main.async {
                dataHandler(output)
            }
        }
        task.resume()
        
    }
    
}

