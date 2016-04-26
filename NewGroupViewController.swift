//
//  NewGroupViewController.swift
//  NanChat
//
//  Created by George Fitzgibbons on 4/4/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import UIKit
import CoreData

class NewGroupViewController: UIViewController {

    var context:NSManagedObjectContext?
    var chatCreationDelegate: ChatCreationDelegate?
    
    //
    private let subjectField = UITextField()
    private let characterNumberLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "New Group Game"
        
        view.backgroundColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancel")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: "next")
        
        //handle the button
        upDateNextButton(forCharCount: 0)
        
        subjectField.placeholder = "Group Game"
        subjectField.delegate  = self
        subjectField.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(subjectField)
        
        //add the button fucntions
        updateCharacterLable(forCharCount: 0)
        
        
        characterNumberLabel.textColor = UIColor.lightGrayColor()
        characterNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subjectField.addSubview(characterNumberLabel)
        
        //bottom boarder
        let bottomBorder = UIView()
        bottomBorder.backgroundColor = UIColor.lightGrayColor()
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        subjectField.addSubview(bottomBorder)

        let constraints:[NSLayoutConstraint] = [
            subjectField.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor, constant: 20),
            subjectField.leadingAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.leadingAnchor),
            subjectField.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
            
            bottomBorder.widthAnchor.constraintEqualToAnchor(subjectField.widthAnchor),
            bottomBorder.bottomAnchor.constraintEqualToAnchor(subjectField.bottomAnchor),
            bottomBorder.leadingAnchor.constraintEqualToAnchor(subjectField.leadingAnchor),
            bottomBorder.heightAnchor.constraintEqualToConstant(1),
           
            characterNumberLabel.centerYAnchor.constraintEqualToAnchor(subjectField.centerYAnchor),
            characterNumberLabel.trailingAnchor.constraintEqualToAnchor(subjectField.layoutMarginsGuide.trailingAnchor),
        ]
        NSLayoutConstraint.activateConstraints(constraints)
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    func next() {
        guard let context = context, chat = NSEntityDescription.insertNewObjectForEntityForName("Chat", inManagedObjectContext: context) as? Chat else{return}
        chat.name = subjectField.text
        //transsition
        let vc  = NewGroupParticipantsViewController()
        vc.context = context
        vc.chat = chat
        vc.chatCreationDelegate = chatCreationDelegate
        navigationController?.pushViewController(vc, animated: true)
        }
    

    
    func updateCharacterLable(forCharCount length: Int) {
        characterNumberLabel.text = String(25 - length)
    }
    
    func upDateNextButton(forCharCount length: Int) {
        if length == 0 {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.lightGrayColor()
            navigationItem.rightBarButtonItem?.enabled = false
        }
        else {
            navigationItem.rightBarButtonItem?.tintColor = view.tintColor
            navigationItem.rightBarButtonItem?.enabled = true
        }

}
}
extension NewGroupViewController:UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
       //get current legnth, if nil 0
        let currentCharacterCount = textField.text?.characters.count ?? 0
        //see what propused ne length will be.  current plus new strengh
        let newLength = currentCharacterCount + string.characters.count -  range.length
        if newLength   <= 25 { upDateNextButton(forCharCount: newLength)
            updateCharacterLable(forCharCount: newLength)
            
            return true
        }
     return false
    }
}
