//
//  SignUpViewController.swift
//  NanChat
//
//  Created by George Fitzgibbons on 4/18/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    //view attributes
    private let phoneNumberField = UITextField()
    private let emailField = UITextField()
    private let passwordField = UITextField()
    
    //remote store protocol
    var remoteStore: RemoteStore?
    
    //
    var contactImporter: ContactImporter?
    var rootViewController: UIViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        view.backgroundColor = UIColor.whiteColor()

//set up
    let label = UILabel()
        label.text = "Play Sports Crack With Your Friend Now"
        label.font = UIFont.systemFontOfSize(24)
        view.addSubview(label)
        //
        let continueButton = UIButton()
        continueButton.setTitle("Continue", forState: .Normal)
        continueButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        continueButton.addTarget(self, action: "pressedContinue:", forControlEvents: .TouchUpInside)
        view.addSubview(continueButton)

        //keypad
        phoneNumberField.keyboardType = .PhonePad
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let fields = [(phoneNumberField, "Phone Number"), (emailField, "Email"), (passwordField,"Password")]
        fields.forEach{
            $0.0.placeholder = $0.1
        }
        //hide password
        passwordField.secureTextEntry = true
        //autolayout
        let stackView = UIStackView(arrangedSubviews:fields.map{$0.0})
        stackView.axis = .Vertical
        stackView.alignment = .Fill
        stackView.spacing = 20
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        //center constraints
        let constraints:[NSLayoutConstraint] = [
            label.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor, constant: 20),
            label.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
            stackView.topAnchor.constraintEqualToAnchor(label.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.trailingAnchor),
            continueButton.topAnchor.constraintEqualToAnchor(stackView.bottomAnchor, constant: 20),
            continueButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor)
        ]
        NSLayoutConstraint.activateConstraints(constraints)
        
        phoneNumberField.becomeFirstResponder()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

//continue button pressed func
    func pressedContinue(sender:UIButton){
        //ensure only sent once
        sender.enabled = false
        
        //test to check fields
        guard let phoneNumber = phoneNumberField.text where phoneNumber.characters.count > 0 else {
            alertForError("please include your phone number")
            sender.enabled = true

            return
        }
        guard let email = emailField.text where email.characters.count > 0 else {
            alertForError("please include your email")
            sender.enabled = true

            return
        }
        guard let password = passwordField.text where password.characters.count > 0 else {
            alertForError("please set password")
            sender.enabled = true

            return
        }
        
        
        //remote store back up
        remoteStore?.signUp(phoneNumber: phoneNumber, email: email, password: password, success: {
            
            //nav
            guard let rootVC = self.rootViewController, remoteStore = self.remoteStore, contactImporter = self.contactImporter else {return}
            //
            remoteStore.startSyncing()
            contactImporter.fetch()
            contactImporter.listenForChanges()
            //
            self.presentViewController(rootVC, animated: true, completion: nil)
  
            
            }, error:{ errorString in
                //error
                self.alertForError(errorString)
                sender.enabled = true

        })
    }

    //error for signup alert
    private func alertForError(error:String){
        let alertController = UIAlertController(title: "error", message: error, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
}
