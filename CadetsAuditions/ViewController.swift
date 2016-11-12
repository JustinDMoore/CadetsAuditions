//
//  ViewController.swift
//  CadetsAuditions
//
//  Created by Justin Moore on 11/9/16.
//  Copyright © 2016 Justin Moore. All rights reserved.
//

import Cocoa
import Parse

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    let Server = ParseServer.sharedInstance
    var searchQuery = PFQuery(className: "Member")
    var arrayOfMembers: [PFObject]? = nil
    
    //Search variables
    var searchCorps = 0
    var searchTrumpet = false
    var searchMellophone = false
    var searchBaritone = false
    var searchTuba = false
    var searchSnare = false
    var searchTenor = false
    var searchBass = false
    var searchFrontEnsemble = false
    var searchColorGuard = false
    var searchDrumMajor = false
    
    @IBOutlet weak var tableMembers: NSTableView!
    
    
    @IBOutlet weak var checkCadets: NSButton!
    @IBOutlet weak var checkCadets2: NSButton!
    @IBOutlet weak var checkCadetsBoth: NSButton!

    //Search checkboxes
    @IBOutlet weak var checkAllBrass: NSButton!
    @IBOutlet weak var checkTrumpet: NSButton!
    @IBOutlet weak var checkMellophone: NSButton!
    @IBOutlet weak var checkBaritone: NSButton!
    @IBOutlet weak var checkTuba: NSButton!
    @IBOutlet weak var checkAllPercussion: NSButton!
    @IBOutlet weak var checkSnare: NSButton!
    @IBOutlet weak var checkTenor: NSButton!
    @IBOutlet weak var checkBass: NSButton!
    @IBOutlet weak var checkFrontEnsemble: NSButton!
    @IBOutlet weak var checkAllColorguard: NSButton!
    @IBOutlet weak var checkAllDrumMajors: NSButton!
    
    //Results
    @IBOutlet weak var lblResults: NSTextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableMembers.delegate = self
        tableMembers.dataSource = self
    }

    func searchMembers() {
        arrayOfMembers?.removeAll()
        lblResults.stringValue = "Searching..."
        searchQuery.cancel()
        
        //Corps
        switch searchCorps {
        case 1: // Cadets
            searchQuery.whereKey("cadets", equalTo: true)
            searchQuery.whereKey("cadets2", equalTo: false)
            break;
        case 2: // Cadets2
            searchQuery.whereKey("cadets", equalTo: false)
            searchQuery.whereKey("cadets2", equalTo: true)
            break;
        case 3: //Cadets + Cadets2
            searchQuery.whereKey("cadets", equalTo: true)
            searchQuery.whereKey("cadets2", equalTo: true)
            break;
        default:
            break;
        }
        
        //Brass
        if searchTrumpet {
            searchQuery.whereKey("sections", contains: "Trumpet")
        }
        
        if searchMellophone {
            searchQuery.whereKey("sections", contains: "Mellophone")
        }
        
        if searchBaritone {
            searchQuery.whereKey("sections", contains: "Baritone")
        }
        
        if searchTuba {
            searchQuery.whereKey("sections", contains: "Tuba")
        }

        //Percussion
        if searchSnare {
            searchQuery.whereKey("sections", contains: "Snare")
        }
        
        if searchTenor {
            searchQuery.whereKey("sections", contains: "Tenor")
        }
        
        if searchBass {
            searchQuery.whereKey("sections", contains: "Bass")
        }
        
        if searchFrontEnsemble {
            searchQuery.whereKey("sections", contains: "Front Ensemble")
        }
        
        //Color Guard
        if searchColorGuard {
            searchQuery.whereKey("sections", contains: "Color Guard")
        }
        
        //Drum Major
        if searchDrumMajor {
            searchQuery.whereKey("sections", contains: "Drum Major")
        }
        
        //Run the query
        searchQuery.findObjectsInBackground { (members: [PFObject]?, err: Error?) in
            if members != nil {
                self.arrayOfMembers = members!
                self.lblResults.stringValue = "\(self.arrayOfMembers?.count) found"
                self.tableMembers.reloadData()
            }
        }
    }
    
    //Actions
    //Corps
    @IBAction func imgCadets_click(_ sender: Any) {
        if checkCadets.state == NSOnState {
            checkCadets.state = NSOffState
        } else {
            checkCadets.state = NSOnState
        }
        checkCorps_click(checkCadets)
    }
    
    @IBAction func imgCadets2_click(_ sender: Any) {
        if checkCadets2.state == NSOnState {
            checkCadets2.state = NSOffState
        } else {
            checkCadets2.state = NSOnState
        }
        checkCorps_click(checkCadets2)
    }
    
    @IBAction func imgCadetsBoth1(_ sender: Any) {
        if checkCadetsBoth.state == NSOnState {
            checkCadetsBoth.state = NSOffState
        } else {
            checkCadetsBoth.state = NSOnState
        }
        checkCorps_click(checkCadetsBoth)
    }
    
    @IBAction func imgCadetsBoth2(_ sender: Any) {
        if checkCadetsBoth.state == NSOnState {
            checkCadetsBoth.state = NSOffState
        } else {
            checkCadetsBoth.state = NSOnState
        }
        checkCorps_click(checkCadetsBoth)
    }
    
    @IBAction func checkCorps_click(_ sender: NSButton) {
        searchCorps = sender.tag
        searchMembers()
    }
    
    @IBAction func checkAllBrass_click(_ sender: NSButton) {
        if sender.state == NSOnState {
            checkTrumpet.state = NSOnState
            checkMellophone.state = NSOnState
            checkBaritone.state = NSOnState
            checkTuba.state = NSOnState
        } else {
            checkTrumpet.state = NSOffState
            checkMellophone.state = NSOffState
            checkBaritone.state = NSOffState
            checkTuba.state = NSOffState
        }
        
        checkTrumpet_click(sender)
        checkMellophone_click(sender)
        checkBaritone_click(sender)
        checkTuba_click(sender)
    }
    
    //Brass
    @IBAction func checkTrumpet_click(_ sender: NSButton) {
        if sender.state == NSOnState {
            searchTrumpet = true
            print("searching trumpet")
        } else {
            searchTrumpet = false
            print("not searching trumpet")
        }
        
        searchMembers()
    }
    
    @IBAction func checkMellophone_click(_ sender: NSButton) {
        if sender.state == NSOnState {
            searchMellophone = true
            print("searching mellophone")
        } else {
            searchMellophone = false
            print("not searching mellophone")
        }
        
        searchMembers()
    }
    
    @IBAction func checkBaritone_click(_ sender: NSButton) {
        if sender.state == NSOnState {
            searchBaritone = true
            print("searching baritone")
        } else {
            searchBaritone = false
            print("not searching baritone")
        }
        
        searchMembers()
    }
    
    @IBAction func checkTuba_click(_ sender: NSButton) {
        if sender.state == NSOnState {
            searchTuba = true
            print("searching tuba")
        } else {
            searchTuba = false
            print("not searching tuba")
        }
        
        searchMembers()
    }
    
    //Percussion
    @IBAction func checkAllPercussion_click(_ sender: NSButton) {
        if checkAllPercussion.state == NSOnState {
            checkSnare.state = NSOnState
            checkTenor.state = NSOnState
            checkBass.state = NSOnState
            checkFrontEnsemble.state = NSOnState
        } else {
            checkSnare.state = NSOffState
            checkTenor.state = NSOffState
            checkBass.state = NSOffState
            checkFrontEnsemble.state = NSOffState
        }
        
        checkSnare_click(sender)
        checkTenor_click(sender)
        checkBass_click(sender)
        checkFrontEnsemble_click(sender)
    }
    
    @IBAction func checkSnare_click(_ sender: NSButton) {
        if sender.state == NSOnState {
            searchSnare = true
            print("searching snare")
        } else {
            searchSnare = false
            print("not searching snare")
        }
        
        searchMembers()
    }
    
    @IBAction func checkTenor_click(_ sender: NSButton) {
        if sender.state == NSOnState {
            searchTenor = true
            print("searching tenor")
        } else {
            searchTenor = false
            print("not searching tenor")
        }
        
        searchMembers()
    }

    @IBAction func checkBass_click(_ sender: NSButton) {
        if sender.state == NSOnState {
            searchBass = true
            print("searching bass")
        } else {
            searchBass = false
            print("not searching bass")
        }
        
        searchMembers()
    }
    
    @IBAction func checkFrontEnsemble_click(_ sender: NSButton) {
        if sender.state == NSOnState {
            searchFrontEnsemble = true
            print("searching front ensemble")
        } else {
            searchFrontEnsemble = false
            print("not searching front ensemble")
        }
        
        searchMembers()
    }
    
    @IBAction func checkAllColorGuard_click(_ sender: NSButton) {
        if sender.state == NSOnState {
            searchColorGuard = true
            print("searching color guard")
        } else {
            searchColorGuard = false
            print("not searching color guard")
        }
        
        searchMembers()
    }
    
    @IBAction func checkAllDrumMajors_click(_ sender: NSButton) {
        if sender.state == NSOnState {
            searchDrumMajor = true
            print("searching drum major")
        } else {
            searchDrumMajor = false
            print("not searching drum major")
        }
        
        searchMembers()
    }
    
    //MARK:-
    //MARK:TABLE VIEW
    //MARK:-
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if arrayOfMembers?.count != nil {
            return arrayOfMembers!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var image:NSImage?
        var text:String = ""
        var cellIdentifier: String = ""
        
        // 1
        guard let member = arrayOfMembers?[row] else {
            return nil
        }
        
        // 2
        if tableColumn == tableView.tableColumns[0] {
            text = member["name"] as? String ?? ""
            cellIdentifier = "cellName"
        } else if tableColumn == tableView.tableColumns[1] {
            let C = member["cadets"] as! Bool
            let C2 = member["cadets"] as! Bool
            if C && !C2 {
                image = NSImage(named: "Cadets")
            } else if !C && C2 {
                image = NSImage(named: "Cadets2")
            } else if C && C2 {
                image = NSImage(named: "CadetsCadets2")
            }
            cellIdentifier = "cellAuditioningFor"
        } else if tableColumn == tableView.tableColumns[2] {
            let arrayOfInstruments = member["sections"] as? [String]
            var strInstruments = ""
            if arrayOfInstruments != nil {
                for instrument in arrayOfInstruments! {
                    strInstruments += "\(instrument) - "
                }
            }
            text = strInstruments
            cellIdentifier = "cellSection"
        } else if tableColumn == tableView.tableColumns[3] {
            var rating: Int?
            rating = member["rating"] as! Int?
            if rating != nil {
                text = "\(rating)"
            } else {
                text = ""
            }
            cellIdentifier = "cellRating"
        }
        
        // 3
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            cell.imageView?.image = image ?? nil
            return cell
        }
        return nil
        
    }
}
