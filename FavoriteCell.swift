//
//  FavoriteCell.swift
//  NanChat
//
//  Created by George Fitzgibbons on 4/13/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import UIKit

class FavoriteCell: UITableViewCell {

    //attribute
    let phoneTypeLabel = UILabel()
    
    //init cell style
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        
        //cell style
        detailTextLabel?.textColor = UIColor.lightGrayColor()
        phoneTypeLabel.textColor = UIColor.lightGrayColor()
        phoneTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(phoneTypeLabel)
     //contraints
        phoneTypeLabel.centerYAnchor.constraintEqualToAnchor(contentView.centerYAnchor).active = true
        phoneTypeLabel.trailingAnchor.constraintEqualToAnchor(contentView.layoutMarginsGuide.trailingAnchor).active = true
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
