//
//  AppDelegate.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 12/16/17.
//  Copyright © 2017 Planar Form. All rights reserved.
//

import UIKit
import LocalAuthentication

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        PersistentStore.handleMigration()
        checkBiometrics()
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = AppCoordinator.shared.rootViewController
        window?.makeKeyAndVisible()
        
        UIApplication.shared.statusBarStyle = .lightContent
        UINavigationBar.appearance().makeTransparent()
        
        let cur = Currency.secondary
        CurrencyAPI.getCurrencyInfo(for: cur) { rate in
            if let rate = rate {
                Lincoln.log("Got currency info for '\(cur.rawValue)': \(cur.symbol)\(rate) per NANO")
                cur.setRate(rate)
            }
        }
        AppCoordinator.shared.start()
        if RtChk.ir() {
            let alert = UIAlertController(title: "Uh oh!", message: "We've detected your device may be jail broken. It is strongly recommended that you don't run wallet software on a jail broken device.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            AppCoordinator.shared.rootViewController.present(alert, animated: true)
        }
        
        return true
    }

    fileprivate func checkBiometrics() {
        let context = LAContext()
        var error: NSError? = NSError()
        if !context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            Keychain.standard.remove(key: KeychainKey.biometricsKey)
            UserSettings.biometricsOnLaunch(set: false)
        }
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        if let paymentInfo = URLHandler.parse(url: url),
            let _ = WalletUtil.derivePublic(from: paymentInfo.address ?? "") {
            // TODO: Present account view with send
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
