//
//  AppDelegate.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 3/2/16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import UIKit
import CoreData
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?
    var networkConnection : NetworkConnection = NetworkConnection.sharedInstance
    var parseConnection : ParseConnection = ParseConnection.sharedInstance

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.configurarParse()
        
        // Override point for customization after application launch.
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let splitViewController = storyboard.instantiateViewControllerWithIdentifier("SplitVC") as! UISplitViewController
//        if let tabBarVC = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as? TabBarViewController {
//            if let navigationController = tabBarVC.viewControllers?.first as? UINavigationController {
//                navigationController.viewControllers.first?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
//            }
//        }
        
//        splitViewController.delegate = self
//
//        let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
//        let controller = masterNavigationController.topViewController as! ContractViewController
//        controller.managedObjectContext = self.managedObjectContext
        
//        //Colores
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = UIColor.whiteColor()  // Back buttons and such
        navigationBarAppearance.barTintColor = UIColor(red: 142/255, green: 68/255, blue: 173/255, alpha: 1)
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]  // Title's text color
//        self.window?.tintColor = UIColor(red: 239/255/*0xEF*/, green: 254/255/*0xFE*/, blue: 246/255/*0xF6*/, alpha: 1)
        
        
        
        parseConnection.loadCodes()
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
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
//    // MARK: - Split view
//    
//    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
//        guard let secondaryAsNavController = secondaryViewController as? TabBarViewController else { return false }
//        guard let topAsDetailController = secondaryAsNavController.viewControllers?.first as? ActivityViewController else { return false }
//        if topAsDetailController.detailContact == nil {
//            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
//            return true
//        }
//        return false
//    }
    
    func splitViewController(splitViewController: UISplitViewController, showDetailViewController vc: UIViewController, sender: AnyObject?) -> Bool {
        return true
    }
    
    func splitViewController(splitViewController: UISplitViewController, showViewController vc: UIViewController, sender: AnyObject?) -> Bool {
        return true
    }
    
    func primaryViewControllerForExpandingSplitViewController(splitViewController: UISplitViewController) -> UIViewController? {
        return splitViewController.viewControllers.first
    }
    
    

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.solu4b.prueba.buho_Mobile" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("buho_Mobile", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    //MARK: - Configuración Parse
    
    func configurarParse() {
        registrarParseSubclasses()
        
        // Override point for customization after application launch.
        
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/iOS
        Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId("PIemJ3DhtKKLjPbwfHx5tLtFK1lCgDFgisj9EJOE",
            clientKey: "Q1WYmGJEIyu39bzANlJGfIePZRyDUupFURc5pi3T")
        
        //Si tienes la opción activada "Require Revocable Sessions" en Parse,
        //despues de realizar el Parse.setApplicationId:
        //This line will cause all login/signups from the SDK to use revocable sessions.
        //It will also issue a network call to Parse in the background to upgrade
        //your user's legacy session token to the new revocable token.
        PFUser.enableRevocableSessionInBackgroundWithBlock {
            (error: NSError?) -> Void in
            guard error == nil else {
                print(error!.code)
                print("Hubo un error en establecer RevocableSessionInBackgroundWithBlock.")
                return
            }
        }
        //PFUser.enableRevocableSessionInBackground()
        
        // [Optional] Track statistics around application opens.
        //PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
    }
    
    func registrarParseSubclasses() {
        CommentsApproval.registerSubclass()
//        Comment.registerSubclass()
        TypeCode.registerSubclass()
        Code.registerSubclass()
        Contact.registerSubclass()
//        RolesContact.registerSubclass()
        Company.registerSubclass()
        Contract.registerSubclass()
//        Meeting.registerSubclass()
        Responsibility.registerSubclass()
//        MeetingItemLog.registerSubclass()
        MeetingItem.registerSubclass()
//        Participant.registerSubclass()
        Resource.registerSubclass()
        
    }

}

enum ConnectionResult{
    case Success
    case NoCredentials
    case NoConnection
    case ServerError
    case TimeOut
}

