//
//  Media.swift
//  DogBook
//
//  Created by 李一正 on 2018/7/23.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class Media {
    
    var communicator : Communicator
    
    init(communicator : Communicator) {
        self.communicator = communicator
    }
    
    func getImage(_ status:String,
                  _ originImageView : UIImageView ,
                  _ key : String,
                  id : Int ,
                  imageSize : Int){
        
        unowned let imageView = originImageView
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
            
            imageView.image = image
        }
    }
}
