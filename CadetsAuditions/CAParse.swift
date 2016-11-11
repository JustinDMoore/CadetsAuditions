//
//  CAParse.swift
//  CadetsAuditions
//
//  Created by Justin Moore on 11/11/16.
//  Copyright © 2016 Justin Moore. All rights reserved.
//

import Foundation
import Parse
import Bolts

var serverInitialized = false
var arrayOfMembers = [PFObject]()

class ParseServer {
    static let sharedInstance = ParseServer()
    private init() {
        if !serverInitialized {
            let configuration = ParseClientConfiguration {
                $0.applicationId = "wx8eMIWy1f9e60WrQJYUI81jlk5g6YYAPPmwxequ"
                $0.clientKey = "ECyvUjxayFW3un2sOkTkgFJC8mmqweeOAjW0OlKJ"
                $0.server = "http://corpsboard.herokuapp.com/parse"
                $0.isLocalDatastoreEnabled = true
            }
            Parse.initialize(with: configuration)
            serverInitialized = true
        }
    }
    
    //MARK: -
    //MARK: All Members
    //MARK: -
    
    func getAllMembers() {
        let query = PFQuery(className: "Member")
        query.findObjectsInBackground { (members: [PFObject]?, err: Error?) in
            if ((members) != nil) {
                arrayOfMembers = members!
            }
            print("\(arrayOfMembers.count) members found")
        }
    }
    
    //MARK: -
    //MARK: Filter by Corps
    //MARK: -
    
    func getCadets() {
        let query = PFQuery(className: "Member")
        query.whereKey("cadets", equalTo: true)
        query.findObjectsInBackground { (members: [PFObject]?, err: Error?) in
            if ((members) != nil) {
                arrayOfMembers = members!
            }
            print("\(arrayOfMembers.count) members found")
        }
    }
    
    
    func getCadets2() {
        let query = PFQuery(className: "Member")
        query.whereKey("cadets2", equalTo: true)
        query.findObjectsInBackground { (members: [PFObject]?, err: Error?) in
            if ((members) != nil) {
                arrayOfMembers = members!
            }
            print("\(arrayOfMembers.count) members found")
        }
    }
    
    func getCadetsAndCadets2() {
        let query = PFQuery(className: "Member")
        query.whereKey("cadets2", equalTo: true)
        query.whereKey("cadets", equalTo: true)
        query.findObjectsInBackground { (members: [PFObject]?, err: Error?) in
            if ((members) != nil) {
                arrayOfMembers = members!
            }
            print("\(arrayOfMembers.count) members found")
        }
    }
    
    //MARK: -
    //MARK: Filter by SECTION
    //MARK: -
    func get() {
        let query = PFQuery(className: "Member")
        query.whereKey("cadets2", equalTo: true)
        query.whereKey("cadets", equalTo: true)
        query.findObjectsInBackground { (members: [PFObject]?, err: Error?) in
            if ((members) != nil) {
                arrayOfMembers = members!
            }
            print("\(arrayOfMembers.count) members found")
        }
    }
    
    //MARK: -
    //MARK: Filter by INSTRUMENT
    //MARK: -
}
