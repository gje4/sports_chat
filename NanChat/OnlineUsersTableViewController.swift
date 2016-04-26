//
//  OnlineUsersTableViewController.swift
//  NanChat
//
//  Created by George Fitzgibbons on 3/10/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class OnlineUsersTableViewController: UITableViewController,ChatCreationDelegate {

    var context: NSManagedObjectContext?

    
    // MARK: Constants
    let UserCell = "UserCell"
let usersRef = Firebase(url: "https://party-time.firebaseio.com/online")
    let ref = Firebase(url: "https://party-time.firebaseio.com")
    var user: User!

    let playGame = "playGame"

    //pass data

    
    var currentUsers: [String] = [String]()

    
    // MARK: Properties
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(currentUsers)
        
        title = "Open Game Lobby"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "new_chat"), style: .Plain, target: self, action: "newChat")

        
        ref.observeAuthEventWithBlock { authData in
            
            if authData != nil {
                
                self.user = User(authData: authData)
                
                // Create a child reference with a unique id
                let currentUserRef = self.usersRef.childByAutoId()
                
                // Save the current user to the online users list
                currentUserRef.setValue(self.user.email)
                
                // When the user disconnects remove the value
                currentUserRef.onDisconnectRemoveValue()
            }
            
        }

        // Create a listener for the delta additions to animate new items as they're added
        usersRef.observeEventType(.ChildAdded, withBlock: { (snap: FDataSnapshot!) in
            
            // Add the new user to the local array
            self.currentUsers.append(snap.value as! String)
            
            // Get the index of the current row
            let row = self.currentUsers.count - 1
            
            // Create an NSIndexPath for the row
            let indexPath = NSIndexPath(forRow: row, inSection: 0)
            
            // Insert the row for the table with an animation
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
            
        })
        
        // Create a listener for the delta deletions to animate removes from the table view
        usersRef.observeEventType(.ChildRemoved, withBlock: { (snap: FDataSnapshot!) -> Void in
            
            // Get the email to find
            let emailToFind: String! = snap.value as! String
            
            // Loop to find the email in the array
            for(index, email) in self.currentUsers.enumerate() {
                
                // If the email is found, delete it from the table with an animation
                if email == emailToFind {
                    let indexPath = NSIndexPath(forRow: index, inSection: 0)
                    self.currentUsers.removeAtIndex(index)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
                
            }
            
        })
        
    }
    //pass data
    func created(chat chat: Chat, incontext context: NSManagedObjectContext) {
        let vc = ChatViewController()
        vc.context = context
        vc.chat = chat
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func newChat() {
        let vc = NewChatViewController()
        let chatContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        
        chatContext.parentContext = context
        vc.context = chatContext
        //is the child vc.context
        
        
        
        //start a new chat
        vc.chatCreationDelegate = self
        
        
        let navVC = UINavigationController(rootViewController: vc)
        presentViewController(navVC, animated: true, completion: nil)
        
        
    }
    
    // MARK: UITableView Delegate methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(currentUsers)
        return currentUsers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(UserCell)! as UITableViewCell
        let onlineUserEmail = currentUsers[indexPath.row]
        cell.textLabel?.text = onlineUserEmail
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.blackColor()
        let paddingView = UIView()
        view.addSubview(paddingView)
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        
        let dateLabel = UILabel()
        paddingView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //contraints for the headers and date label, make sure they are centered and such
        let constraints:[NSLayoutConstraint] = [
            paddingView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
            paddingView.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor),
            
            dateLabel.centerXAnchor.constraintEqualToAnchor(paddingView.centerXAnchor),
            dateLabel.centerYAnchor.constraintEqualToAnchor(paddingView.centerYAnchor),
            
            paddingView.heightAnchor.constraintEqualToAnchor(dateLabel.heightAnchor, constant: 5),
            paddingView.widthAnchor.constraintEqualToAnchor(dateLabel.widthAnchor, constant: 50),
            view.heightAnchor.constraintEqualToAnchor(paddingView.heightAnchor)
        ]
        NSLayoutConstraint.activateConstraints(constraints)
        
        
        //date formatter
        //        let formatter = NSDateFormatter()
        //        formatter.dateFormat = "MMM dd YYY"
        //       header label //name
        //if text from incoming is equal to cname, get a new name.
        
        
        dateLabel.text = "Click to Challange"
        
        paddingView.layer.cornerRadius = 10
        paddingView.layer.masksToBounds = true
        paddingView.backgroundColor = UIColor(red: 153/255, green: 204/255, blue: 255/255, alpha: 1.0)
        
        return view
        
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
        
    }
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        self.performSegueWithIdentifier(self.playGame, sender: nil)

        return true
    }


    
   
    
    
}
