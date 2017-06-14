//
//  AppDelegate.swift
//  ClickBye
//
//  Created by Maxim  on 10/28/16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleMaps
import GooglePlaces
import Fabric
import Crashlytics
import FlickrKit
import Analytics
import KeychainAccess

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        self.initDefaults()
        
        FlickrKit.shared().initialize(withAPIKey: Constants.Flickr.apiKey, sharedSecret: Constants.Flickr.clientSecret)
        GMSServices.provideAPIKey("AIzaSyDgMOPeWTACX4SCy2V7bjQluSy29j2EgWM")
        GMSPlacesClient.provideAPIKey("AIzaSyDgMOPeWTACX4SCy2V7bjQluSy29j2EgWM")

        let analyticsConfiguration = SEGAnalyticsConfiguration(writeKey: Constants.Segment.writeKey)
        analyticsConfiguration.trackApplicationLifecycleEvents = true
        SEGAnalytics.setup(with: analyticsConfiguration)
        
        Fabric.with([Crashlytics.self])

        return true
        
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return  FBSDKApplicationDelegate.sharedInstance().application(app, open: url as URL!,
                                                                      sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation]
        )
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }


    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }


    func initDefaults() {
        if UserDefaults.standard.bool(forKey: "appHasAlreadyLaunched") == true {
            return
        }
        
        try? Keychain(service: Constants.Keychain.appServiceID).removeAll()
        
        UserDefaults.standard.set(true, forKey: "appHasAlreadyLaunched")
        UserDefaults.standard.synchronize()
    }
}

