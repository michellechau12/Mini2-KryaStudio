//
//  AppDelegate.swift
//  MiniChallenge2
//
//  Created by Muhammad Afif Fadhlurrahman on 01/07/24.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.landscape // Support only landscape orientations

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

