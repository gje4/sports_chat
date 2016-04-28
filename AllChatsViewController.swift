//
//  AllChatsViewController.swift
//  NanChat
//
//  Created by George Fitzgibbons on 3/16/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import UIKit
import CoreData



class AllChatsViewController: UIViewController,TableViewFetchedResultsDisplayer ,ChatCreationDelegate,  ContextViewController  {
    
    var context: NSManagedObjectContext?
    
    var chatCreationDelegate:ChatCreationDelegate?

    
    
    private var fetchedResultsController: NSFetchedResultsController?
    private let tableView = UITableView(frame: CGRectZero, style: .Plain)
    
    private let cellIdentifier = "MessageCell"
    
    private var fetchedResultsDelegate:NSFetchedResultsControllerDelegate?
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the data to the extension of itself
        tableView.dataSource = self
        tableView.delegate = self
    
        //
        title = "Games"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Game", style: .Plain, target: self, action: "newChat")
        
        //header
        tableView.tableHeaderView = createHeader()

        
        //refactor with UI fill with viwq
        tableView.registerClass(ChatCell.self, forCellReuseIdentifier: cellIdentifier)
        automaticallyAdjustsScrollViewInsets = false

        fillViewWith(tableView)
        


        //get context for core data, this fetchs the data
        if let context = context {
            let request = NSFetchRequest(entityName: "Chat")
            request.sortDescriptors = [NSSortDescriptor(key: "lastMessageTime", ascending:  false)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            
            //using the class from tableview fetched
            fetchedResultsDelegate = TableViewFetchedResultsDelegate(tableView: tableView, displayer:self)
            fetchedResultsController?.delegate = fetchedResultsDelegate

            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print("there was a problem fetching")
            }
            
            
        }
        //call fake data
        fakeData()

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //add action for newChat
    
    func newChat() {
        let vc = NewChatViewController()
        vc.context = context
        vc.chatCreationDelegate = self
        let chatContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        
       chatContext.parentContext = context
        //is the child vc.context
        
        
        
        //start a new chat


        let navVC = UINavigationController(rootViewController: vc)
        presentViewController(navVC, animated: true, completion: nil)
        

        
    }
    
    //placeholderdata
    func fakeData() {
        guard let context =  context else {return}
        let chat = NSEntityDescription.insertNewObjectForEntityForName("Chat", inManagedObjectContext: context) as? Chat
    }
    
    //confirue cell method
    //info in cell
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        let cell = cell as! ChatCell

        
        guard let chat = fetchedResultsController?.objectAtIndexPath(indexPath) as? Chat else {return}
        guard let contact = chat.participants?.anyObject() as? Contact else {return}
        guard let lastMessage = chat.lastMessage, timestamp = lastMessage.timestamp, score = lastMessage.score, text = lastMessage.text else {return}
        
        
//        let formatter = NSDateFormatter()
//        formatter.dateFormat = "MM/dd/YY"
        cell.nameLabel.text = contact.fullName
        cell.dateLabel.text = StringLiteralType(score)
        cell.messageLabel.text = text
    }
    
    func created(chat chat: Chat, incontext context: NSManagedObjectContext) {
        let vc = ChatViewController()
        vc.context = context
        vc.chat = chat
        //hid bottom bar
        vc.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(vc, animated: true)
    }
    //header
    private func createHeader() -> UIView {
        let header = UIView()
        
        //button
        let newGroupButton = UIButton()
        newGroupButton.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(newGroupButton)
        
        //boarder
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(border)
        border.backgroundColor = UIColor.lightGrayColor()

        //button function
        newGroupButton.setTitle("Group Game", forState: .Normal)
        newGroupButton.setTitleColor(view.tintColor, forState: .Normal)
        newGroupButton.addTarget(self, action: "pressedNewGroup", forControlEvents: .TouchUpInside)
        
        //constraints for the header and the button
        let constraints:[NSLayoutConstraint] = [
            newGroupButton.heightAnchor.constraintEqualToAnchor(header.heightAnchor),
            newGroupButton.trailingAnchor.constraintEqualToAnchor(header.layoutMarginsGuide.trailingAnchor),
            //boarder
            border.heightAnchor.constraintEqualToConstant(1),
            border.leadingAnchor.constraintEqualToAnchor(header.leadingAnchor),
            border.trailingAnchor.constraintEqualToAnchor(header.trailingAnchor),
            border.bottomAnchor.constraintEqualToAnchor(header.bottomAnchor)
        ]
        NSLayoutConstraint.activateConstraints(constraints)
        
        header.setNeedsLayout()
        header.layoutIfNeeded()
        
        let height = header.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        var frame = header.frame
        frame.size.height = height
        header.frame = frame
        
        //get header
        return header
    }
    //action for header button
    func pressedNewGroup () {
        let vc = NewGroupViewController()
        let chatContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        chatContext.parentContext = context
        vc.context = chatContext
        vc.chatCreationDelegate = self
        let navVC = UINavigationController(rootViewController: vc)
        presentViewController(navVC, animated: true, completion: nil)
        
    }
    
}
extension AllChatsViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        guard let sections = fetchedResultsController?.sections else{return 0}
        
        let currentSection = sections[section]
        return currentSection.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
    configureCell(cell, atIndexPath: indexPath)
    return cell
    
    }
    
    
    
    }
    
extension AllChatsViewController:UITableViewDelegate {
    
    //how big the celll is
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    
    //highlight on row
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
       return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let chat = fetchedResultsController?.objectAtIndexPath(indexPath) as? Chat else {return}
        
      let vc = ChatViewController()
        vc.context = context
        vc.chat = chat
        //hide bottom bar
        vc.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
}
//moved to tableViewFetched Results delegate


//extension AllChatsViewController:NSFetchedResultsControllerDelegate {
//    
//    func controllerWillChangeContent(controller: NSFetchedResultsController) {
//        tableView.beginUpdates()
//    }
//    
//    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
//        switch type {
//        case .Insert:
//            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
//        
//        case .Delete:
//            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
//            default:
//            break
//        
//        }
//    }
//    
//    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        switch type {
//        case .Insert:
//            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
//        case .Update:
//            let cell = tableView.cellForRowAtIndexPath(indexPath!)
//            configureCell(cell!, atIndexPath: indexPath!)
//            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
//        case .Move:
//            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
//            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
//        case.Delete:
//            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
//        }
//    }
//    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        tableView.endUpdates()
//    }
//    
//}
//    
//    
//    
//    

