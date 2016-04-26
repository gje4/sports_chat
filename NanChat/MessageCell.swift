//
//  ChatCell.swift
//  NanChat
//
//  Created by George Fitzgibbons on 1/6/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    //variables
    let messageLabel: UILabel = UILabel()
    //variables only for this chatcell
    
    //[] to make it ann array so we can activate the constraints
    private var outgoingContraints: [NSLayoutConstraint]!
    private var incomingContraints: [NSLayoutConstraint]!
    
    private let bubbleImageView = UIImageView()

    
    //overiding UITableViewCell to make custom
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleImageView)
        bubbleImageView.addSubview(messageLabel)
        
        if #available(iOS 9.0, *) {
            messageLabel.centerXAnchor.constraintEqualToAnchor(bubbleImageView.centerXAnchor).active = true
        } else {
            // Fallback on earlier versions
        }
        messageLabel.centerYAnchor.constraintEqualToAnchor(bubbleImageView.centerYAnchor).active = true
        
        bubbleImageView.widthAnchor.constraintEqualToAnchor(messageLabel.widthAnchor, constant: 50).active = true
        bubbleImageView.heightAnchor.constraintEqualToAnchor(messageLabel.heightAnchor, constant:20).active = true
        
        //trailing is the right side
        
        //use vars to get bubble on right or left used in the func incoming
        outgoingContraints = [
            bubbleImageView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor),
            bubbleImageView.leadingAnchor.constraintGreaterThanOrEqualToAnchor(contentView.centerXAnchor)
        ]
        
        incomingContraints = [
            bubbleImageView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor),
            bubbleImageView.trailingAnchor.constraintLessThanOrEqualToAnchor(contentView.centerXAnchor)
        ]
        
        bubbleImageView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 10).active = true
        bubbleImageView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -10).active = true
        
        
        messageLabel.textAlignment = .Center
        messageLabel.numberOfLines = 0
        
  
        
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    //function to show bubble on left or right depending on if it is incoming or out going
    func incoming(incoming: Bool) {
       //how to display incoming messages
        if incoming {
            NSLayoutConstraint.deactivateConstraints(outgoingContraints)
            NSLayoutConstraint.activateConstraints(incomingContraints)
            bubbleImageView.image = bubble.incoming
        } else {
            NSLayoutConstraint.deactivateConstraints(incomingContraints)
            NSLayoutConstraint.activateConstraints(outgoingContraints)
            bubbleImageView.image = bubble.outgoing

        }
    }
    

}


//creat the variable to call a function
let bubble = makeBubble()

//determine the color of the bubbles
func makeBubble() -> (incoming: UIImage, outgoing: UIImage) {
    let image = UIImage(named: "MessageBubble")!
    
    //use incest edge to make bubble confirm to test length
    let insetsIncoming = UIEdgeInsets(top: 17, left: 26.5, bottom: 17.5, right: 21)
    
    let insetsOutgoing = UIEdgeInsets(top: 17, left: 21, bottom: 17.5, right: 26.5)
    
    // rendering mode .AlwaysTemplate doesn't work when changing the orientation
    let outgoing = coloredImage(image, red: 0/255, green: 122/255, blue: 255/255, alpha: 1).resizableImageWithCapInsets(insetsOutgoing)
    
    let flippedImage = UIImage(CGImage: image.CGImage!, scale: image.scale, orientation: UIImageOrientation.UpMirrored)
    
    let incoming = coloredImage(flippedImage, red: 229/255, green: 229/255, blue: 229/255, alpha: 1).resizableImageWithCapInsets(insetsIncoming)
    return (incoming, outgoing)
}

//function to make color
func coloredImage(image: UIImage, red:CGFloat, green: CGFloat,
    blue: CGFloat, alpha: CGFloat) -> UIImage! {
        let rect = CGRect(origin: CGPointZero, size: image.size)
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()
        image.drawInRect(rect)
        
        CGContextSetRGBFillColor(context, red, green, blue, alpha)
        CGContextSetBlendMode(context, CGBlendMode.SourceAtop)
        CGContextFillRect(context, rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
        
}


