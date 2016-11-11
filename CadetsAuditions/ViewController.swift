//
//  ViewController.swift
//  CadetsAuditions
//
//  Created by Justin Moore on 11/9/16.
//  Copyright © 2016 Justin Moore. All rights reserved.
//

import Cocoa
import Parse

class ViewController: NSViewController {

    @IBOutlet weak var checkCadets2: NSButton!
    @IBOutlet weak var checkCadets: NSButton!
    
    @IBAction func imgCadets_click(_ sender: Any) {
        if checkCadets.state == NSOnState {
            checkCadets.state = NSOffState
        } else {
            checkCadets.state = NSOnState
        }
    }
    
    @IBAction func imgCadets2_click(_ sender: Any) {
        if checkCadets2.state == NSOnState {
            checkCadets2.state = NSOffState
        } else {
            checkCadets2.state = NSOnState
        }
    }
    

    
    let Server = ParseServer.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Server.getCadetsAndCadets2()
        Server.getCadets2()
        Server.getCadets()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

