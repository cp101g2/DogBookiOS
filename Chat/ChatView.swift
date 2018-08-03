//
//  ChatView.swift
//  DogBook
//
//  Created by 李一正 on 2018/8/2.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class ChatView: UIView {
    
    // Varibles and subviews
    var textLabel: UILabel?
    var backgroundView : UIView?
    var currenY : CGFloat = 0.0
    var myDogId = -1
    // Constants from chat view
    let chat : Chat
    let fullWidth : CGFloat
    let offsetY : CGFloat
    // Constants for display
    let sidePaddingRate : CGFloat = 0.02
    let maxBubbleWidthRate : CGFloat = 0.7
    let contentMargin : CGFloat = 10.0
    let bubbleTailWidth : CGFloat = 10.0
    let textFontSize : CGFloat = 16.0
    
    init(chat:Chat,maxWidth:CGFloat,offsetY:CGFloat ) {
        myDogId = UserDefaults.standard.integer(forKey: "dogId")
        self.chat = chat
        self.fullWidth = maxWidth
        self.offsetY = offsetY
        super.init(frame:CGRect.zero)
        
        // 2 decide a basic frame
        self.frame = caculateBasicFrame()
        // 3 decide text labe's frame
        prepareTextLabel()
        // 4 decide final size of frame
        decideFinalSize()
        // 5 display bubble view background
        prepareBackgroundView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func caculateBasicFrame() -> CGRect{
        let sidePadding = fullWidth * sidePaddingRate
        let maxBubbleViewWidth = fullWidth * maxBubbleWidthRate
        let offsetX : CGFloat
        if chat.senderId == myDogId {
            offsetX = fullWidth - sidePadding - maxBubbleViewWidth
        } else {
            offsetX = sidePadding + 63
        }
        return CGRect(x: offsetX, y: offsetY, width: maxBubbleViewWidth, height: 10.0)
    }
    
    private func prepareTextLabel(){
        let text = chat.message
        // Check if we sould show text or not.
//        guard  !text.isEmpty else {
//            return
//        }
        
        // Decide x and y
        let x = contentMargin
        let y = currenY + textFontSize / 2
        
        // Decide width and height
        let displayWidth = self.frame.width - 2 * contentMargin
        
        // Decide final frame of label
        let displayFrame = CGRect(x: x, y: y, width: displayWidth, height: textFontSize)
        
        // Create and prepare text label
        let label = UILabel(frame: displayFrame)
        self.textLabel = label
        label.font = UIFont.systemFont(ofSize:textFontSize)
        label.numberOfLines = 0 // important
        label.text = text
        label.sizeToFit() // important
        
        self.addSubview(label)
        currenY = label.frame.maxY
    }
    
    private func decideFinalSize(){
        var finalWidth : CGFloat = 0.0
        let finalHeight : CGFloat = currenY + contentMargin
    
        // Compare with width of text.
        if let label = textLabel {
            var tmpWidth : CGFloat
            if chat.senderId == myDogId {
                tmpWidth = label.frame.maxX + contentMargin
            } else { // From others.
                tmpWidth = label.frame.maxX + contentMargin
            }
            finalWidth = max(finalWidth, tmpWidth)
        }
        // final adjustment for a special case
        if chat.senderId == myDogId && self.frame.width > finalWidth {
            self.frame.origin.x += self.frame.width - finalWidth
        }
        self.frame.size = CGSize(width: finalWidth, height: finalHeight)
    }
    
    private func prepareBackgroundView(){
    
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        let view = UIView(frame: frame)
        backgroundView = view
        backgroundView?.clipsToBounds = true
        backgroundView?.layer.cornerRadius = 2
        backgroundView?.dropShadow()
        backgroundView?.backgroundColor = UIColor.white
        self.addSubview(backgroundView!)
        self.sendSubview(toBack: backgroundView!)
    }
    
}
extension UIView {
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
