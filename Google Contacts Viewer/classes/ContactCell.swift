//
//  ContactCell.swift
//  Google Contacts Viewer
//
//  Created by Kalyan Vishnubhatla on 12/19/16.
//
//

import Foundation

class ContactCell: UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var frame = self.imageView!.frame
        frame = CGRect(x: frame.origin.x, y: 7, width: 30, height: 30)
        self.imageView!.frame = frame
        
        var textLabelFrame = self.textLabel!.frame
        textLabelFrame = CGRect(x: 60, y: textLabelFrame.origin.y, width: textLabelFrame.size.width, height: textLabelFrame.size.height)
        self.textLabel!.frame = textLabelFrame
    }
}
