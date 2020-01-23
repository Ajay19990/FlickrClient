//
//  AppDelegate.swift
//  FlickrClient
//
//  Created by Ajay Choudhary on 18/01/20.
//  Copyright © 2020 Ajay Choudhary. All rights reserved.
//

import UIKit
import CoreData
import AFNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let NetworkReachabilityChanged = NSNotification.Name("NetworkReachabilityChanged")
    var previousNetworkReachabilityStatus: AFNetworkReachabilityStatus = .unknown

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AFNetworkReachabilityManager.shared().startMonitoring()
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { (status) in
            let reachabilityStatus = AFStringFromNetworkReachabilityStatus(status)
            var reachableOrNot = ""
            var networkSummary = ""
            var reachableStatusBool = false

            switch (status) {
            case .reachableViaWWAN, .reachableViaWiFi:
                // Reachable.
                reachableOrNot = "Reachable"
                networkSummary = "Connected to Network"
                reachableStatusBool = true
            default:
                // Not reachable.
                reachableOrNot = "Not Reachable"
                networkSummary = "Disconnected from Network"
                reachableStatusBool = false
            }

            // Any class which has observer for this notification will be able to report loss of network connection
            // successfully.

            if (self.previousNetworkReachabilityStatus != .unknown && status != self.previousNetworkReachabilityStatus) {
                NotificationCenter.default.post(name: self.NetworkReachabilityChanged, object: nil, userInfo: [
                    "reachabilityStatus" : "Connection Status : \(reachabilityStatus)",
                    "reachableOrNot" : "Network Connection \(reachableOrNot)",
                    "summary" : networkSummary,
                    "reachableStatus" : reachableStatusBool
                ])
            }
            self.previousNetworkReachabilityStatus = status
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.saveContext()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FlickrClient")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
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
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }



}

