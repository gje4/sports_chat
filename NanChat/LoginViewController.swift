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


    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    var ref = Firebase(url:"https://party-time.firebaseio.com/")

//    let LoginToList = loginUser()

    
    
    
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        message: "Register",
        preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
            style: .Default) { (action: UIAlertAction) -> Void in
                
                let emailField = alert.textFields![0]
                let passwordField = alert.textFields![1]
                
                
                
                
          self.ref.createUser(emailField.text, password: passwordField.text,
                    withValueCompletionBlock: { error, result in
                        if error != nil {
                            // There was an error creating the account
                            print("could not send")

                        } else {
                            let uid = result["uid"] as? String
                                    self.logUser()
                            
                            print("Successfully created user account with uid: \(uid)")
                        
                        }
                })
                
                
                
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
    
    //add action for newChat
    
    func loginUser() {
        let vc = AllChatsViewController()
        let chatContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        
        chatContext.parentContext = context
        vc.context = chatContext
        //is the child vc.context
        
        
        
        //start a new chat
//        vc.chatCreationDelegate = self
        
        
        let navVC = UINavigationController(rootViewController: vc)
        presentViewController(navVC, animated: true, completion: nil)
        
    }
    
//    func created(chat chat: Chat, incontext context: NSManagedObjectContext) {
//        let vc = ChatViewController()
//        vc.context = context
//        vc.chat = chat
//        
//        navigationController?.pushViewController(vc, animated: true)
//    }
    
}
