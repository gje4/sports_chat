//
//  NewChatViewController.swift
//  NanChat
//
//  Created by George Fitzgibbons on 3/21/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import CoreData
import UIKit


class NewChatViewController: UIViewController,TableViewFetchedResultsDisplayer {

    var context: NSManagedObjectContext?
    private var fetchedResultsDelegate: NSFetchedResultsControllerDelegate?

    
    private var fetchedResultsController:NSFetchedResultsController?
    
    private let tableView = UITableView(frame: CGRectZero, style: .Plain)
    
    private let cellIdentifier = "ContactCell"
    
    //set up chat
    var chatCreationDelegate:ChatCreationDelegate?

    
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        //set up core data

        
        title = "New Game"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancel")
        
        automaticallyAdjustsScrollViewInsets = false
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        fillViewWith(tableView)

   
        //connect to core data
        if let context = context {
            let request = NSFetchRequest(entityName: "Contact")
//            request.predicate = NSPredicate(format: "storageId != nil")
            
            request.sortDescriptors = [NSSortDescriptor(key:"lastName", ascending:true)]
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "sortLetter", cacheName: "nil")
            
            fetchedResultsDelegate = TableViewFetchedResultsDelegate(tableView: tableView, displayer: self)
            fetchedResultsController?.delegate = fetchedResultsDelegate
            
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print("could not get anything")
            }
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //cancel function
    func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //cell
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        guard let contact = fetchedResultsController?.objectAtIndexPath(indexPath) as?
            Contact else {return}
        cell.textLabel?.text = contact.fullName
    }
    
}
extension NewChatViewController:UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else {return 0}
        let currentSection = sections[section]
        return currentSection.numberOfObjects
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
        }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = fetchedResultsController?.sections else {return nil}
        let currentSection = sections[section]
        return currentSection.name
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}
extension NewChatViewController:UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let contact = fetchedResultsController?.objectAtIndexPath(indexPath) as? Contact else {return}
        
        guard let context = context else {return}
 
        let chat = Chat.existing(directWith: contact, inContext: context) ?? Chat.new(directWith: contact, inContext: context)
        
        chatCreationDelegate?.created(chat: chat, incontext: context)
        dismissViewControllerAnimated(false, completion: nil)
    
    }
}
//moved to tableViewFetched Results delegate

//
//extension NewChatViewController: NSFetchedResultsControllerDelegate {
//    func controllerWillChangeContent(controller: NSFetchedResultsController) {
//        tableView.beginUpdates()
//    }
//    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
//        switch type {
//        case .Insert:
//            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
//        case .Delete:
//            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
//        default:
//            break
//        }
//    }
//    
//    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        switch type {
//        case .Insert:
//            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
//        
//        case .Update:
//            let cell = tableView.cellForRowAtIndexPath(indexPath!)
//            configureCell(cell!, atIndexPath: indexPath!)
//            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
//        case .Move:
//            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
//            //insert new path
//            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
//        case .Delete:
//            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
//        }
//    }
//    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        tableView.endUpdates()
//    }
//    
//    
//    
//    
//}
//
//
