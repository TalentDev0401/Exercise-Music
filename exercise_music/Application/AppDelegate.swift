//
//  AppDelegate.swift
//  exercise_music
//
//  Created by Billiard ball on 02.05.2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import Fabric
import Crashlytics
import ObjectMapper
import AVFoundation
import DeviceCheck

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    //MARK:- Variables
    
    var window: UIWindow?
    var viewControlller : SWRevealViewController?
    var viewLoadCount:Int = 0
    var viewListCount:Int = 0
    var navigationController : UINavigationController?
    var fromPrevious:Bool!
    
    var isFromDownload:Bool!
    var isFromSearch:Bool!
    var isFromFavorite:Bool!
    var isFirstPlaying: Bool = true
    @objc var keyBoardIsUP: Bool = false
 
    let service = Service()
    var repeteCount:Int = 0
    var fromWhereRepeate:String = ""
    var radioTitle:String = ""
    var textFieldRepeteValue:String = ""
    
    var currentTime:Double = 0.00
    var duration:Double = 0.00
    var leftDuration:Double = 0.00
    var session_id: String = ""
    var delay_time: Int = 0
    var counter: Int = 0
    var timer: Timer?
    var sendSessionRequest: Bool = true
    var purchased: Bool!
    var isFavorite: Bool = false
    var device_id: String = ""
    
    @objc var customnavigationSignUpTintColor:UIColor?
    @objc var customnavigationSignUpBackgroundColor:UIColor?
    @objc var resetnavigationSignUpTintColor:UIColor?
    var backgroundSessionCompletionHandler: (() -> Void)?
    
    //MARK:- Life Cycle
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        IQKeyboardManager.shared.enable = true
                
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            print(uuid)
            self.device_id = uuid
        }
        
        if Utils.getUserInfoObject() != nil {
            self.fromPrevious = true
            jukebox = Utils.getUserInfoObject() as? Jukebox
            JukeBoxUtils.sharedInstance.configureBox(items: jukebox.queuedItems)
            kAppDelegate.repeteCount = 0
            jukebox.repeatOn = false
            jukebox.repeatcount = 0
        } else {
            self.fromPrevious = false    
        }
        self.navigationController?.navigationBar.setCustomNavigationBar()
        customnavigationSignUpTintColor = Color.customnavigationSignUpTintColor
        customnavigationSignUpBackgroundColor = Color.customNavigationBackgroundColor
        resetnavigationSignUpTintColor = Color.navigationSignUpTintColor
        UIApplication.shared.beginReceivingRemoteControlEvents()
        Fabric.with([Crashlytics.self])
        
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
            
        return true
    }
    
    @objc func keyboardWillAppear(notification: NSNotification){
        //  print("appear")
        self.keyBoardIsUP = true
    }
    
    @objc func keyboardWillDisappear(notification: NSNotification){
        // print("Disappear")
        self.keyBoardIsUP = false
    }
  
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        if event?.type == .remoteControl
        {
            switch event!.subtype
            {
            case .remoteControlPlay :
                jukebox.play()
            case .remoteControlPause :
                jukebox.pause()
            case .remoteControlNextTrack :
                if jukebox.playIndex == jukebox.queuedItems.count - 1
                {
                    //changed by ...PC
                    jukebox.replay()
                }
                else
                {
                    jukebox.repeatcount = 0
                    jukebox.playNext()
                }
            case .remoteControlPreviousTrack:
                if let time = jukebox.currentItem?.currentTime, time > 5 || jukebox.playIndex == 0 {
                    //  jukebox.replayCurrentItem()
                    //changed by ...PC
                    jukebox.play(atIndex: jukebox.queuedItems.count - 1)
                } else {
                    jukebox.repeatcount = 0
                    jukebox.playPrevious()
                }
            case .remoteControlTogglePlayPause:
                if jukebox.state == .playing
                {
                    jukebox.pause()
                } else
                {
                    jukebox.play()
                }
            default:
                break
            }
        }
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "exercise_music")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

