//
//  FavoritesViewController.swift
//  NanChat
//
//  Created by George Fitzgibbons on 4/13/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import UIKit
import CoreData
import Contacts
import ContactsUI


class FavoritesViewController: UIViewController, TableViewFetchedResultsDisplayer,ContextViewController {
    
    //attributes
        //core data reuqiered by helper
    var context: NSManagedObjectContext?
    
    private var fetchedResultsController: NSFetchedResultsController?
    private var fetchedResultsDelegate: NSFetchedResultsControllerDelegate?
    
    
    //table
    private let tableView = UITableView(frame: CGRectZero, style: .Plain)
    private let cellIdentifier = "FavoriteCell"
    //generate the contact instances to store
    private let store = CNContactStore()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        title = "Favorites"
        
        navigationItem.leftBarButtonItem = editButtonItem()
        
        automaticallyAdjustsScrollViewInsets = false
        tableView.registerClass(FavoriteCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.dataSource = self
        tableView.delegate = self
        
        fillViewWith(tableView)
        
        if let context = context {
            let request = NSFetchRequest(entityName: "Contact")
            request.predicate = NSPredicate(format: "storageId != nil AND favorite = true")
            request.sortDescriptors = [NSSortDescriptor(key: "lastName", ascending: true), NSSortDescriptor(key: "firstName", ascending: true)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsDelegate = TableViewFetchedResultsDelegate(tableView: tableView, displayer: self)
            fetchedResultsController?.delegate = fetchedResultsDelegate
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print("There was a problem fetching.")
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //edit fucntion
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
    
        if editing {
            tableView.setEditing(true, animated: true)
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete all", style: .Plain, target: self, action: ".deleteAll")
        }else {
            tableView.setEditing(false, animated: true)
            navigationItem.rightBarButtonItem = nil

            guard let context = context where context.hasChanges else {return}
            do {
                try context.save()
            }catch{
                print("error saving")
            }
            }
        }
    //delate all fucntion
    func deleteAll() {
        guard let contacts = fetchedResultsController?.fetchedObjects as? [Contact] else {return}
        for contact in contacts {
            context?.deleteObject(contact)
        }
    }
    
    //need to confiruge witht he class TableViewFetchedResultsDisplayer to handle the cell stuff
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        //fetch contact
        guard let contact = fetchedResultsController?.objectAtIndexPath(indexPath) as? Contact else {return}
        //get data into the cellidentifier
        guard let cell = cell as? FavoriteCell else {return}
        cell.textLabel?.text = contact.fullName
   //
//        cell.detailTextLabel?.text = contact.status ?? "**no status***"
//        cell.phoneTypeLabel.text = contact.phoneNumbers?.filter({
//            number in
//            guard let number = number as? PhoneNumber else {return false}
//            return number.registered}).first?.kind
//        get the first one from the array allobjects
        cell.phoneTypeLabel.text = contact.phoneNumbers?.allObjects.first?.kind
        
        
        
        //givues us a button in the cell
        cell.accessoryType = .DetailButton

    }

}
extension FavoritesViewController: UITableViewDataSource{
    
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
    
}
extension FavoritesViewController: UITableViewDelegate{

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let contact = fetchedResultsController?.objectAtIndexPath(indexPath) as? Contact else {return}
        //see if there is a chat already
        let chatContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        chatContext.parentContext = context
        //fro the chat class static functions
        let chat = Chat.existing(directWith: contact, inContext: chatContext) ?? Chat.new(directWith: contact, inContext: chatContext)

        //
        let vc = ChatViewController()
        vc.context = chatContext
        vc.chat = chat
        vc.hidesBottomBarWhenPushed = true
        //naviaction controller
        navigationController?.pushViewController(vc, animated: true)

    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    //navigation and button (the info button)
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        guard let contact = fetchedResultsController?.objectAtIndexPath(indexPath) as? Contact else {return}
        guard let id = contact.contactId else {return}
        
        let cncontact: CNContact
        do{
            cncontact = try store.unifiedContactWithIdentifier(id, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()]) }
        catch {
            return}
        let vc = CNContactViewController(forContact: cncontact)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
        }
    
    //ediying rows
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let contact = fetchedResultsController?.objectAtIndexPath(indexPath) as? Contact else {return}
        contact.favorite = false
    }
    

}

    
    

