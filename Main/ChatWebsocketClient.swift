//
//  ChatWebsocketClient.swift
//  DogBook
//
//  Created by 李一正 on 2018/8/1.
//  Copyright © 2018年 lee. All rights reserved.
//

import Foundation
import Starscream

class ChatWebsocketClient : WebSocketDelegate {
    var url : URL
    var socket : WebSocketClient
    
    init(url : String) {
        self.url = URL(string: url)!
        self.socket = WebSocket(url: self.url)
    }
    
    func startLinkServer(){
        socket.delegate = self
        socket.connect()
    }
    
    func stopLinkServer() {
        socket.disconnect()
        socket.delegate = nil
    }
    
    func sendMessage(_ message : String) {
        socket.write(string: message)
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("socket is connect")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        socket.disconnect()
        print("socket is disconnect")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Receive Message: \(text)")
        
        // 解析 text (server送出的是jsonString) 成 Json Data
        guard let jsonData = text.data(using: .utf8) else {
            assertionFailure("cast to data fail")
            return
        }
        
        guard let chat = try? JSONDecoder().decode(Chat.self,from : jsonData) else {
            assertionFailure("cast to chat fail")
            return
        }
        
        
        if chat.type != "chat" {
            return
        }
        
        print("message = \(chat.message)")
        
        let message : [String:Chat] = ["message" : chat]
        NotificationCenter.default.post(name: Notification.Name.init("chat"), object: chat)
        NotificationCenter.default.post(name: Notification.Name.init("chat"), object: nil, userInfo: message)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
}
