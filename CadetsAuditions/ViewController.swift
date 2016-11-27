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
import AVFoundation

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate, NSPopoverDelegate {

    let Server = ParseServer.sharedInstance
    var buttonClicked = 0
    var searchQuery = PFQuery(className: "Member")
    var arrayOfAllMembers: [PFObject]? = nil
    var arrayOfFilteredMembers: [PFObject]? = nil
    var arrayOfInstrumentsToFilter = [String]()
    var arrayOfVisualRatingsToFilter = [Int]()
    var arrayOfMusicRatingsToFilter = [Int]()
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
    @IBOutlet weak var checkVisual_NoRating: NSButton!
    @IBOutlet weak var checkVisual_1: NSButton!
    @IBOutlet weak var checkVisual_2: NSButton!
    @IBOutlet weak var checkVisual_3: NSButton!

    @IBOutlet weak var checkMusic_NoRating: NSButton!
    @IBOutlet weak var checkMusic_1: NSButton!
    @IBOutlet weak var checkMusic_2: NSButton!
    @IBOutlet weak var checkMusic_3: NSButton!
    
    @IBOutlet weak var checkVets: NSButton!
    @IBOutlet weak var checkContract: NSButton!

    @IBOutlet weak var lblUserName: NSTextField!
    @IBOutlet weak var barSelect: NSImageView!
    @IBOutlet weak var lblUserPosition: NSTextField!

    
    @IBOutlet weak var viewSearch: NSView!
    //Search boxes
    @IBOutlet weak var txtSearch: NSTextField!
    
    //Results
    @IBOutlet weak var lblResults: NSTextField!

    //Section Buttons
    @IBOutlet weak var btnBrass: NSButton!
    @IBOutlet weak var btnPercussion: NSButton!
    @IBOutlet weak var btnFrontEnsemble: NSButton!
    @IBOutlet weak var btnColorGuard: NSButton!
    @IBOutlet weak var btnDrumMajor: NSButton!
    @IBOutlet weak var btnHelp: NSButton!
    @IBOutlet weak var btnDelete: NSButton!
    @IBOutlet weak var btnCopy: NSButton!
    @IBOutlet weak var btnVideo: NSButton!
    @IBOutlet weak var btnUpload: NSButton!
    @IBOutlet weak var btnMail: NSButton!
    
    //Filter Groups
    
    @IBOutlet weak var lblFilterGroup: NSTextField!
    @IBOutlet weak var viewBrass: NSView!
    @IBOutlet weak var viewBattery: NSView!
    @IBOutlet weak var viewColorGuard: NSView!
    @IBOutlet weak var viewDrumMajor: NSView!
    @IBOutlet weak var viewRating: NSView!
    @IBOutlet weak var viewFrontEnsemble: NSView!
    @IBOutlet weak var lblMusic: NSTextField!
    @IBOutlet weak var lblVisual: NSTextField!
    
    @IBOutlet weak var btnAudition: NSButton!
    @IBOutlet weak var btnAssigned: NSButton!
    @IBOutlet weak var switchCorps: NSSlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableMembers.delegate = self
        tableMembers.dataSource = self
        txtSearch.delegate = self

        
        refreshServer()
        //load()
        
        loadSideBar()
        loadFilterBar()
        self.view.layer?.backgroundColor = NSColor(colorLiteralRed: 247/255, green: 247/255, blue: 247/255, alpha: 1).cgColor
    }
    
    @IBAction func btnAuditionAssigned_Click(_ sender: NSButton) {
        
        let gray = NSColor(calibratedRed: 75/255, green: 75/255, blue: 75/255, alpha: 1)
        if sender.tag == 0 {
            setCheckBoxColors(button: btnAudition)
            
            let pstyle = NSMutableParagraphStyle()
            pstyle.alignment = .center
            
            btnAssigned.attributedTitle = NSAttributedString(string: btnAssigned.title, attributes: [ NSForegroundColorAttributeName : gray, NSParagraphStyleAttributeName : pstyle ])
        } else if sender.tag == 1 {
            setCheckBoxColors(button: btnAssigned)
            
            let pstyle = NSMutableParagraphStyle()
            pstyle.alignment = .center
            
            btnAudition.attributedTitle = NSAttributedString(string: btnAudition.title, attributes: [ NSForegroundColorAttributeName : gray, NSParagraphStyleAttributeName : pstyle ])
        }
        
        switchCorps.doubleValue = Double(sender.tag)
        
        //Now refresh the search
        searchMembers()
    }
    
    @IBAction func switchCorps_Click(_ sender: NSSlider) {
        if switchCorps.doubleValue == 0.0 {
            btnAuditionAssigned_Click(btnAudition)
        } else if switchCorps.doubleValue == 1.0 {
            btnAuditionAssigned_Click(btnAssigned)
        }
    }
    
    
    override func mouseEntered(with event: NSEvent) {
        if let userData = event.trackingArea?.userInfo as? [String : AnyObject] {
            let button = userData["button"] as! String
            if button == "Brass" {
                if buttonClicked != 1 {
                    btnBrass.image = NSImage(named: "BrassHover")
                }
            } else if button == "Percussion" {
                if buttonClicked != 2 {
                    btnPercussion.image = NSImage(named: "PercussionHover")
                }
            }  else if button == "FrontEnsemble" {
                if buttonClicked != 3 {
                    btnFrontEnsemble.image = NSImage(named: "FrontEnsembleHover")
                }
            } else if button == "ColorGuard" {
                if buttonClicked != 4 {
                    btnColorGuard.image = NSImage(named: "ColorGuardHover")
                }
            } else if button == "DrumMajor" {
                if buttonClicked != 5 {
                    btnDrumMajor.image = NSImage(named: "DrumMajorHover")
                }
            } else if button == "Help" {
                if buttonClicked != 6 {
                    btnHelp.image = NSImage(named: "HelpHover")
                }
            } else if button == "Delete" {
                btnDelete.image = NSImage(named: "DeleteHover")
            } else if button == "Copy" {
                btnCopy.image = NSImage(named: "CopyHover")
            } else if button == "Video" {
                btnVideo.image = NSImage(named: "VideoHover")
            } else if button == "Upload" {
                btnUpload.image = NSImage(named: "UploadHover")
            } else if button == "Mail" {
                btnMail.image = NSImage(named: "MailHover")
            }
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        if let userData = event.trackingArea?.userInfo as? [String : AnyObject] {
            let button = userData["button"] as! String
            if button == "Brass" {
                if buttonClicked != 1 {
                    btnBrass.image = NSImage(named: "Brass")
                }
            } else if button == "Percussion" {
                if buttonClicked != 2 {
                    btnPercussion.image = NSImage(named: "Percussion")
                }
            } else if button == "FrontEnsemble" {
                if buttonClicked != 3 {
                    btnFrontEnsemble.image = NSImage(named: "FrontEnsemble")
                }
            } else if button == "ColorGuard" {
                if buttonClicked != 4 {
                    btnColorGuard.image = NSImage(named: "ColorGuard")
                }
            } else if button == "DrumMajor" {
                if buttonClicked != 5 {
                    btnDrumMajor.image = NSImage(named: "DrumMajor")
                }
            } else if button == "Help" {
                if buttonClicked != 6 {
                    btnHelp.image = NSImage(named: "Help")
                }
            } else if button == "Delete" {
                btnDelete.image = NSImage(named: "Delete")
            } else if button == "Copy" {
                btnCopy.image = NSImage(named: "Copy")
            } else if button == "Video" {
                btnVideo.image = NSImage(named: "Video")
            } else if button == "Upload" {
                btnUpload.image = NSImage(named: "Upload")
            } else if button == "Mail" {
                btnMail.image = NSImage(named: "Mail")
            }
        }
    }
    
    func loadSideBar() {
        let areaBrass = NSTrackingArea.init(rect: btnBrass.bounds, options: [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeAlways], owner: self, userInfo: ["button":"Brass"])
        btnBrass.addTrackingArea(areaBrass)
        
        let areaPercussion = NSTrackingArea.init(rect: btnPercussion.bounds, options: [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeAlways], owner: self, userInfo: ["button":"Percussion"])
        btnPercussion.addTrackingArea(areaPercussion)
        
        let areaFrontEnsemble = NSTrackingArea.init(rect: btnFrontEnsemble.bounds, options: [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeAlways], owner: self, userInfo: ["button":"FrontEnsemble"])
        btnFrontEnsemble.addTrackingArea(areaFrontEnsemble)
        
        let areaColorGuard = NSTrackingArea.init(rect: btnColorGuard.bounds, options: [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeAlways], owner: self, userInfo: ["button":"ColorGuard"])
        btnColorGuard.addTrackingArea(areaColorGuard)
        
        let areaDrumMajor = NSTrackingArea.init(rect: btnDrumMajor.bounds, options: [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeAlways], owner: self, userInfo: ["button":"DrumMajor"])
        btnDrumMajor.addTrackingArea(areaDrumMajor)
        
        let areaHelp = NSTrackingArea.init(rect: btnHelp.bounds, options: [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeAlways], owner: self, userInfo: ["button":"Help"])
        btnHelp.addTrackingArea(areaHelp)
        
        let areaDelete = NSTrackingArea.init(rect: btnDelete.bounds, options: [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeAlways], owner: self, userInfo: ["button":"Delete"])
        btnDelete.addTrackingArea(areaDelete)
        
        let areaCopy = NSTrackingArea.init(rect: btnCopy.bounds, options: [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeAlways], owner: self, userInfo: ["button":"Copy"])
        btnCopy.addTrackingArea(areaCopy)
        
        let areaVideo = NSTrackingArea.init(rect: btnVideo.bounds, options: [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeAlways], owner: self, userInfo: ["button":"Video"])
        btnVideo.addTrackingArea(areaVideo)
        
        let areaUpload = NSTrackingArea.init(rect: btnUpload.bounds, options: [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeAlways], owner: self, userInfo: ["button":"Upload"])
        btnUpload.addTrackingArea(areaUpload)
        
        let areaMail = NSTrackingArea.init(rect: btnMail.bounds, options: [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeAlways], owner: self, userInfo: ["button":"Mail"])
        btnMail.addTrackingArea(areaMail)
    }
    
    func loadFilterBar() {
        
        viewSearch.layer?.backgroundColor = NSColor(colorLiteralRed: 74/255, green: 74/255, blue: 74/255, alpha: 1).cgColor
        viewSearch.layer?.cornerRadius = 3
        
        setCheckBoxColors(button: checkVets)
        setCheckBoxColors(button: checkContract)
        setCheckBoxColors(button: checkAllMembers)
        
        setCheckBoxColors(button: checkTrumpet)
        setCheckBoxColors(button: checkMellophone)
        setCheckBoxColors(button: checkBaritone)
        setCheckBoxColors(button: checkTuba)
        
        setCheckBoxColors(button: checkSnare)
        setCheckBoxColors(button: checkTenor)
        setCheckBoxColors(button: checkBass)
        setCheckBoxColors(button: checkFrontEnsemble)
        
        setCheckBoxColors(button: checkAllColorguard)
        setCheckBoxColors(button: checkAllDrumMajors)
        
        setCheckBoxColors(button: checkMusic_1)
        setCheckBoxColors(button: checkMusic_2)
        setCheckBoxColors(button: checkMusic_3)
        setCheckBoxColors(button: checkMusic_NoRating)
        
        setCheckBoxColors(button: checkVisual_1)
        setCheckBoxColors(button: checkVisual_2)
        setCheckBoxColors(button: checkVisual_3)
        setCheckBoxColors(button: checkVisual_NoRating)
        
        viewBattery.frame = viewBrass.frame
        viewFrontEnsemble.frame = viewBrass.frame
        viewColorGuard.frame = viewBrass.frame
        viewDrumMajor.frame = viewBrass.frame
        
        btnSection_click(btnBrass)
        btnAuditionAssigned_Click(btnAudition)
        
    }
    
    @IBAction func btnSection_click(_ sender: NSButton) {
        
        buttonClicked = sender.tag
        
        //reposition the 'selection indicator'
        barSelect.frame = CGRect(x: barSelect.frame.origin.x, y: sender.frame.origin.y, width: barSelect.frame.size.width, height: barSelect.frame.size.height)
        
        //Change the button images
        if sender.identifier == "brass" {
            btnPercussion.image = NSImage(named: "Percussion")
            btnColorGuard.image = NSImage(named: "ColorGuard")
            btnDrumMajor.image = NSImage(named: "DrumMajor")
            btnHelp.image = NSImage(named: "Help")
            btnFrontEnsemble.image = NSImage(named: "FrontEnsemble")
            btnBrass.image = NSImage(named: "BrassClick")
        } else if sender.identifier == "percussion" {
            btnBrass.image = NSImage(named: "Brass")
            btnColorGuard.image = NSImage(named: "ColorGuard")
            btnDrumMajor.image = NSImage(named: "DrumMajor")
            btnHelp.image = NSImage(named: "Help")
            btnFrontEnsemble.image = NSImage(named: "FrontEnsemble")
            btnPercussion.image = NSImage(named: "PercussionClick")
        } else if sender.identifier == "colorguard" {
            btnBrass.image = NSImage(named: "Brass")
            btnPercussion.image = NSImage(named: "Percussion")
            btnDrumMajor.image = NSImage(named: "DrumMajor")
            btnHelp.image = NSImage(named: "Help")
            btnFrontEnsemble.image = NSImage(named: "FrontEnsemble")
            btnColorGuard.image = NSImage(named: "ColorGuardClick")
        } else if sender.identifier == "drummajor" {
            btnBrass.image = NSImage(named: "Brass")
            btnPercussion.image = NSImage(named: "Percussion")
            btnColorGuard.image = NSImage(named: "ColorGuard")
            btnHelp.image = NSImage(named: "Help")
            btnFrontEnsemble.image = NSImage(named: "FrontEnsemble")
            btnDrumMajor.image = NSImage(named: "DrumMajorClick")
        } else if sender.identifier == "help" {
            btnBrass.image = NSImage(named: "Brass")
            btnPercussion.image = NSImage(named: "Percussion")
            btnColorGuard.image = NSImage(named: "ColorGuard")
            btnDrumMajor.image = NSImage(named: "DrumMajor")
            btnFrontEnsemble.image = NSImage(named: "FrontEnsemble")
            btnHelp.image = NSImage(named: "HelpClick")
        } else if sender.identifier == "frontensemble" {
            btnBrass.image = NSImage(named: "Brass")
            btnPercussion.image = NSImage(named: "Percussion")
            btnColorGuard.image = NSImage(named: "ColorGuard")
            btnDrumMajor.image = NSImage(named: "DrumMajor")
            btnHelp.image = NSImage(named: "Help")
            btnFrontEnsemble.image = NSImage(named: "FrontEnsembleClick")
        }
        
        updateFilterBoxes()
    }
    
    func updateFilterBoxes() {
        switch buttonClicked {
        case 1:
            viewBattery.isHidden = true
            viewFrontEnsemble.isHidden = true
            viewColorGuard.isHidden = true
            viewDrumMajor.isHidden = true
            viewBrass.isHidden = false
            lblFilterGroup.stringValue = "BRASS"
            break;
        case 2:
            viewBrass.isHidden = true
            viewFrontEnsemble.isHidden = true
            viewColorGuard.isHidden = true
            viewDrumMajor.isHidden = true
            viewBattery.isHidden = false
            lblFilterGroup.stringValue = "BATTERY"
            break;
        case 3:
            viewBrass.isHidden = true
            viewBattery.isHidden = true
            viewColorGuard.isHidden = true
            viewDrumMajor.isHidden = true
            viewFrontEnsemble.isHidden = false
            lblFilterGroup.stringValue = "FRONT ENSEMBLE"
            break;
        case 4:
            viewBrass.isHidden = true
            viewBattery.isHidden = true
            viewFrontEnsemble.isHidden = true
            viewDrumMajor.isHidden = true
            viewColorGuard.isHidden = false
            lblFilterGroup.stringValue = "COLOR GUARD"
            break;
        case 5:
            viewBrass.isHidden = true
            viewBattery.isHidden = true
            viewFrontEnsemble.isHidden = true
            viewColorGuard.isHidden = true
            viewDrumMajor.isHidden = false
            lblFilterGroup.stringValue = "DRUM MAJOR"
            break;
        case 6:
            break;
        default:
            break;
        }
    }
    
    func setCheckBoxColors(button: NSButton) {
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .center
        
        button.attributedTitle = NSAttributedString(string: button.title, attributes: [ NSForegroundColorAttributeName : NSColor.white, NSParagraphStyleAttributeName : pstyle ])

    }
    
    @IBAction func video(_ sender: NSButton) {
        if memberToOpen != nil {
            let answer = dialogOKCancel(question: "Set \(memberToOpen!["name"]!) Video Audition", text: "Are you sure you want to set this as a video audition?")
            if answer {
                memberToOpen?["video"] = true
                memberToOpen?.saveEventually()
            }
        }
    }
    
    @IBAction func multiple(_ sender: NSButton) {
        if memberToOpen != nil {
            let answer = dialogOKCancel(question: "Copy \(memberToOpen!["name"]!)", text: "Are you sure you want to copy this member?")
            if answer {
                let new = PFObject(className: "Member")
                new["prevDance"] = memberToOpen?["prevDance"]
                new["goals"] = memberToOpen?["goals"]
                new["understandMoney"] = memberToOpen?["understandMoney"]
                new["marchedGuard"] = memberToOpen?["marchedGuard"]
                new["prevInstructors"] = memberToOpen?["prevInstructors"]
                new["december"] = memberToOpen?["december"]
                new["marchedCorps"] = memberToOpen?["marchedCorps"]
                new["marchedPerc"] = memberToOpen?["marchedPerc"]
                new["number"] = memberToOpen?["number"]
                new["name"] = memberToOpen?["name"]
                new["sections"] = memberToOpen?["sections"]
                new["multiple"] = true
                memberToOpen?["multiple"] = true
                memberToOpen?.saveInBackground()
                new["whyDecember"] = memberToOpen?["whyDecember"]
                new["phone"] = memberToOpen?["phone"]
                new["medical"] = memberToOpen?["medical"]
                new["school"] = memberToOpen?["school"]
                new["cadets2"] = memberToOpen?["cadets2"]
                new["otherGuard"] = memberToOpen?["otherGuard"]
                new["otherPerc"] = memberToOpen?["otherPerc"]
                new["marchingYears"] = memberToOpen?["marchingYears"]
                new["dob"] = memberToOpen?["dob"]
                new["planMoney"] = memberToOpen?["planMoney"]
                new["otherCorps"] = memberToOpen?["otherCorps"]
                new["questionMoney"] = memberToOpen?["questionMoney"]
                new["email"] = memberToOpen?["email"]
                new["yearsDance"] = memberToOpen?["yearsDance"]
                new["cadets"] = memberToOpen?["cadets"]
                new["picture"] = memberToOpen?["picture"]
                new.saveInBackground()
            }
        }
    }
    
    @IBAction func deleteMember(_ sender: NSButton) {
        if memberToOpen != nil {
            let answer = dialogOKCancel(question: "Delete \(memberToOpen!["name"]!)", text: "Are you sure you want to delete this member?")
            if answer {
                memberToOpen?.deleteInBackground(block: { (done: Bool, err: Error?) in
                    self.tableMembers.reloadData()
                })
            }
        }
    }

    func duplicateSections() {
//        for member in arrayOfAllMembers! {
//            let dup = member["multiple"]
//            if dup == true {
//                var new = PFObject(className: "Member")
//                new = member
//                new.saveInBackground()
//            }
//        }
    }
    
    func dialogOKCancel(question: String, text: String) -> Bool {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlertStyle.warning
        myPopup.addButton(withTitle: "OK")
        myPopup.addButton(withTitle: "Cancel")
        return myPopup.runModal() == NSAlertFirstButtonReturn
    }
    
    func refreshServer() {
        lblResults.stringValue = "Refreshing..."
        searchQuery.cancel()
        arrayOfAllMembers?.removeAll()
        arrayOfFilteredMembers?.removeAll()
        searchQuery.limit = 1000
        //searchQuery.order(byAscending: "name")
        searchQuery.order(byAscending: "lastUpdated")
        searchQuery.findObjectsInBackground { (members: [PFObject]?, err: Error?) in
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
        arrayOfVisualRatingsToFilter.removeAll()
        arrayOfMusicRatingsToFilter.removeAll()
        
        if checkVisual_NoRating.state == NSOnState { arrayOfVisualRatingsToFilter.append(0) }
        if checkVisual_1.state == NSOnState { arrayOfVisualRatingsToFilter.append(1) }
        if checkVisual_2.state == NSOnState { arrayOfVisualRatingsToFilter.append(2) }
        if checkVisual_3.state == NSOnState { arrayOfVisualRatingsToFilter.append(3) }
        
        if checkMusic_NoRating.state == NSOnState { arrayOfMusicRatingsToFilter.append(0) }
        if checkMusic_1.state == NSOnState { arrayOfMusicRatingsToFilter.append(1) }
        if checkMusic_2.state == NSOnState { arrayOfMusicRatingsToFilter.append(2) }
        if checkMusic_3.state == NSOnState { arrayOfMusicRatingsToFilter.append(3) }
        
        //set the music and visual rating images to "ON" or "OFF"
        if arrayOfVisualRatingsToFilter.count > 0 {
            lblVisual.textColor = NSColor.white
        } else {
            lblVisual.textColor = NSColor(calibratedRed: 75/255, green: 75/255, blue: 75/255, alpha: 1)
        }
        
        if arrayOfMusicRatingsToFilter.count > 0 {
            lblMusic.textColor = NSColor.white
        } else {
            lblMusic.textColor = NSColor(calibratedRed: 75/255, green: 75/255, blue: 75/255, alpha: 1)
        }
        
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
            checkForRating(member: member) // no instruments selected, so skip to rating
        }
    }
    
    func checkForRating(member: PFObject) {
        
        
        if arrayOfVisualRatingsToFilter.isEmpty && arrayOfMusicRatingsToFilter.isEmpty {
            //we don't care about ratings, add the member
            addMemberToFilteredArray(member: member)
            
        } else if arrayOfVisualRatingsToFilter.isEmpty && !arrayOfMusicRatingsToFilter.isEmpty {
            //we only care about music ratings
            //MUSIC
            if !arrayOfMusicRatingsToFilter.isEmpty {
                if let memberMusicRating = member["musicRating"] as? Int {
                    for rating in arrayOfMusicRatingsToFilter {
                        if memberMusicRating == rating {
                            addMemberToFilteredArray(member: member)
                        }
                    }
                } else { // member does not have a rating, are we searching for No ratings?
                    if arrayOfMusicRatingsToFilter.contains(0) {
                        addMemberToFilteredArray(member: member)
                    }
                }
            } else {
                addMemberToFilteredArray(member: member)
            }

            
        } else if !arrayOfVisualRatingsToFilter.isEmpty && arrayOfMusicRatingsToFilter.isEmpty {
            //we only care about visual ratings
            if !arrayOfVisualRatingsToFilter.isEmpty {
                if let memberVisualRating = member["visualRating"] as? Int {
                    for rating in arrayOfVisualRatingsToFilter {
                        if memberVisualRating == rating {
                            print("match visual \(rating) - \(memberVisualRating)")
                            addMemberToFilteredArray(member: member)
                        }
                    }
                } else { // member does not have a rating, are we searching for No ratings?
                    if arrayOfVisualRatingsToFilter.contains(0) {
                        addMemberToFilteredArray(member: member)
                    }
                }
            } else {
                addMemberToFilteredArray(member: member)
            }
            
            
        } else if !arrayOfVisualRatingsToFilter.isEmpty && !arrayOfMusicRatingsToFilter.isEmpty {
            //we care about both ratings
            let memberVis = member["visualRating"] as? Int ?? nil
            let memberMus = member["musicRating"] as? Int ?? nil
            
            var addMusic = false
            var addVisual = false
            
            if memberVis != nil {
                for rating in arrayOfVisualRatingsToFilter {//check visual rating
                    if memberVis == rating {
                        addVisual = true
                    }
                }
            } else {
                // are we checking for no rating?
                if arrayOfVisualRatingsToFilter.contains(0) {
                    addMemberToFilteredArray(member: member)
                }
            }
            
            
            if memberMus != nil {
                for rating in arrayOfMusicRatingsToFilter {//check music rating
                    if memberMus == rating {
                        addMusic = true
                    }
                }
            } else {
                // are we checking for no rating?
                if arrayOfMusicRatingsToFilter.contains(0) {
                    addMemberToFilteredArray(member: member)
                }
            }
            
            if addMusic && addVisual {
                addMemberToFilteredArray(member: member)
            }
        }
        
        
//        //VISUAL
//        if !arrayOfVisualRatingsToFilter.isEmpty {
//            if let memberVisualRating = member["visualRating"] as? Int {
//                for rating in arrayOfVisualRatingsToFilter {
//                    print("checking for rating of visual \(rating)")
//                    if memberVisualRating == rating {
//                        print("match visual \(rating) - \(memberVisualRating)")
//                        addMemberToFilteredArray(member: member)
//                    }
//                }
//            } else { // member does not have a rating, are we searching for No ratings?
//                if arrayOfVisualRatingsToFilter.contains(0) {
//                    addMemberToFilteredArray(member: member)
//                }
//            }
//        } else {
//            addMemberToFilteredArray(member: member)
//        }
//        
//        //MUSIC
//        if !arrayOfMusicRatingsToFilter.isEmpty {
//            if let memberMusicRating = member["musicRating"] as? Int {
//                for rating in arrayOfMusicRatingsToFilter {
//                    if memberMusicRating == rating {
//                        addMemberToFilteredArray(member: member)
//                    }
//                }
//            } else { // member does not have a rating, are we searching for No ratings?
//                if arrayOfMusicRatingsToFilter.contains(0) {
//                    addMemberToFilteredArray(member: member)
//                }
//            }
//        } else {
//            addMemberToFilteredArray(member: member)
//        }
    }
    
    func addMemberToFilteredArray(member: PFObject) {
        
        //check veteran rating first
        if checkVets.state == NSOnState {
            let cVet = member["cadetsVet"] as? Bool ?? nil
            let c2Vet = member["cadets2Vet"] as? Bool ?? nil
            
            if cVet == true || c2Vet == true {
                //vet
            } else {
                //no vet
                return
            }
        }
        
        checkContractThenAdd(member: member)
    }
    
    func checkContractThenAdd(member: PFObject) {
        
        //check if contact is filtered, then add
        if checkContract.state == NSOnState {
            let contract = member["contract"] as? Bool ?? nil
            if contract == true {
                
            } else {
                return
            }
        }

        //make sure they don't exist in filtered array, then add
        if !(arrayOfFilteredMembers?.contains(member))! {
            arrayOfFilteredMembers?.append(member)
        }
        tableMembers.reloadData()
    }
    
    // END CHECK FILTERS
    
    func searchMembers() {
        arrayOfFilteredMembers?.removeAll()
        lblResults.stringValue = ""
        
        if arrayOfAllMembers == nil || arrayOfAllMembers?.count == 0 {
            return
        }
        
        for member in arrayOfAllMembers! {
            
            //Corps
            var isCadets: Bool?
            var isCadets2: Bool?
            
            if checkAllMembers.state == NSOnState {
                
                checkForInstrument(member: member)
                
            } else if checkCadets.state == NSOnState {
                
                if switchCorps.doubleValue == 0.0 { //SEARCHING BY AUDITON
                    
                    isCadets = member["cadets"] as? Bool ?? false
                    isCadets2 = member["cadets2"] as? Bool ?? false
                    if isCadets! && !isCadets2! {
                        
                        //we have a member matching the corps filter
                        
                        //do they match the selected instruments?
                        checkForInstrument(member: member)
                        
                    }
                    
                } else if switchCorps.doubleValue == 1.0 { //SEARCHING BY ASSIGNED
                    let corps = member["corps"] as? Int ?? nil
                    if corps == 1 {
                        checkForInstrument(member: member)
                    }
                }
                
            } else if checkCadets2.state == NSOnState {
                
                if switchCorps.doubleValue == 0.0 { //SEARCHING BY AUDITON
                    
                    isCadets = member["cadets"] as? Bool ?? false
                    isCadets2 = member["cadets2"] as? Bool ?? false
                    if isCadets2! && !isCadets! {
                        
                        //we have a member matching the corps filter
                        
                        //do they match the selected instruments?
                        checkForInstrument(member: member)
                        
                    }
                    
                } else if switchCorps.doubleValue == 1.0 { //SEARCHING BY ASSIGNED
                    let corps = member["corps"] as? Int ?? nil
                    if corps == 2 {
                        checkForInstrument(member: member)
                    }
                }

                
            } else if checkCadetsBoth.state == NSOnState {
             
                // This is disabled if switchCorps == 1.0 ie. searching by Assigned
                // Member cannot be asssigned to BOTH.
                if switchCorps.doubleValue == 0.0 {
                    
                    isCadets = member["cadets"] as? Bool ?? false
                    isCadets2 = member["cadets2"] as? Bool ?? false
                    if isCadets! && isCadets2! {
                        
                        //we have a member matching the corps filter
                        
                        //do they match the selected instruments?
                        checkForInstrument(member: member)
                        
                    }
                    
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
    
    @IBAction func checkVets_click(_ sender: NSButton) {
        searchMembers()
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
        
        if tableColumn == tableView.tableColumns[1] { // VET
            let cVet = member["cadetsVet"] as? Bool ?? nil
            let c2Vet = member["cadets2Vet"] as? Bool ?? nil
            
            if cVet == true || c2Vet == true {
                image = NSImage(named: "Check")
            } else {
                image = nil
            }
            
            cellIdentifier = "cellVeteran"
        }
        
        if tableColumn == tableView.tableColumns[2] { // NAME
            text = member["name"] as? String ?? ""
            cellIdentifier = "cellName"
        }
        
        if tableColumn == tableView.tableColumns[3] { // AGE
            let dob = member["dob"] as! Date
            let now = Date()
            let calendar = Calendar.current
            let ageComponents = calendar.dateComponents([.year], from: dob, to: now)
            let age = ageComponents.year!
            text = "\(age)"
            cellIdentifier = "cellAge"
        }
        
        else if tableColumn == tableView.tableColumns[4] { // CADETS LOGO
            let C = member["cadets"] as! Bool
            if C {
                image = NSImage(named: "Cadets")
            }
            cellIdentifier = "cellAuditioningForCadets"
        }
        
        else if tableColumn == tableView.tableColumns[5] { // CADETS2 LOGO
            let C2 = member["cadets2"] as! Bool
            if C2 {
                image = NSImage(named: "Cadets2")
            }
            cellIdentifier = "cellAuditioningForCadets2"
        }
        
        else if tableColumn == tableView.tableColumns[6] { // SECTION
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
            
        else if tableColumn == tableView.tableColumns[7] { // VISUAL RATING
            if let rating = member["visualRating"] as! Int? {
                text = "\(rating)"
            } else {
                text = ""
            }
            cellIdentifier = "cellVisualRating"
        }
            
        else if tableColumn == tableView.tableColumns[8] { // MUSIC RATING
            if let rating = member["musicRating"] as! Int? {
                text = "\(rating)"
            } else {
                text = ""
            }
            cellIdentifier = "cellMusicRating"
        }
        
        else if tableColumn == tableView.tableColumns[9] { // PICTURE
            text = ""
            if let _ = member["picture"] as? PFFile {
                image = NSImage(named: "Picture")
            } else {
                image = nil
            }
            cellIdentifier = "cellPicture"
        }
        
        else if tableColumn == tableView.tableColumns[10] { // MULTIPLE AUDITIONS
            text = ""
            let multiple = member["multiple"] as? Bool ?? false
            if multiple {
                image = NSImage(named: "Multiple")
            } else {
                image = nil
            }
            cellIdentifier = "cellMultiple"
        }
        
        else if tableColumn == tableView.tableColumns[11] { // RECOMMEND
            if let recommendedCorps = member["corps"] as? Int {
                if recommendedCorps == 1 {
                    image = NSImage(named: "Cadets")
                } else if recommendedCorps == 2 {
                    image = NSImage(named: "Cadets2")
                }
            } else {
                image = nil
            }
            
            cellIdentifier = "cellCorps"
        }
        
            
        else if tableColumn == tableView.tableColumns[12] { // POSITION
            if let position = member["position"] as! String? {
                text = position
            } else {
                text = ""
            }
            cellIdentifier = "cellPosition"
        }
        
        if tableColumn == tableView.tableColumns[13] { // CONTRACT
            let contract = member["contract"] as? Bool ?? nil
            
            if contract == true {
                image = NSImage(named: "Contract")
            } else {
                image = nil
            }
            
            cellIdentifier = "cellContract"
        }
        
        
        // 3
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            cell.imageView?.image = image ?? nil
            
            cell.textField?.font = NSFont(name: "PT Sans", size: NSFont.systemFontSize())
            
            return cell
            
        } else {
            print("no \(cellIdentifier)")
        }
        return nil
        
    }
    @IBAction func click(_ sender: Any) {
        // 1
        guard tableMembers.selectedRow >= 0 , let member = arrayOfFilteredMembers?[tableMembers.selectedRow] else {
            return
        }
        memberToOpen = member
    }
    
    @IBAction func doubleClick(_ sender: Any) {
        // 1
        guard tableMembers.selectedRow >= 0 , let member = arrayOfFilteredMembers?[tableMembers.selectedRow] else {
            return
        }
        memberToOpen = member
        self.performSegue(withIdentifier: "profile", sender: self)
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
//        arrayOfFilteredMembers.sort
//        var songsAsMutableArray = NSMutableArray(array: arrayOfFilteredMembers!)
//        songsAsMutableArray.sort(using: tableView.sortDescriptors)
//        arrayOfFilteredMembers = songsAsMutableArray
//        tableView.reloadData()
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
                vc.arrayOfFilteredMembers = arrayOfFilteredMembers
                vc.tableParent = tableMembers
            }
        }
    }
    
    
    @IBAction func btnUpload_click(_ sender: NSButton) {
        let answer = dialogOKCancel(question: "Upload Profiles", text: "Are you sure you want to upload new user profiles?")
        if answer {
            load()
        }
    }
    
    @IBAction func btnMail_click(_ sender: NSButton) {
        
        var toEmail = ""
        
        if arrayOfFilteredMembers?.count == 1 {
            let member = arrayOfFilteredMembers?.first
            if let email = member?["email"] as? String {
                toEmail = email
            }
        } else if (arrayOfFilteredMembers?.count)! > 1 {
            for member in arrayOfFilteredMembers! {
                if let email = member["email"] as? String {
                    toEmail += email
                    if member != arrayOfFilteredMembers?.last {
                        toEmail += ","
                    }
                }
            }
        }

        let urlString = "mailto:\(toEmail)"
        
        if let url = URL(string: urlString) {
            NSWorkspace.shared().open(url)
        }
    }
    
    func load() {
        var count = 0
        
        let path = "/Users/JMoore/Downloads/AuditionProfile_Data.csv"
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
    
    func popoverDidClose(_ notification: Notification) {
        tableMembers.reloadData()
    }
    
    
}
