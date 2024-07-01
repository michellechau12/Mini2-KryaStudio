//
//  MiniChallenge2App.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 11/06/24.
//

import SwiftUI

@main
struct MiniChallenge2App: App {
        // Integrate the custom AppDelegate with SwiftUI
        @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear{
                    AppDelegate.orientationLock = .landscape
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                            windowScene.windows.first?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                    }
                }
        }
    }
}
