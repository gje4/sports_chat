//
//  ContactsViewController.swift
//  NanChat
//
//  Created by George Fitzgibbons on 4/8/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import UIKit
import CoreData
import ContactsUI
import Contacts



class ContactsViewController: UIViewController,ContextViewController, TableViewFetchedResultsDisplayer,ContactSelector {

    
    
    
    //need to add a context attirbute
    var context: NSManagedObjectContext?
    
    //protocol helpers to fetch data
    private var fetchedResultsController: NSFetchedResultsController?
    private var fetchedResultsDelegate: NSFetchedResultsControllerDelegate?
    
    private let tableView = UITableView(frame: CGRectZero, style:  .Plain)
    
    private let cellIdentifier = "ContactCell"
    
    //get the search function
    private var searchController:UISearchController?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //gett data
        tableView.dataSource = self
        //controler data
        tableView.delegate = self
        
navigationController?.navigationBar.topItem?.title = "Play with Friends"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "add"), style: .Plain, target: self, action:  "newContact")
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        fillViewWith(tableView)
        
        //get core data
        if let context = context {
            //request from core contacts
            let request = NSFetchRequest(entityName: "Contact")
            //sort by last name and then first name
            request.sortDescriptors = [NSSortDescriptor(key: "lastName", ascending: true),
            NSSortDescriptor(key: "firstName", ascending: true)]
            //
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "sortLetter", cacheName: nil)
            //table view
            fetchedResultsDelegate = TableViewFetchedResultsDelegate(tableView: tableView, displayer: self)
            //set up the delaagte
            fetchedResultsController?.delegate = fetchedResultsDelegate
            do {
                //fetch it
                try fetchedResultsController?.performFetch()
            } catch {
                print("could not fetch")
            }
        }
        //search function
        let resultsVC = ContactsSearchResultsController()
        //confirm protocal so we can recive a contacts from the search
      resultsVC.contactSelector = self
        
        //get contcts from search
        resultsVC.contacts = fetchedResultsController?.fetchedObjects as! [Contact]
        //
        searchController = UISearchController(searchResultsController: resultsVC)
        searchController?.searchResultsUpdater = resultsVC
        //overlay over contact controller
        definesPresentationContext = true
        //odifferent ui controller
        tableView.tableHeaderView = searchController?.searchBar
        
        
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func newContact() {
        let vc = CNContactViewController(forNewContact: nil)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
        
    }
    //confirgure cell for view
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        guard let contact = fetchedResultsController?.objectAtIndexPath(indexPath) as? Contact else {return}
        //populate full name
        cell.textLabel?.text = contact.fullName
        
    }
    
    //conformed to the ContactSelector Protocol we need to implement the selectedContact method
    func selectedContact(contact: Contact) {
        //make sure contact has contact id
        guard let id = contact.contactId else {return}
        let store = CNContactStore()
        let cncontact: CNContact
        do {
           //create a cncontact we can pass
            cncontact = try store.unifiedContactWithIdentifier(id, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
        } catch {
            return
        }
        //set up view controller and pass contact
        let vc = CNContactViewController(forContact:cncontact)
        vc.hidesBottomBarWhenPushed = true
       //set view controller to close search
        navigationController?.pushViewController(vc, animated: true)
        searchController?.active = false
    }


}
extension ContactsViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections  else {return 0}
        let currentSection = sections[section]
        return currentSection.numberOfObjects
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier,forIndexPath:  indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = fetchedResultsController?.sections else {return nil}
        let currentSection = sections[section]
        return currentSection.name
        
    }
    
    
}

//delagete
extension ContactsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let contact = fetchedResultsController?.objectAtIndexPath(indexPath) as? Contact else {return}
        selectedContact(contact)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
//implement method
extension ContactsViewController:CNContactViewControllerDelegate {
    //did complete contact
    func contactViewController(viewController:CNContactViewController, didCompleteWithContact
        contact:CNContact?) {
            //if cancel remove view (pop)
            if contact == nil {
                navigationController?.popViewControllerAnimated(true)
                return
            }
    }
}