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

    override func viewDidLoad() {
        super.viewDidLoad()

        let testObject = PFObject(className: "TestObject")
        testObject["foo"] = "Daniel Fish"
        testObject.saveInBackground()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

