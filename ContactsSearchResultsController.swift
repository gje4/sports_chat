//
//  ContactsSearchResultsController.swift
//  NanChat
//
//  Created by George Fitzgibbons on 4/11/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import UIKit
import CoreData

class ContactsSearchResultsController: UITableViewController {

    //confirm to protocal
    var contactSelector: ContactSelector?
    
    //
    private var filteredContacts = [Contact]()
    var contacts = [Contact]() {
        didSet {
            filteredContacts = contacts
        }
        }
    
    private let cellIdentifier = "ContactsSearchCell"
    
    private var searchController:UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    
        
       //register cell
   tableView.registerClass(UITableViewCell.self,
    forCellReuseIdentifier: cellIdentifier)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }

    // MARK: - Table view data source
    
    
//only 1 section (1 table)
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredContacts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
let contact = filteredContacts[indexPath.row]
    cell.textLabel?.text = contact.fullName
    return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let contact = filteredContacts[indexPath.row]
        contactSelector?.selectedContact(contact)

        
    }
}

//search function
extension ContactsSearchResultsController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {return}
        if searchText.characters.count > 0 {
            filteredContacts = contacts.filter{$0.fullName.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil}
    } else {
    filteredContacts = contacts
    }
    tableView.reloadData()
    }

}
