//
//  UIColor+App.swift
//  VendingDemo
//
//  Created by Muhammad Azeem on 9/26/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = cString.substring(from: cString.index(cString.startIndex, offsetBy: 1))
        }
        
        assert(cString.characters.count == 6, "Invalid hex string")
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // App colors
    static var squash : UIColor { return UIColor(hex: "#f5a623") }
    static var textGray: UIColor { return UIColor(hex: "#a2a2a2") }
    static var backgroundGray: UIColor { return UIColor(hex: "#4b4547") }
    static var barSquash: UIColor { return UIColor(colorLiteralRed: 240/255.0, green: 173/255.0, blue: 61/255.0, alpha: 1.0) }
    
    func uiImage() -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y:0), size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(self.cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
