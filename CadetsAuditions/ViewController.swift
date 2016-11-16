//
//  ViewController.swift
//  CadetsAuditions
//
//  Created by Justin Moore on 11/9/16.
//  Copyright © 2016 Justin Moore. All rights reserved.
//

import Cocoa
import Parse
import CSVImporter


class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {

    let Server = ParseServer.sharedInstance
    var searchQuery = PFQuery(className: "Member")
    var arrayOfAllMembers: [PFObject]? = nil
    var arrayOfFilteredMembers: [PFObject]? = nil
    var arrayOfInstrumentsToFilter = [String]()
    var arrayOfRatingsToFilter = [Int]()
    var memberToOpen: PFObject? = nil
    
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
    
    //Search boxes
    @IBOutlet weak var txtSearch: NSTextField!
    
    //Results
    @IBOutlet weak var lblResults: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableMembers.delegate = self
        tableMembers.dataSource = self
        tableMembers.target = self
        txtSearch.delegate = self
        refreshServer()
        //load()
        //deleteAllMembers()
    }

    func refreshServer() {
        arrayOfAllMembers?.removeAll()
        arrayOfFilteredMembers?.removeAll()
        let query = PFQuery(className: "Member")
        query.limit = 1000
        query.findObjectsInBackground { (members: [PFObject]?, err: Error?) in
            if members != nil {
                self.arrayOfAllMembers = members!
                self.arrayOfFilteredMembers = members!
                self.searchMembers()
            }
        }
    }
    
    func deleteAllMembers() {
        var count = 0
        arrayOfAllMembers?.removeAll()
        arrayOfFilteredMembers?.removeAll()
        let query = PFQuery(className: "Member")
        query.limit = 1000
        query.findObjectsInBackground { (members: [PFObject]?, err: Error?) in
            for member in members! {
                member.deleteInBackground(block: { (done: Bool, err: Error?) in
                    if done {
                        count += 1
                        print("deleted \(count) members")
                    }
                })
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
    @IBAction func btnRefresh_click(_ sender: NSButton) {
        refreshServer()
    }
    
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
        
        guard let member = arrayOfFilteredMembers?[row] else {
            return nil
        }
        
        if tableColumn == tableView.tableColumns[0] { // NUMBER
            if let num = member["number"] as? Int {
                text = String(num)
            }
            cellIdentifier = "cellNumber"
        }
            
        if tableColumn == tableView.tableColumns[1] { // NAME
            text = member["name"] as? String ?? ""
            cellIdentifier = "cellName"
        }
        
        if tableColumn == tableView.tableColumns[2] { // AGE
            let dob = member["dob"] as! Date
            let now = Date()
            let calendar = Calendar.current
            let ageComponents = calendar.dateComponents([.year], from: dob, to: now)
            let age = ageComponents.year!
            text = "\(age)"
            cellIdentifier = "cellAge"
        }
        
        else if tableColumn == tableView.tableColumns[3] { // CADETS LOGO
            let C = member["cadets"] as! Bool
            if C {
                image = NSImage(named: "Cadets")
            }
            cellIdentifier = "cellAuditioningForCadets"
        }
        
        else if tableColumn == tableView.tableColumns[4] { // CADETS2 LOGO
            let C2 = member["cadets2"] as! Bool
            if C2 {
                image = NSImage(named: "Cadets2")
            }
            cellIdentifier = "cellAuditioningForCadets2"
        }
        
        else if tableColumn == tableView.tableColumns[5] { // SECTION
            if let arrayOfInstruments = member["sections"] as! [String]? {
                var strInstruments = ""
                if arrayOfInstruments.count > 1 {
                    for instrument in arrayOfInstruments {
                        strInstruments += instrument + "    "
                    }
                } else if arrayOfInstruments.count == 1 {
                    strInstruments = arrayOfInstruments.first!
                }
                
                text = strInstruments
            }
            cellIdentifier = "cellSections"
        }
            
            
        else if tableColumn == tableView.tableColumns[6] { // RATING
            if let rating = member["rating"] as! Int? {
                text = "\(rating)"
            } else {
                text = ""
            }
            cellIdentifier = "cellRating"
        }
        
        else if tableColumn == tableView.tableColumns[7] { // PICTURE
            text = ""
            if let _ = member["picture"] as? PFFile {
                image = NSImage(named: "Picture")
            } else {
                image = nil
            }
            cellIdentifier = "cellPicture"
        }
        
        
        // 3
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            cell.imageView?.image = image ?? nil
            return cell
        } else {
            print("no \(cellIdentifier)")
        }
        return nil
        
    }
    
    @IBAction func doubleClick(_ sender: Any) {
        // 1
        guard tableMembers.selectedRow >= 0 , let member = arrayOfFilteredMembers?[tableMembers.selectedRow] else {
            return
        }
        memberToOpen = member
        self.performSegue(withIdentifier: "profile", sender: self)
    }
    
    
    //NSTEXTFIELD DELAGATE
    override func controlTextDidChange(_ obj: Notification) {
        arrayOfFilteredMembers?.removeAll()
        if txtSearch.stringValue.characters.count == 0 {
            searchMembers()
            return
        }
        
        for member in arrayOfAllMembers! {
            if let num = Int(txtSearch.stringValue) {
                if let memnum = member["number"] as? Int {
                    if memnum == num {
                        addMemberToFilteredArray(member: member)
                    }
                }
            } else {
                if let name = member["name"] as? String {
                    let nameLower = name.lowercased()
                    let textLower = txtSearch.stringValue.lowercased()
                    if nameLower.range(of: textLower) != nil {
                        addMemberToFilteredArray(member: member)
                    }
                }
            }
            tableMembers.reloadData()
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "profile" {
            if let vc = segue.destinationController as? ProfileViewController {
                vc.member = memberToOpen
            }
        }
    }
    
    func load() {
        var count = 0
        
        let path = "/Users/JMoore/Downloads/load.csv"
        let importer = CSVImporter<[String: String]>(path: path)
        importer.startImportingRecords(structure: { (headerValues) -> Void in
            
            //print(headerValues) // => ["firstName", "lastName"]
            
        }) { $0 }.onFinish { importedRecords in
            
            for record in importedRecords {
                //print(record) // => e.g. ["firstName": "Harry", "lastName": "Potter"]
                //print(record["Name (First)"]) // prints "Harry" on first, "Hermione" on second run
                //print(record["lastName"]) // prints "Potter" on first, "Granger" on second run
                
                let newMember = PFObject(className: "Member")
                newMember["name"] = record["Name (First)"]! + " " + record["Name (Last)"]!
                
                
                //BIRTHDAY
                let dateString = record["Date of Birth"]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM-dd-yyyy"
                let dob = dateFormatter.date(from: dateString!)
                newMember["dob"] = dob
                //END BIRTHDAY

                newMember["email"] = record["Email"]
                newMember["phone"] = record["Phone"]
                newMember["school"] = record["High School/College Name"]
                
                //CORPS
                let corps = record["I'm auditioning for"]
                if corps == "The Cadets" {
                    newMember["cadets"] = true
                    newMember["cadets2"] = false
                } else if corps == "Cadets2" {
                    newMember["cadets"] = false
                    newMember["cadets2"] = true
                } else if corps == "Both" {
                    newMember["cadets"] = true
                    newMember["cadets2"] = true
                }
                //END CORPS
                
                //INSTRUMENT/SECTION
                let str = record["I'm auditioning for the these sections"]
                let arr = str?.characters.split(separator: "|").map(String.init)
                newMember["sections"] = arr
                //END SECTION
                
                newMember["marchingYears"] = record["Years of marching experience"]
                
                //MARCHED ANOTHER CORPS
                let marched = record["Have you marched for another drum corps?"]
                if marched == "Yes" {
                    newMember["marchedCorps"] = true
                } else if marched == "No" {
                    newMember["marchedCorps"] = false
                }
                //END CORPS
                
                //WHAT CORPS
                newMember["otherCorps"] = record["What drum corps have you marched with?"]
                
                //Have you marched in a Winter Guard?
                let marchedGuard = record["Have you marched in a Winter Guard?"]
                if marchedGuard == "Yes" {
                    newMember["marchedGuard"] = true
                } else if marched == "No" {
                    newMember["marchedGuard"] = false
                }
                //END GUARD
                
                //What Winter Guards have you marched with?
                newMember["otherGuard"] = record["What Winter Guards have you marched with?"]
                
                //Have you marched in an Indoor Percussion Ensemble?
                let marchedPerc = record["Have you marched in an Indoor Percussion Ensemble?"]
                if marchedPerc == "Yes" {
                    newMember["marchedPerc"] = true
                } else if marched == "No" {
                    newMember["marchedPerc"] = false
                }
                //END GUARD
                
                //What ensembles have you marched with?
                newMember["otherPerc"] = record["What ensembles have you marched with?"]
                
                //Do you have any prior movement or dance training?
                let prevDance = record["Do you have any prior movement or dance training?"]
                if prevDance == "Yes" {
                    newMember["prevDance"] = true
                } else if marched == "No" {
                    newMember["prevDance"] = false
                }
                //END DANCE
                
                //Years of movement/dance training
                newMember["yearsDance"] = record["Years of movement/dance training"]
                
                //List your previous instructors/teachers
                newMember["prevInstructors"] = record["List your previous instructors/teachers"]
                
                //Can you attend the December camp?
                let dec = record["Can you attend the December camp?"]
                if dec == "Yes" {
                    newMember["december"] = true
                } else if marched == "No" {
                    newMember["december"] = false
                }
                
                //Why can't you attend the December camp?
                newMember["whyDecember"] = record["Why can't you attend the December camp?"]
                
                //Do you have a clear understanding of the financial obligations?
                let money = record["Do you have a clear understanding of the financial obligations?"]
                if money == "Yes" {
                    newMember["understandMoney"] = true
                } else if marched == "No" {
                    newMember["understandMoney"] = false
                }
                
                //What questions do you have about the financial obligations?
                newMember["questionMoney"] = record["What questions do you have about the financial obligations?"]
                
                //How do you plan to meet your financial obligations?
                newMember["planMoney"] = record["How do you plan to meet your financial obligations?"]
                
                //List any existing medical conditions
                newMember["medical"] = record["List any existing medical conditions"]
                
                //What do you hope to gain through participation in The Cadets?
                newMember["goals"] = record["What do you hope to gain through participation in The Cadets?"]
                
                
                newMember.saveInBackground(block: { (done: Bool, err: Error?) in
                    if done {
                        count += 1
                        print("\(count) imported")
                    }
                })
            }
            
        }
    }
}
