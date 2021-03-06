//
//  Action.swift
//  DogBook
//
//  Created by 李一正 on 2018/7/17.
//  Copyright © 2018年 lee. All rights reserved.
//

import Foundation

struct LoginDetil : Codable{
    var isLogin : Bool
    var ownerId : Int
    var dogId : Int
}

struct Action : Codable {
    var status : String?
    var owner : Owner
}

struct GetDogInfo : Codable{
    var status : String?
    var dog : Dog
}

struct CommonAction : Codable{
    var status : String?
    var dogId : Int
}

struct DogMediaAction : Codable{
    var status : String?
    var dogId : Int
    var imageSize : Int
}

struct GetMedia : Codable {
    var status : String?
    var mediaId : Int
    var imageSize : Int
}

//////

struct GetMyFriendList : Codable {
    var action: String?
    var dogId: Int
}

struct GetAllDog: Codable {
    var status: String?
    var dog: Dog
    
}

struct AddFriend: Codable {
    var action: String?
    var inviteDogId: Int
    
}


struct DeleteFriend: Codable {
    var action: String?
    var dogId: Int
    var inviteDogId: Int
    
}


struct AddFriendToFriendship:Codable {
    var action: String
    var myDogId: Int
    var friendId: Int
    
}
