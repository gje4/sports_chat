//
//  ChatCell.swift
//  NanChat
//
//  Created by George Fitzgibbons on 3/15/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import UIKit




class ChatCell: UITableViewCell {
    
    
    
    let nameLabel = UILabel()
    let messageLabel = UILabel()
    let dateLabel = UILabel()
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    
        super.init(style: style, reuseIdentifier:reuseIdentifier)
        
        nameLabel.font = UIFont.systemFontOfSize(18, weight: UIFontWeightBold)
        messageLabel.textColor = UIColor.grayColor()
        dateLabel.textColor = UIColor.grayColor()
        
        //
        let labels = [nameLabel, messageLabel, dateLabel]
        for label in labels {
            label.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(label)
        }
        
        let constraints:[NSLayoutConstraint] = [
            nameLabel.topAnchor.constraintEqualToAnchor(contentView.layoutMarginsGuide.topAnchor),
            nameLabel.leadingAnchor.constraintEqualToAnchor(contentView.layoutMarginsGuide.leadingAnchor),
            messageLabel.bottomAnchor.constraintEqualToAnchor(contentView.layoutMarginsGuide.bottomAnchor),
            messageLabel.leadingAnchor.constraintEqualToAnchor(nameLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraintEqualToAnchor(contentView.layoutMarginsGuide.trailingAnchor),
            dateLabel.firstBaselineAnchor.constraintEqualToAnchor(nameLabel.firstBaselineAnchor)
            
        ]
        NSLayoutConstraint.activateConstraints(constraints)

    }
    

    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
