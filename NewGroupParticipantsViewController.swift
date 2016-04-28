//
//  NewGroupParticipantsViewController.swift
//
//
//  Created by George Fitzgibbons on 4/4/16.
//
//

import UIKit
import CoreData

class NewGroupParticipantsViewController: UIViewController {
    
    //core date set up
    var context:NSManagedObjectContext?
    var chat:Chat?
    var chatCreationDelegate:ChatCreationDelegate?
    
    //search
    private var searchField: UITextField!
    
    private var tableView = UITableView(frame: CGRectZero, style: .Plain)
    
    private let cellIdentifeir = "contactCell"
    
    //search display
    private var displayedContacts = [Contact]()
    
    //all contact for refrence
    private var allContacts = [Contact]()
    
    //selected contact
    private var selectedContacts = [Contact]()
    
    //use is searching
    private var isSearching = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "group game"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "create", style: .Plain, target: self, action: "createChat")
        showCreatButton(false)
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifeir)
        
        tableView.dataSource = self
        tableView.delegate = self
        //get callbacks from search field
        
        
        
        tableView.tableFooterView = UIView(frame:CGRectZero)
        
        
        
        
        searchField = createSearchField()
        searchField.delegate = self
        
        tableView.tableHeaderView = searchField
        
        
        
        if let context = context {
            let request = NSFetchRequest(entityName: "Contact")
            //only firebase
            request.predicate = NSPredicate(format: "storageId != nil")
            

            request.sortDescriptors = [NSSortDescriptor(key: "lastName", ascending: true),
                NSSortDescriptor(key: "firstName", ascending: true)]
            do {
                if let result = try context.executeFetchRequest(request) as? [Contact] {
                    allContacts = result
                }
            }
            catch {
                print("could not get core data")
            }
            
        }
        
        fillViewWith(tableView)
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //search
    private func createSearchField() -> UITextField {
        let searchField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        searchField.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        searchField.placeholder = "Type contact name"
        
        let holderView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        searchField.leftView = holderView
        searchField.leftViewMode = .Always
        
        let image = UIImage(named: "contact_icon")?.imageWithRenderingMode(.AlwaysTemplate)
        let contactImage = UIImageView(image: image)
        contactImage.tintColor = UIColor.darkGrayColor()
        
        holderView.addSubview(contactImage)
        contactImage.translatesAutoresizingMaskIntoConstraints = false
        
        //constrint
        let constraints: [NSLayoutConstraint] = [
            contactImage.widthAnchor.constraintEqualToAnchor(holderView.widthAnchor, constant: -20),
            contactImage.heightAnchor.constraintEqualToAnchor(holderView.heightAnchor, constant: -20),
            contactImage.centerXAnchor.constraintEqualToAnchor(holderView.centerXAnchor),
            contactImage.centerYAnchor.constraintEqualToAnchor(holderView.centerYAnchor)
        ]
        NSLayoutConstraint.activateConstraints(constraints)
        
        return searchField
    }
    
    //func for button
    private func showCreatButton(show:Bool)
    {
        if show {
            navigationItem.rightBarButtonItem?.tintColor = view.tintColor
            navigationItem.rightBarButtonItem?.enabled = true
        } else
        {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.lightGrayColor()
            navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    
    private func endSearch() {
        displayedContacts = selectedContacts
        tableView.reloadData()
    }
    //create chat and navigate
    func createChat() {
        guard let chat = chat, context = context else {return}
        chat.participants = NSSet(array: selectedContacts)
        chatCreationDelegate?.created(chat: chat, incontext: context)
        
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    
}
//datasource
extension NewGroupParticipantsViewController:UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return displayedContacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifeir, forIndexPath: indexPath)
        let contact = displayedContacts[indexPath.row]
        cell.textLabel?.text = contact.fullName
        cell.selectionStyle = .None
        return cell
        
    }
}
//table view delaget
extension NewGroupParticipantsViewController:UITableViewDelegate
{
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //look to se searching
        guard isSearching else {return}
        //what are they searching
        let contact = displayedContacts[indexPath.row]
        //we want it to return true to make sure it does not contain contact already.  do not re add
        guard !selectedContacts.contains(contact) else {return}
        //add to search
        selectedContacts.append(contact)
        //remove so we do not see
        allContacts.removeAtIndex(allContacts.indexOf(contact)!)
        searchField.text = ""
        //reload data
        endSearch()
        //so create
        showCreatButton(true)
    }
}

//search data source
extension NewGroupParticipantsViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        isSearching = true
        
        
        guard let currentText = textField.text else {
            
            //is searching, to change var
            
            endSearch()
            return true
        }
        //insert characters into text, string by replace have to us NSString
        let text = NSString(string: currentText).stringByReplacingCharactersInRange(range, withString: string)
        
        if text.characters.count == 0 {
            endSearch()
            return true
        }
        displayedContacts = allContacts.filter{
            contact in
            //true or false bool
            let match = contact.fullName.rangeOfString(text) != nil
            //if match
            return match
        }
        tableView.reloadData()
        return true
    }
}