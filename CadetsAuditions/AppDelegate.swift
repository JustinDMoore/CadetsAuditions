//
//  AppDelegate.swift
//  CadetsAuditions
//
//  Created by Justin Moore on 11/9/16.
//  Copyright © 2016 Justin Moore. All rights reserved.
//

import Cocoa
import Bolts
import Parse

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {

        let configuration = ParseClientConfiguration {
            $0.applicationId = "wx8eMIWy1f9e60WrQJYUI81jlk5g6YYAPPmwxequ"
            $0.clientKey = "ECyvUjxayFW3un2sOkTkgFJC8mmqweeOAjW0OlKJ"
            $0.server = "http://corpsboard.herokuapp.com/parse"
            $0.isLocalDatastoreEnabled = true
        }
        Parse.initialize(with: configuration)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

