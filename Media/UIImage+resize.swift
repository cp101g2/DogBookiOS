//
//  UIImage+resize.swift
//  DogBook
//
//  Created by 李一正 on 2018/7/27.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

extension UIImage{
    
    func resize(willSetWidth : CGFloat) -> UIImage?{
        
        let ratio = willSetWidth / self.size.width
        let height = self.size.height * ratio
        
        let finalSize = CGSize(width: willSetWidth, height: height)
        
        UIGraphicsBeginImageContext(finalSize)
        
        let drawRect = CGRect(x: 0, y: 0, width: finalSize.width, height: finalSize.height)
        self.draw(in: drawRect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
    
    func resize(willSetWidth : CGFloat, willSetHeight : CGFloat) -> UIImage?{
        
        let finalSize = CGSize(width: willSetWidth, height: willSetHeight)
        
        UIGraphicsBeginImageContext(finalSize)
        
        let drawRect = CGRect(x: 0, y: 0, width: finalSize.width, height: finalSize.height)
        self.draw(in: drawRect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
    
}
