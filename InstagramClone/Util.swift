//
//  Util.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 7/30/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import Foundation
import UIKit

func instaTextField( _ placeholderText : String, _ modifyTextField : inout UITextField ) {
    modifyTextField.backgroundColor = .clear
    modifyTextField.tintColor = .white
    modifyTextField.textColor = .white
    modifyTextField.attributedPlaceholder = NSAttributedString.init(string: placeholderText, attributes: [ NSAttributedString.Key.foregroundColor : UIColor.init(white: 1, alpha: 0.4) ])
    
    let bottomLineLayer = CALayer()
    let thickness : CGFloat = 0.6
    bottomLineLayer.frame = CGRect(x: 0, y: modifyTextField.frame.size.height - thickness, width: modifyTextField.frame.size.width, height: thickness)
    bottomLineLayer.backgroundColor = UIColor.init(white: 1, alpha: 0.5).cgColor
    modifyTextField.layer.addSublayer(bottomLineLayer)
}
