//
//  UIButton+Corner.swift
//  wassup
//
//  Created by MAC on 8/16/16.
//  Copyright (c) 2016 MAC. All rights reserved.
//

import UIKit

extension UIButton {
    override func corner(rad: Int, border: Int, colorBorder: Int) {
        layer.cornerRadius = CGFloat(rad)
        layer.borderWidth = CGFloat(border)
        clipsToBounds = true
        layer.borderColor = UIColor.fromRgbHex(colorBorder).CGColor
    }
}
