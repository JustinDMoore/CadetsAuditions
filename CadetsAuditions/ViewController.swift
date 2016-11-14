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
    var arrayOfAllMembers: [PFObject]? = nil
    var arrayOfFilteredMembers: [PFObject]? = nil
    var arrayOfInstrumentsToFilter = [String]()
    var arrayOfRatingsToFilter = [Int]()
    
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
    
    
    @IBOutlet weak var checkAllMembers: NSButton!
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
    
    //Rating checkboxes
    @IBOutlet weak var checkNoRating: NSButton!
    @IBOutlet weak var checkRating1: NSButton!
    @IBOutlet weak var checkRating2: NSButton!
    @IBOutlet weak var checkRating3: NSButton!
    
    //Results
    @IBOutlet weak var lblResults: NSTextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableMembers.delegate = self
        tableMembers.dataSource = self
        arrayOfAllMembers?.removeAll()
        arrayOfFilteredMembers?.removeAll()
        let query = PFQuery(className: "Member")
        query.findObjectsInBackground { (members: [PFObject]?, err: Error?) in
            if members != nil {
                self.arrayOfAllMembers = members!
                self.arrayOfFilteredMembers = members!
                self.lblResults.stringValue = "\(self.arrayOfAllMembers?.count) found"
                self.tableMembers.reloadData()
            }
        }
    }

    // SET FILTERS
    func updateInstrumentFilters() {
        arrayOfInstrumentsToFilter.removeAll()
        if checkTrumpet.state == NSOnState { arrayOfInstrumentsToFilter.append("Trumpet") }
        if checkMellophone.state == NSOnState { arrayOfInstrumentsToFilter.append("Mellophone") }
        if checkBaritone.state == NSOnState { arrayOfInstrumentsToFilter.append("Baritone") }
        if checkTuba.state == NSOnState { arrayOfInstrumentsToFilter.append("Tuba") }
        
        if checkSnare.state == NSOnState { arrayOfInstrumentsToFilter.append("Snare") }
        if checkTenor.state == NSOnState { arrayOfInstrumentsToFilter.append("Tenor") }
        if checkBass.state == NSOnState { arrayOfInstrumentsToFilter.append("Bass") }
        if checkFrontEnsemble.state == NSOnState { arrayOfInstrumentsToFilter.append("Front Ensemble") }
        
        if checkAllColorguard.state == NSOnState { arrayOfInstrumentsToFilter.append("Color Guard") }
        if checkAllDrumMajors.state == NSOnState { arrayOfInstrumentsToFilter.append("Drum Major") }
        
        searchMembers()
    }
    
    
    func updateRatingFilters() {
        arrayOfRatingsToFilter.removeAll()
        if checkNoRating.state == NSOnState { arrayOfRatingsToFilter.append(0) }
        if checkRating1.state == NSOnState { arrayOfRatingsToFilter.append(1) }
        if checkRating2.state == NSOnState { arrayOfRatingsToFilter.append(2) }
        if checkRating3.state == NSOnState { arrayOfRatingsToFilter.append(3) }
        
        searchMembers()
    }
    
    // END SET FILTERS
    
    
    // CHECK FILTERS
    func checkForInstrument(member: PFObject) {
        if !arrayOfInstrumentsToFilter.isEmpty {
            if let memberInstruments = member["sections"] as? [String] {
                for instrumentToCheck in arrayOfInstrumentsToFilter {
                    if memberInstruments.contains(instrumentToCheck) {
                        checkForRating(member: member) //We have a match, check the rating filter, then add
                    }
                }
            }
        } else {
            checkForRating(member: member)
        }
    }
    
    func checkForRating(member: PFObject) {
        if !arrayOfRatingsToFilter.isEmpty {
            if let memberRating = member["rating"] as? Int {
                for rating in arrayOfRatingsToFilter {
                    if memberRating == rating {
                        addMemberToFilteredArray(member: member)
                    }
                }
            } else { // member does not have a rating, are we searching for No ratings?
                if arrayOfRatingsToFilter.contains(0) {
                    addMemberToFilteredArray(member: member)
                }
            }
        } else {
            addMemberToFilteredArray(member: member)
        }
    }
    
    func addMemberToFilteredArray(member: PFObject) {
        //make sure they don't exist in filtered array, then add
        if !(arrayOfFilteredMembers?.contains(member))! {
            arrayOfFilteredMembers?.append(member)
        }
    }
    
    // END CHECK FILTERS
    
    func searchMembers() {
        arrayOfFilteredMembers?.removeAll()
        lblResults.stringValue = ""
        
        for member in arrayOfAllMembers! {
            
            //Corps
            var isCadets: Bool?
            var isCadets2: Bool?
            
            if checkAllMembers.state == NSOnState {
                
                checkForInstrument(member: member)
                
            } else if checkCadets.state == NSOnState {
                
                isCadets = member["cadets"] as? Bool ?? false
                isCadets2 = member["cadets2"] as? Bool ?? false
                if isCadets! && !isCadets2! {
                    
                    //we have a member matching the corps filter
                    
                    //do they match the selected instruments?
                    checkForInstrument(member: member)

                }
                
            } else if checkCadets2.state == NSOnState {
                
                isCadets = member["cadets"] as? Bool ?? false
                isCadets2 = member["cadets2"] as? Bool ?? false
                if isCadets2! && !isCadets! {
                    
                    //we have a member matching the corps filter
                    
                    //do they match the selected instruments?
                    checkForInstrument(member: member)
                    
                }
                
            } else if checkCadetsBoth.state == NSOnState {
             
                isCadets = member["cadets"] as? Bool ?? false
                isCadets2 = member["cadets2"] as? Bool ?? false
                if isCadets! && isCadets2! {
                    
                    //we have a member matching the corps filter
                    
                    //do they match the selected instruments?
                    checkForInstrument(member: member)
                    
                }
                
            }

            
//            //Brass
//            if checkTrumpet.state == NSOnState {
//                if let instruments = member["sections"] as? [String] {
//                    if instruments.contains("Trumpet") {
//                        //make sure they don't exist in filtered array, then add
//                        if !(arrayOfFilteredMembers?.contains(member))! {
//                            arrayOfFilteredMembers?.append(member)
//                        }
//                    }
//                }
//            }
//            
            
            
            
        } // end of for/loop
        
//
//        
//        if searchMellophone {
//            searchQuery.whereKey("sections", contains: "Mellophone")
//        }
//        
//        if searchBaritone {
//            searchQuery.whereKey("sections", contains: "Baritone")
//        }
//        
//        if searchTuba {
//            searchQuery.whereKey("sections", contains: "Tuba")
//        }
//
//        //Percussion
//        if searchSnare {
//            searchQuery.whereKey("sections", contains: "Snare")
//        }
//        
//        if searchTenor {
//            searchQuery.whereKey("sections", contains: "Tenor")
//        }
//        
//        if searchBass {
//            searchQuery.whereKey("sections", contains: "Bass")
//        }
//        
//        if searchFrontEnsemble {
//            searchQuery.whereKey("sections", contains: "Front Ensemble")
//        }
//        
//        //Color Guard
//        if searchColorGuard {
//            searchQuery.whereKey("sections", contains: "Color Guard")
//        }
//        
//        //Drum Major
//        if searchDrumMajor {
//            searchQuery.whereKey("sections", contains: "Drum Major")
//        }
//        
//        //Run the query
//        searchQuery.findObjectsInBackground { (members: [PFObject]?, err: Error?) in
//            if members != nil {
//                self.arrayOfMembers = members!
//                self.lblResults.stringValue = "\(self.arrayOfMembers?.count) found"
//                self.tableMembers.reloadData()
//            }
//        }
        
        tableMembers.reloadData()
        lblResults.stringValue = "\(arrayOfFilteredMembers!.count) members found"
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
    
    
    //Corps Filter
    @IBAction func checkCorps_click(_ sender: NSButton) {
        searchCorps = sender.tag
        searchMembers()
    }
    
    //Instrument Filter
    @IBAction func checkInstrument_click(_ sender: NSButton) {
        updateInstrumentFilters()
    }
    
    //Rating Filter
    @IBAction func checkRating_click(_ sender: NSButton) {
        updateRatingFilters()
    }
    
    //MARK:-
    //MARK:TABLE VIEW
    //MARK:-
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if arrayOfFilteredMembers?.count != nil {
            return arrayOfFilteredMembers!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var image:NSImage?
        var text:String = ""
        var cellIdentifier: String = ""
        
        // 1
        guard let member = arrayOfFilteredMembers?[row] else {
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