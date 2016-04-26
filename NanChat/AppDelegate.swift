//
//  AppDelegate.swift
//  NanChat
//
//  Created by George Fitzgibbons on 1/5/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics
import Firebase



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private var contactImporter: ContactImporter?
    
    //syncers the context main and background if changes
    private var contactsSyncer:Syncer?
    private var contactsUploaderSyncer:Syncer?
    private var firebaseSyncer:Syncer?
    
    //firebase
    private var firebaseStore:FirebaseStore?
    
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        //answers
        Fabric.sharedSDK().debug = true
        Fabric.with([Crashlytics.self])
        
      
        //maincontext for core data to store data
        let mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        mainContext.persistentStoreCoordinator = CDHelper.sharedInstance.coordinator
        
        //get contact core data Contact
        //run in the backgorund (private queue)
       let contactsContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        contactsContext.persistentStoreCoordinator = CDHelper.sharedInstance.coordinator
        
        //setup firebase context
        let firebaseContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        firebaseContext.persistentStoreCoordinator = CDHelper.sharedInstance.coordinator
        //variables to use for firebase
        let firebaseStore = FirebaseStore(context: firebaseContext)
        self.firebaseStore = firebaseStore
        
        //uploaders for firebase
        contactsUploaderSyncer = Syncer(mainContext: mainContext, backgroundContext: firebaseContext)
        //
        contactsUploaderSyncer?.remoteStore = firebaseStore
        firebaseSyncer = Syncer(mainContext: mainContext, backgroundContext: firebaseContext)
        //
        firebaseSyncer?.remoteStore = firebaseStore

        
        //import contact
        contactImporter = ContactImporter(context: contactsContext)
        

        //sync themain and background sync and FIREBASE
        contactsSyncer = Syncer(mainContext: contactsContext, backgroundContext: firebaseContext)
        

        //tab controller, order matter with thi buttons.
        let tabController = UITabBarController()
        //view controller data and button can add more, String = Title
        let vcData:[(UIViewController, UIImage, String)] = [
           (ContactsViewController(), UIImage(named: "contact_icon")!, "Contacts"),
        //second button
            (AllChatsViewController(), UIImage(named:"chat_icon")!,  "Games"),
        //add favorites
            (FavoritesViewController(), UIImage(named: "favorites_icon")!, "Favorites")
        
        ]
        //for each view controller embeded the context to pass core data
        //contextview controller need to be in any view we go to
        let vcs = vcData.map {
            (vc: UIViewController, image: UIImage, title: String)-> UINavigationController in
            if var vc = vc as? ContextViewController {
                vc.context = mainContext
            }
            let nav = UINavigationController(rootViewController: vc)
            //add the image
            nav.tabBarItem.image = image
            //title
            nav.title = title
            
            return nav
        }
        //bottom tab
        tabController.viewControllers = vcs

        //now see if the user is register with firebase or not
        if firebaseStore.hasAuth() {
            firebaseStore.startSyncing()
            //listn for change
            contactImporter?.listenForChanges()
            //show nav bar for app

            window?.rootViewController = tabController
        } else {
            //login promt
            let vc = SignUpViewController()
            vc.remoteStore = firebaseStore
            //assign so tab can be displayed after sign up
            vc.rootViewController = tabController
            vc.contactImporter = contactImporter
            window?.rootViewController = vc

        }
        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
//    //fake core data
//    func importContacts(context:NSManagedObjectContext) {
//        //create a key to store data
//        let dataSeeded = NSUserDefaults.standardUserDefaults().boolForKey("dataSeeded")
//        guard !dataSeeded else {return}
//        //get contact from class
//        contactImporter?.fetch()
//        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "dataSeeded")
// 
//    }
}

