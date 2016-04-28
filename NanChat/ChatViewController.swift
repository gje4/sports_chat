//
//  ViewController.swift
//  NanChat
//
//  Created by George Fitzgibbons on 1/5/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import UIKit
import CoreData
import Firebase






class ChatViewController: UIViewController {
    
    //     //timer
    
    //timer
    let timerLabel = UILabel()
        var count = 0
    var seconds = 0
    var timer = NSTimer()
    
    
    //score
    let scoreLabel = UILabel()


    
    
    //set up the game
    func setupGame()  {
//     createHeader()
        

        seconds = 30
        count = 0
        timerLabel.text = "Time: \(seconds)"
        scoreLabel.text = "Score: \(count)"
tableView.reloadData()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("subtractTime"), userInfo: nil, repeats: true)
    }


    
    


    //chat view  updated to included timestamp,  grouped allows us to group by date
    private let tableView = UITableView(frame: CGRectZero, style: .Grouped)
    //new message bottom box
    private let newMessageField = UITextView()
    
    //score keeper and timer, just add to above new message field
//    private let scoreboardField = UITextView()


    
    //from our message class (replaced by dictionary)
//    private var messages = [Message]()
    //dicationary NSDATE is the key
    private var sections = [cname: [Message]()]
    private var names = [cname]
    private var dates = [NSDate]()

    
    //nsconctraint to move the chat up when clicked
    private var bottomConstraint: NSLayoutConstraint!
    
    //so we can reuse the cell
    private let cellIdentifier = "Cell"

    //global var so we can get it in app deleagete
    var context: NSManagedObjectContext?
    
    var chat: Chat?
    
    private enum Error: ErrorType {
        case NoChat
        case NoContext
    }
    
    
    //appears beform the data populates and is the first thing
    override func viewDidLoad() {
        super.viewDidLoad()


      //save and requst core data
        //get back saved
        do {
            
            guard let chat = chat else {throw Error.NoChat}
            guard let context = context else {throw Error.NoContext}
            
            
            let request = NSFetchRequest(entityName: "Message")
//            print(request)
            //filter the request, only get chat from current chat that was slected
            request.predicate = NSPredicate(format: "chat=%@", chat)
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

            
            if let result = try context.executeFetchRequest(request) as? [Message]
            {
//                print(result)

                for message in result {
//                    print(message)
                    //add to dictioary
                    addMessage(message)
//                    print(message)
                }
            }
            
        }
        catch {
            print("nothing from core data")
        }
        automaticallyAdjustsScrollViewInsets = false
        
        //       header label //name
        //if text from incoming is equal to cname, get a new name.

        //area for the user to type new message
        let newMessageArea = UIView()
        view.addSubview(newMessageArea)

        //new message button/text area and fucntionsality
        newMessageField.translatesAutoresizingMaskIntoConstraints = false
        //add new text box in the bottom message area
        newMessageArea.addSubview(newMessageField)
        
        newMessageField.scrollEnabled = false

        //Send Button
        let sendButton = UIButton()
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        //add button
        newMessageArea.addSubview(sendButton)
        sendButton.setTitle("Party", forState: .Normal)
        //add action to call the sendbutton fuction when tapped
        sendButton.addTarget(self, action: Selector("pressedSend:"), forControlEvents:.TouchUpInside)
        sendButton.setContentHuggingPriority(251, forAxis: .Horizontal)
        sendButton.setContentCompressionResistancePriority(751, forAxis: .Horizontal)
        
        //New game button
        let newGame = UIButton()
        newGame.translatesAutoresizingMaskIntoConstraints = false
        //add button
        newMessageArea.addSubview(newGame)
        newGame.setTitle("New Name", forState: .Normal)
        //add action to call the sendbutton fuction when tapped
        newGame.addTarget(self, action: Selector("repickName:"), forControlEvents:.TouchUpInside)
        newGame.setContentHuggingPriority(251, forAxis: .Horizontal)
        newGame.setContentCompressionResistancePriority(751, forAxis: .Horizontal)

    
        //Timer
        
//        timerLabel.text = "Time: \(seconds)"
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        newMessageArea.addSubview(timerLabel)
        timerLabel.setContentHuggingPriority(251, forAxis: .Horizontal)
        timerLabel.setContentCompressionResistancePriority(751, forAxis: .Horizontal)
        //score 
        
        // score
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        newMessageArea.addSubview(scoreLabel)
        scoreLabel.setContentHuggingPriority(251, forAxis: .Horizontal)
        scoreLabel.setContentCompressionResistancePriority(751, forAxis: .Horizontal)
        
        

        //constraint to move the chat up with the bottome box
        bottomConstraint = newMessageArea.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
        //need to activate because not in the array it is a one off
        bottomConstraint.active = true
        

        //area for the user to type new message
        newMessageArea.backgroundColor = UIColor.lightGrayColor()
        newMessageArea.translatesAutoresizingMaskIntoConstraints = false

        //contraints for new message area and send button
        let messageAreConstraints: [NSLayoutConstraint] = [
        newMessageArea.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
        newMessageArea.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
        newMessageField.leadingAnchor.constraintEqualToAnchor(newMessageArea.leadingAnchor, constant: 40),

        newMessageField.centerYAnchor.constraintEqualToAnchor(newMessageArea.centerYAnchor),
       //add send button
        sendButton.trailingAnchor.constraintEqualToAnchor(newMessageArea.trailingAnchor,constant:-15),
        newMessageField.trailingAnchor.constraintEqualToAnchor(sendButton.leadingAnchor, constant: -15),
        sendButton.centerYAnchor.constraintEqualToAnchor(newMessageField.centerYAnchor),
//        newMessageArea.heightAnchor.constraintEqualToAnchor(newMessageField.heightAnchor, constant:20),
            
        //add new game button
            newGame.leadingAnchor.constraintEqualToAnchor(newMessageArea.leadingAnchor,constant:-15),
            newMessageField.leadingAnchor.constraintEqualToAnchor(newGame.trailingAnchor, constant: -105),
            newGame.centerYAnchor.constraintEqualToAnchor(newMessageField.centerYAnchor , constant: -35),
            
            //add a timer
            timerLabel.leadingAnchor.constraintEqualToAnchor(newMessageArea.leadingAnchor,constant: 160),
            newMessageField.leadingAnchor.constraintEqualToAnchor(timerLabel.trailingAnchor, constant: -200),
            timerLabel.centerYAnchor.constraintEqualToAnchor(newMessageField.centerYAnchor , constant: -35),
            
            //add score
            scoreLabel.trailingAnchor.constraintEqualToAnchor(newMessageArea.trailingAnchor,constant:-1),
            newMessageField.trailingAnchor.constraintEqualToAnchor(scoreLabel.leadingAnchor, constant: -1),
            scoreLabel.centerYAnchor.constraintEqualToAnchor(newMessageField.centerYAnchor , constant: -35),
            
            //height of message bar
            newMessageArea.heightAnchor.constraintEqualToAnchor(newMessageField.heightAnchor, constant:70)

            
        ]
        
        
        //activate new message at the bottom
        NSLayoutConstraint.activateConstraints(messageAreConstraints)
        
        
        //activate ScoreBoard at the bottom
//        NSLayoutConstraint.activateConstraints(scoreBoardConstraints)
        
        
   //set up the cell so it can be re used
        tableView.registerClass(MessageCell.self, forCellReuseIdentifier: cellIdentifier)
        //need to tell app what is table view data source and delagte
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
//table sytling
//        tableView.backgroundView = UIImageView(image: UIImage(named: "MessageBubble"))
        tableView.separatorColor = UIColor.clearColor()
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 25
        
        
        
        //constrants for table
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        let tableViewConstraints: [NSLayoutConstraint] = [
        tableView.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor),
        tableView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
        tableView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
        tableView.bottomAnchor.constraintEqualToAnchor(newMessageArea.topAnchor)
        ]
        NSLayoutConstraint.activateConstraints(tableViewConstraints)
    
        //create a listing center for the keyboard so we know when its opened
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        
        //create a listner to control changes to message area, the grey bar need to bring up and down
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"),
            name: UIKeyboardWillHideNotification, object: nil)
        
        //NSNotification that will listen to change to our context
        if let mainContext = context?.parentContext ?? context{
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector:Selector("contextUpdated:"),
                name:NSManagedObjectContextObjectsDidChangeNotification,
                object:mainContext)
        }
        
        //tap gesture, this will control the keybowboard based on touch using tap feature
    let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapRecognizer)
    }
    
    //view did apper loads after the data is laoded
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var alert = UIAlertController(title: "Celebrity",
            message: "Get your teammates to guess as many celebrity names with out using the celebrity name in 30 seconds",
            preferredStyle: .Alert)
        self.presentViewController(alert, animated: true, completion:nil)
        
        
        
        alert.addAction(UIAlertAction(title: "Start Game", style: UIAlertActionStyle.Default, handler: {
        //change name
        action in self.setupGame()
        
        
        }
        ))

        
        tableView.scrollToBottom()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    //function time
    func subtractTime() {
        seconds--
        timerLabel.text = "Time: \(seconds)"
        
        if(seconds == 0)  {
            timer.invalidate()
            let alert = UIAlertController(title: "Time is up!",
                message: "You scored \(count) points",
                preferredStyle: UIAlertControllerStyle.Alert)
           //buttons
            alert.addAction(UIAlertAction(title: "Play Again", style: UIAlertActionStyle.Default, handler: {
 
                
                action in cname = pickName()

                //remove core data, start fresh
                self.deleteMessages("Message")
                
                self.tableView.reloadData()
                self.setupGame()

                
                }
                ))
            
            //buttons
            alert.addAction(UIAlertAction(title: "Back to Game", style: UIAlertActionStyle.Default, handler: nil))
                
            presentViewController(alert, animated: true, completion:nil)

                }

            
        }
//        else { print("try Again")}
    

    //function to control keyboard will show,  this will handle moving the shift
    func keyboardWillShow(notification: NSNotification) {
        updateBottomConstraint(notification)

    }
    //called from observer when it is about to be hiddn
    func keyboardWillHide(notification: NSNotification) {
        updateBottomConstraint(notification)
    }
    //function to call the tabgestur var (let)
    func handleSingleTap(recognizer:UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func updateBottomConstraint(notification: NSNotification) {
        if let
            userInfo = notification.userInfo,
            frame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue,
            animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
                let newFrame = view.convertRect(frame, fromView: (UIApplication.sharedApplication().delegate?.window)!)
                bottomConstraint.constant = newFrame.origin.y - CGRectGetHeight(view.frame)
                UIView.animateWithDuration(animationDuration, animations: {
                    self.view.layoutIfNeeded()
                })
                tableView.scrollToBottom()

        }
    }
    
    
    
    //fucntion for sending messga
    func pressedSend(button: UIButton) {
        //make sure there is data
        tableView.dataSource = self
        //        //check to save  message core data
        guard let text = newMessageField.text where text.characters.count > 0 else {return}
        checkTemporaryContect()
        
        guard let context = context else {return}
        guard let message = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as? Message else {return}
        message.text = text
        print(message.text = text)
        
        if (text.caseInsensitiveCompare(cname) == .OrderedSame) {
            count++
            message.score = count

            scoreLabel.text = "Score: \(count)"
        } else {
            //            print("wrong answer")
        }
        
   

       message.chat = chat
        chat?.lastMessageTime = message.timestamp


        //firebace
//        message.isIncoming = false
        message.timestamp = NSDate()
        message.celebrityName = cname
        print(message.celebrityName)
        message.celebrityName = cname

        //add to score

        
        //check to see if the answer is right, caps do not madder
        if  (text.caseInsensitiveCompare(cname) == .OrderedSame) {
            let alert = UIAlertController(title: "Correct",
                message: "You got it",
                preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Keep Going", style: UIAlertActionStyle.Default, handler: {
                //change name
                action in cname = pickName()
                
                //remove core data, start fresh
                              self.deleteMessages("Message")
                
                
                }
                ))
            
            presentViewController(alert, animated: true, completion:nil)
        }
//        else { print("try Again")}
        
        
        //        print(message)
        
        
        //save to core data
        do {
            try context.save()
        } catch {
            print("could not save to core data")
            return
        }
        newMessageField.text = ""
        
        //reload so new message shows up
        tableView.reloadData()
        
        //extention file leveraged
        tableView.scrollToBottom()
        //close keyboard and reset text
        view.endEditing(true)
        
    }
    //adding message to the dictionary using the key message
    func addMessage(message: Message) {
//        guard let date = message.timestamp else {return}
//        let calandar = NSCalendar.currentCalendar()
//        let startDay = calandar.startOfDayForDate(date)
        
        //comversion, key is the date the value is the messages (start date is key)
        var messages = sections[cname]
        print(messages)
        if messages == nil {
            //group by date (start day is calander)
//            dates.append(startDay)
//            dates = dates.sort({$0.earlierDate($1) == $0})
            //change to group by cname (start day is calander)
            names.append(cname)
            messages = [Message]()
        }
        messages!.append(message)
        //        messages!.sortInPlace{$0.timestamp!.earlierDate($1.timestamp!) == $0.timestamp!}
        
        sections[cname] = messages
        
        
    }
    //associated contextUpdated method for the listner
    func contextUpdated(notification:NSNotification){
        
        guard let set = (notification.userInfo![NSInsertedObjectsKey] as? NSSet) else {return}
        let objects = set.allObjects
        
        for obj in objects{
            guard let message = obj as? Message else {continue}
            if message.chat?.objectID == chat?.objectID{
                addMessage(message)
            }
        }
        
        tableView.reloadData()
        tableView.scrollToBottom()
    }

    
    
    func checkTemporaryContect() {
        if let mainContext = context?.parentContext,
            chat = chat {
                let tempContext = context
                context = mainContext
                do {
                    try tempContext?.save() }
                catch {
                    print("Error saving tempContext")
                }
                self.chat = mainContext.objectWithID(chat.objectID)
                    as? Chat
        }
    }
    //multiple context, parent child.  Need to trun off default setting
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    //function to determin if the user should see the name
    func headerName(label: Message) {
        if label.sender == true {
            return  cname = pickName()
        } else {
            cname = "Geuss Name"
        }
        
    }
    
    
    func repickName(button: UIButton) -> String{
        cname = pickName()
        tableView.reloadData()
//        print(cname)
        return cname
        
    }
    
    
    //delating Message
    func deleteMessages(entity: String) {
        do {
            let request = NSFetchRequest(entityName: "Message")
            //    print(request)
            
            if let result = try context!.executeFetchRequest(request) as? [Message]
            {
                
                for message in result {
                    
                    context!.deleteObject(message)
                    
                    try context!.save()
                    //    print(message)
                    self.tableView.reloadData()
                }
            }
        }
        catch {
            print("miss")
        }
    }
//
//    //header
//    private func createHeader() -> UIView {
//        let header = UIView()
//        
//        //button
//        let newGroupButton = UIButton()
//        newGroupButton.translatesAutoresizingMaskIntoConstraints = false
//        header.addSubview(newGroupButton)
//        
//        //boarder
//        let border = UIView()
//        border.translatesAutoresizingMaskIntoConstraints = false
//        header.addSubview(border)
//        border.backgroundColor = UIColor.lightGrayColor()
//        
//        //button function
//        newGroupButton.setTitle("Group Game", forState: .Normal)
//        newGroupButton.setTitleColor(view.tintColor, forState: .Normal)
//        newGroupButton.addTarget(self, action: "pressedNewGroup", forControlEvents: .TouchUpInside)
//        
//        //constraints for the header and the button
//        let constraints:[NSLayoutConstraint] = [
//            newGroupButton.heightAnchor.constraintEqualToAnchor(header.heightAnchor),
//            newGroupButton.trailingAnchor.constraintEqualToAnchor(header.layoutMarginsGuide.trailingAnchor),
//            //boarder
//            border.heightAnchor.constraintEqualToConstant(1),
//            border.leadingAnchor.constraintEqualToAnchor(header.leadingAnchor),
//            border.trailingAnchor.constraintEqualToAnchor(header.trailingAnchor),
//            border.bottomAnchor.constraintEqualToAnchor(header.bottomAnchor)
//        ]
//        NSLayoutConstraint.activateConstraints(constraints)
//        
//        header.setNeedsLayout()
//        header.layoutIfNeeded()
//        
//        let height = header.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
//        var frame = header.frame
//        frame.size.height = height
//        header.frame = frame
//        
//        //get header
//        return header
//    }
//

}

extension ChatViewController: UITableViewDataSource {
    //extention to translate dication to arryso can us in utable view
    func getMessages(section: Int) -> [Message] {
        let name = names[section]
        print(sections)
          print(sections[name])
        return sections[name]!

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //top private variable (keep track of group dates)
        print(names.count)
        return names.count
        

    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print(getMessages(section))

        return getMessages(section).count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MessageCell
        //get message array
        let messages = getMessages(indexPath.section)
        
//        print(messages)
        let message = messages[indexPath.row]
        cell.messageLabel.text = message.text
        cell.incoming(message.isIncoming)
        
        //remove the gry line seperator
        cell.separatorInset = UIEdgeInsetsMake(0, tableView.bounds.size.width, 0, 0)
        
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clearColor()
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

       
        dateLabel.text = cname
        
        paddingView.layer.cornerRadius = 10
        paddingView.layer.masksToBounds = true
        paddingView.backgroundColor = UIColor(red: 153/255, green: 204/255, blue: 255/255, alpha: 1.0)
        
        return view

    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50

    }
    
    //footer space that can be controlled
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        //defautl
        return UIView()
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    

}
    

//stop rows from highliting
//need to call the delagate
extension ChatViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}


//function to get new name

//extention to grab a random name
extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}

func pickName() -> String{
    let names = ["Michael Jordan",
        "Lebron",
        "Melo",
        "Jerry Seinfeld",
        "Steven Spielberg",
        "Spice Girls",
        "Harrison Ford",
        "Robin Williams",
        "Kobe",
        "The Rolling Stones"
    ]
    let cbname = names.randomItem()

    return cbname
    
}

//global random name
var cname = pickName()

var gameId = userId()
//function for when the game is won.  Need to pull a new name and clear the data
func userId() -> String {
    //create a game id
    let uuid = NSUUID().UUIDString

    //get a new name
    // clear text from ui view
return uuid
}




