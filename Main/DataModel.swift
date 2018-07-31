//
//  DataModel.swift
//  DogBook
//
//  Created by 李一正 on 2018/7/17.
//  Copyright © 2018年 lee. All rights reserved.
//

import Foundation

enum Key : String{
    case dogId = "dogId"
}

struct Owner : Codable{
    var id : Int?
    var email : String
    var password : String
}

struct Dog : Codable{
    
    var ownerId : Int?
    var dogId : Int?
    var name : String?
    var gender : String?
    var variety : String?
    var birthday : String?
    var age : Int?
    
}

struct Article : Codable {
    
    var dogId : Int?
    var status : Int?
    var articleId : Int?
    var content : String?
    var location : String?
    var mediaId : Int?
    
}

struct Chat : Codable{
    var chatId : Int?
    var senderId : Int?
    var receiverId : Int?
    var chatroomId : Int?
    var message : String?
    var type : String?
}




