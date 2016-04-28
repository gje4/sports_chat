//
//  LoginViewController.swift
//  NanChat
//
//  Created by George Fitzgibbons on 3/9/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//


import UIKit
import CoreData
import Firebase
import Fabric
import Crashlytics


class LoginViewController: UIViewController {
    //global var so we can get it in app deleagete
    var context: NSManagedObjectContext?

    //remote store protocol
    var remoteStore: RemoteStore?
    
    //
    var contactImporter: ContactImporter?
    var rootViewController: UIViewController?
    
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    //view attributes
    private let phoneNumberField = UITextField()
    private let emailField = UITextField()
    private let passwordField = UITextField()
    
    var ref = Firebase(url:"https://party-time.firebaseio.com/")

//    let LoginToList = loginUser()




    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
//        super.viewDidLoad()
//        let label = UILabel()
//        label.text = "Play Sports Crack With Your Friend Now"
//        label.font = UIFont.systemFontOfSize(24)
//        view.addSubview(label)
//        //
//        let continueButton = UIButton()
//        continueButton.setTitle("Continue", forState: .Normal)
//        continueButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
//        continueButton.addTarget(self, action: "pressedContinue:", forControlEvents: .TouchUpInside)
//        view.addSubview(continueButton)
//        
//        //keypad
//        phoneNumberField.keyboardType = .PhonePad
//        continueButton.translatesAutoresizingMaskIntoConstraints = false
//        label.translatesAutoresizingMaskIntoConstraints = false
//        
//        let fields = [(phoneNumberField, "Phone Number"), (emailField, "Email"), (passwordField,"Password")]
//        fields.forEach{
//            $0.0.placeholder = $0.1
//        }
//        //hide password
//        passwordField.secureTextEntry = true
//        //autolayout
//        let stackView = UIStackView(arrangedSubviews:fields.map{$0.0})
//        stackView.axis = .Vertical
//        stackView.alignment = .Fill
//        stackView.spacing = 20
//        view.addSubview(stackView)
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        
//        //center constraints
//        let constraints:[NSLayoutConstraint] = [
//            label.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor, constant: 20),
//            label.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
//            stackView.topAnchor.constraintEqualToAnchor(label.bottomAnchor, constant: 20),
//            stackView.leadingAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.leadingAnchor),
//            stackView.trailingAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.trailingAnchor),
//            continueButton.topAnchor.constraintEqualToAnchor(stackView.bottomAnchor, constant: 20),
//            continueButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor)
//        ]
//        NSLayoutConstraint.activateConstraints(constraints)
//        
//        phoneNumberField.becomeFirstResponder()

        //check to see login
        ref.observeAuthEventWithBlock { (authData) -> Void in
            
            if authData != nil {
//                self.performSegueWithIdentifier(loginUser(), sender: nil)
                self.loginUser()
            }
            
        }
    }
  
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        

    }
    
    @IBAction func loginDidTouch(sender: AnyObject) {
        //auth then segue
        ref.authUser(textFieldLoginEmail.text, password: textFieldLoginPassword.text, withCompletionBlock: { (error, auth) -> Void in
//                            self.performSegueWithIdentifier(self.LoginToList, sender: nil)
            self.loginUser()

            
        })
    }
    
    @IBAction func singUpDidTouch(sender: AnyObject) { let alert = UIAlertController(title: "Register",
        message: "Start playing now",
        preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
            style: .Default) { (action: UIAlertAction) -> Void in
                
                let phonenumber = (alert.textFields![0] as UITextField).text
                let emailField = (alert.textFields![1] as UITextField).text
                let passwordField = (alert.textFields![2] as UITextField).text
                
                //remote store back up
                self.remoteStore?.signUp(phoneNumber: phonenumber!, email: emailField!, password: passwordField!, success: {
                    
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
                        
                })

                
//          self.ref.createUser(emailField.text, password: passwordField.text,
//                    withValueCompletionBlock: { error, result in
//                        if error != nil {
//                            // There was an error creating the account
//                            print("could not send")
//
//                        } else {
//                            let uid = result["uid"] as? String
//                                    self.logUser()
//                            
//                            print("Successfully created user account with uid: \(uid)")
//                        
//                        }
//                })
                
                
                
//                self.ref.createUser(emailField.text, password: passwordField.text) { (error: NSError!) in
//                    if error == nil {
//
//                        self.ref.authUser(emailField.text, password: passwordField.text,
//                            withCompletionBlock: { (error, auth) -> Void in
//                        })
//                    }
//                }
                
                
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (Phonenumber) -> Void in
            Phonenumber.placeholder = "Enter your phone number"
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textEmail) -> Void in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textPassword) -> Void in
            textPassword.secureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        //transistion back or make them login again
        
        presentViewController(alert,
            animated: true,
            completion: nil)
    }
    func logUser() {
        // TODO: Use the current user's information
        // You can call any combination of these three methods
        Crashlytics.sharedInstance().setUserEmail("emailField")
        Crashlytics.sharedInstance().setUserIdentifier("uid")
        Crashlytics.sharedInstance().setUserName("uid")
    }
    
//    //continue button pressed func
//    func pressedContinue(sender:UIButton){
//        //ensure only sent once
//        sender.enabled = false
//        
//        //test to check fields
//        guard let phoneNumber = phoneNumberField.text where phoneNumber.characters.count > 0 else {
//            alertForError("please include your phone number")
//            sender.enabled = true
//            
//            return
//        }
//        guard let email = emailField.text where email.characters.count > 0 else {
//            alertForError("please include your email")
//            sender.enabled = true
//            
//            return
//        }
//        guard let password = passwordField.text where password.characters.count > 0 else {
//            alertForError("please set password")
//            sender.enabled = true
//            
//            return
//        }
//        
//        
//        //remote store back up
//        remoteStore?.signUp(phoneNumber: phoneNumber, email: email, password: password, success: {
//            
//            //nav
//            guard let rootVC = self.rootViewController, remoteStore = self.remoteStore, contactImporter = self.contactImporter else {return}
//            //
//            remoteStore.startSyncing()
//            contactImporter.fetch()
//            contactImporter.listenForChanges()
//            //
//            self.presentViewController(rootVC, animated: true, completion: nil)
//            
//            
//            }, error:{ errorString in
//                //error
//                self.alertForError(errorString)
//                sender.enabled = true
//                
//        })
//    }
    //error for signup alert
    private func alertForError(error:String){
        let alertController = UIAlertController(title: "error", message: error, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //add action for newChat
//    
    func loginUser() {
        //ensure only sent once
        
        //test to check fields
        guard let phoneNumber = phoneNumberField.text where phoneNumber.characters.count > 0 else {
            alertForError("please include your phone number")
            
            return
        }
        guard let email = emailField.text where email.characters.count > 0 else {
            alertForError("please include your email")
            
            return
        }
        guard let password = passwordField.text where password.characters.count > 0 else {
            alertForError("please set password")
            
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
                
        })
        
    }
    
//    func created(chat chat: Chat, incontext context: NSManagedObjectContext) {
//        let vc = ChatViewController()
//        vc.context = context
//        vc.chat = chat
//        
//        navigationController?.pushViewController(vc, animated: true)
//    }
    
}
