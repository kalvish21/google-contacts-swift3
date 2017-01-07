//
//  UIColor.swift
//  Mounza
//
//  Created by Kalyan Vishnubhatla on 5/24/16.
//  Copyright © 2016 Kalyan Vishnubhatla. All rights reserved.
//

import UIKit

extension UIColor
{
    static func colorFromHex(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
