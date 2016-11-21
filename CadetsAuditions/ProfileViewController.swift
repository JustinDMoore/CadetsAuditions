//
//  ProfileViewController.swift
//  CadetsAuditions
//
//  Created by Justin Moore on 11/9/16.
//  Copyright © 2016 Justin Moore. All rights reserved.
//

import Cocoa
import Parse
import AVFoundation

class ProfileViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSPopoverDelegate {
    
    var arrayOfFilteredMembers: [PFObject]?
    var arrayOfNotes: [PFObject]?
    var member: PFObject? = nil
    var tableParent: NSTableView? = nil
    
    let session = AVCaptureSession()
    let video_connection = AVCaptureConnection()
    let still_image_output = AVCaptureStillImageOutput()
    
    @IBOutlet weak var imgPicture: NSImageView!

    @IBOutlet weak var lblAge: NSTextField!
    @IBOutlet weak var btnEmail: NSButton!
    @IBOutlet weak var lblSections: NSTextField!
    @IBOutlet weak var imgCorps: NSImageView!
    @IBOutlet weak var lblName: NSTextField!
    @IBOutlet weak var lblNumber: NSTextField!
    @IBOutlet weak var tableNotes: NSTableView!
    @IBOutlet weak var lblPhone: NSTextField!
    @IBOutlet weak var lblSchool: NSTextField!
    @IBOutlet weak var lblDecember: NSTextField!
    @IBOutlet weak var lblMarchingYears: NSTextField!
    @IBOutlet weak var lblPriorDC: NSTextField!
    @IBOutlet weak var lblPriorDCName: NSTextField!
    @IBOutlet weak var lblIndoorPerc: NSTextField!
    @IBOutlet weak var lblIndoorPercName: NSTextField!
    @IBOutlet weak var lblPriorDance: NSTextField!
    @IBOutlet weak var lblPriorDanceYears: NSTextField!
    @IBOutlet weak var lblWinterGuard: NSTextField!
    @IBOutlet weak var lblWinterGuardName: NSTextField!
    @IBOutlet weak var lblInstructors: NSTextField!
    @IBOutlet weak var lblFinancialObligations: NSTextField!
    @IBOutlet weak var lblFinancialPlan: NSTextField!
    @IBOutlet weak var lblMedical: NSTextField!
    @IBOutlet weak var lblGoals: NSTextField!
    
    @IBOutlet weak var lblMultiple: NSTextField!
    
    @IBOutlet weak var btnNext: NSButton!
    @IBOutlet weak var btnPrevious: NSButton!

    @IBOutlet weak var imgRatingVisual: NSImageView!
    @IBOutlet weak var imgRatingMusic: NSImageView!

    @IBOutlet weak var viewNote: NSBox!
    @IBOutlet weak var txtNote: NSTextField!
    @IBOutlet weak var btnCancelNote: NSButton!
    @IBOutlet weak var btnSaveNote: NSButton!
    
    @IBOutlet weak var txtSetNumber: NSTextField!
    @IBOutlet weak var btnSaveNumber: NSButton!
    @IBOutlet weak var progressWheel: NSProgressIndicator!
    
    @IBOutlet weak var imgRecommended: NSImageView!
    
    @IBOutlet weak var checkCadetsVet: NSButton!
    @IBOutlet weak var checkCadets2Vet: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewNote.isHidden = true
        tableNotes.delegate = self
        tableNotes.dataSource = self
        imgPicture.image = nil
        loadProfile()
    }

    @IBAction func btnRecommendCorps(_ sender: NSButton) {
        switch sender.tag {
        case 0:
            member?.remove(forKey: "corps")
            member?.saveEventually()
            imgRecommended.image = NSImage(named: "Question")
        case 1:
            member?["corps"] = sender.tag
            member?.saveEventually()
            imgRecommended.image = NSImage(named: "Cadets")
        case 2:
            member?["corps"] = sender.tag
            member?.saveEventually()
            imgRecommended.image = NSImage(named: "Cadets2")
        default:
            print("Error")
        }
    }
 
    @IBAction func checkVet_clicked(_ sender: NSButton) {
        if sender.tag == 1 {
            if sender.state == NSOnState {
                member?["cadetsVet"] = true
                member?.saveEventually()
            } else {
                member?["cadetsVet"] = false
            }
        } else if sender.tag == 2 {
            if sender.state == NSOnState {
                member?["cadets2Vet"] = true
                member?.saveEventually()
            } else {
                member?["cadets2Vet"] = false
            }
        }
    }
    
    
    @IBAction func email(_ sender: NSButton) {
        if sender.stringValue.characters.count > 0 {
            openMailApp()
        }
    }
    
    func openMailApp() {
        
        let toEmail = member?["email"]
        let urlString = "mailto:\(toEmail!)"
        
        if let url = URL(string: urlString) {
            print(toEmail!)
            NSWorkspace.shared().open(url)
        }
    }
    
    @IBAction func deleteNOte(_ sender: Any) {
        selectedNote?.deleteInBackground(block: { (done: Bool, err: Error?) in
            self.btnCancelNote_clicked(self)
            self.tableNotes.reloadData()
        })
    }
    
    @IBAction func updateNote(_ sender: Any) {
        selectedNote?["note"] = txtNote.stringValue
        selectedNote?.saveEventually({ (done: Bool, err: Error?) in
            self.btnCancelNote_clicked(self)
            self.tableNotes.reloadData()
        })
    }
    
    
    func loadNotes() {
        arrayOfNotes?.removeAll()
        let query = PFQuery(className: "MemberNotes")
        query.limit = 1000
        query.whereKey("member", equalTo: member!)
        query.findObjectsInBackground { (notes: [PFObject]?, err: Error?) in
            if notes != nil {
                self.arrayOfNotes = notes!
                self.tableNotes.reloadData()
            }
        }
    }
    
    func loadProfile() {
        
        if let imageFile = member?["picture"] as? PFFile {
            imgPicture.image = nil
            progressWheel.isHidden = false
            progressWheel.startAnimation(self)
            imageFile.getDataInBackground(block: { (data: Data?, err: Error?) in
                if data != nil {
                    self.progressWheel.stopAnimation(self)
                    self.progressWheel.isHidden = true
                    self.imgPicture.image = NSImage(data: data!)
                }
            })
        } else {
            imgPicture.image = NSImage(named: "Picture")
            progressWheel.stopAnimation(self)
            progressWheel.isHidden = true
        }
        
        if let cadetsVet = member?["cadetsVet"] as? Bool {
            if cadetsVet {
                checkCadetsVet.state = NSOnState
            } else {
                checkCadetsVet.state = NSOffState
            }
        } else {
            checkCadetsVet.state = NSOffState
        }
        
        if let cadets2Vet = member?["cadets2Vet"] as? Bool {
            if cadets2Vet {
                checkCadets2Vet.state = NSOnState
            } else {
                checkCadets2Vet.state = NSOffState
            }
        } else {
            checkCadets2Vet.state = NSOffState
        }

        
        let multiple = member?["multiple"] as? Bool ?? false
        if multiple {
            lblMultiple.isHidden = false
        } else {
            lblMultiple.isHidden = true
        }
        
        loadNotes()
        checkIndexForButtons()
        loadRating()
        
        //number
        if let number = member?["number"] as? Int {
            lblNumber.stringValue = "\(number)"
        } else {
            lblNumber.stringValue = "No #"
        }
        
        //age
        let dob = member?["dob"] as! Date
        let now = Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dob, to: now)
        let age = ageComponents.year!
        lblAge.stringValue = "\(age) Years Old"
        
        lblName.stringValue = member?["name"] as? String ?? "Error"
        btnEmail.title = member?["email"] as? String ?? "Error"
        lblPhone.stringValue = member?["phone"] as? String ?? "Error"
        lblSchool.stringValue = member?["school"] as? String ?? "No School Affiliation"
        
        let cadets = member?["cadets"] as! Bool
        let cadets2 = member?["cadets2"] as! Bool
        if cadets && !cadets2 {
            imgCorps.image = NSImage(named: "Cadets")
        } else if !cadets && cadets2 {
            imgCorps.image = NSImage(named: "Cadets2")
        } else if cadets && cadets2 {
            imgCorps.image = NSImage(named: "CadetsCadets2")
        }
        
        if let corps = member?["corps"] as? Int {
            if corps == 1 {
                imgRecommended.image = NSImage(named: "Cadets")
            } else if corps == 2 {
                imgRecommended.image = NSImage(named: "Cadets2")
            }
        } else {
            imgRecommended.image = NSImage(named: "Question")
        }
        
        //sections
        if let arrayOfInstruments = member?["sections"] as! [String]? {
            var strInstruments = ""
            if arrayOfInstruments.count > 1 {
                for instrument in arrayOfInstruments {
                    strInstruments += instrument + "    "
                }
            } else if arrayOfInstruments.count == 1 {
                strInstruments = arrayOfInstruments.first!
            }
            
            lblSections.stringValue = strInstruments
        }
        
        //december
        if let dec = member?["december"] as? Bool {
            if !dec {
                var reason = member!["whyDecember"] as? String ?? "No Reason Given"
                if reason == "" {
                    reason = "No Reason Given"
                }
                lblDecember.stringValue = "I cannot come to the December Camp" + "\n \n \(reason)"
            } else {
                lblDecember.stringValue = "I can come to the December Camp"
            }
        } else {
            lblDecember.stringValue = "N/A"
        }
        
        //experience
        if let marchingYears = member?["marchingYears"] as? String {
            lblMarchingYears.stringValue = marchingYears + " Years"
        } else {
            lblMarchingYears.stringValue = "Unknown Years"
        }
        
        if let marchedCorps = member?["marchedCorps"] as? Bool {
            if marchedCorps {
                lblPriorDC.stringValue = "Yes"
            } else {
                lblPriorDC.stringValue = "No"
            }
        } else {
            lblPriorDC.stringValue = ""
        }
        
        if let priorCorpsName = member?["otherCorps"] as? String {
            lblPriorDCName.stringValue = priorCorpsName
        } else {
            lblPriorDCName.stringValue = ""
        }
        
        if let priorPerc = member?["marchedPerc"] as? Bool {
            if priorPerc {
                lblIndoorPerc.stringValue = "Yes"
            } else {
                lblIndoorPerc.stringValue = "No"
            }
        } else {
            lblIndoorPerc.stringValue = ""
        }
        
        if let priorPercName = member?["otherPerc"] as? String {
            if priorPercName.characters.count > 1 {
                lblIndoorPercName.stringValue = priorPercName
            } else {
                lblIndoorPercName.stringValue = ""
            }
        } else {
            lblIndoorPercName.stringValue = ""
        }
        
        if let priorDance = member?["prevDance"] as? Bool {
            if priorDance {
                lblPriorDance.stringValue = "Yes"
            } else {
                lblPriorDance.stringValue = "No"
            }
        } else {
            lblPriorDance.stringValue = "No Answer"
        }
        
        if let priorDanceYears = member?["yearsDance"] as? String {
            if priorDanceYears.characters.count > 0 {
                lblPriorDanceYears.stringValue = priorDanceYears + " Years"
            } else {
                lblPriorDanceYears.stringValue = ""
            }
        }
        
        if let priorGuard = member?["marchedGuard"] as? Bool {
            if priorGuard {
                lblWinterGuard.stringValue = "Yes"
            } else {
                lblWinterGuard.stringValue = "No"
            }
        } else {
            lblWinterGuard.stringValue = ""
        }
        
        if let priorGuardName = member?["otherGuard"] as? String {
            if priorGuardName.characters.count > 1 {
                lblWinterGuardName.stringValue = priorGuardName
            } else {
                lblWinterGuardName.stringValue = ""
            }
        } else {
            lblWinterGuardName.stringValue = ""
        }
        
        if let instructors = member?["prevInstructors"] as? String {
            lblInstructors.stringValue = instructors
        } else {
            lblInstructors.stringValue = "None listed"
        }
        
        let moneyQuestion = " - \(member?["questionMoney"] as? String ?? "")"
        if let financial = member?["understandMoney"] as? Bool {
            if financial {
                lblFinancialObligations.stringValue = "Yes I understand" + moneyQuestion
            } else {
                lblFinancialObligations.stringValue = "No I don't understand" + moneyQuestion
            }
        } else {
            lblFinancialObligations.stringValue = "Did not answer" + moneyQuestion
        }
        
        if let plan = member?["planMoney"] as? String {
            lblFinancialPlan.stringValue = plan
        } else {
            lblFinancialPlan.stringValue = "Did not answer"
        }
        
        if let medical = member?["medical"] as? String {
            lblMedical.stringValue = medical
        } else {
            lblMedical.stringValue = "Did not answer"
        }
        
        if let goals = member?["goals"] as? String {
            lblGoals.stringValue = goals
        } else {
            lblGoals.stringValue = "Did not answer"
        }
        
        //set tooltips
        lblName.toolTip = lblName.stringValue
        btnEmail.toolTip = btnEmail.stringValue
        lblSchool.toolTip = lblSchool.stringValue
        lblDecember.toolTip = lblDecember.stringValue
        
        lblPriorDCName.toolTip = lblPriorDCName.stringValue
        lblIndoorPercName.toolTip = lblIndoorPercName.stringValue
        lblWinterGuardName.toolTip = lblWinterGuardName.stringValue
        lblInstructors.toolTip = lblInstructors.stringValue
        
        lblFinancialObligations.toolTip = lblFinancialObligations.stringValue
        lblFinancialPlan.toolTip = lblFinancialPlan.stringValue
        lblMedical.toolTip = lblMedical.stringValue
        lblGoals.toolTip = lblGoals.stringValue
   }
    
    @IBAction func btnVisualRating_click(_ sender: NSButton) {
        if sender.tag == 0 {
            member?.remove(forKey: "visualRating")
            member?.saveEventually()
            imgRatingVisual.image = NSImage(named: "DeleteRating")
        } else {
            member?.setObject(sender.tag, forKey: "visualRating")
            member?.saveEventually()
        }
        loadRating()
    }

    @IBAction func btnMusicRating_click(_ sender: NSButton) {
        if sender.tag == 0 {
            member?.remove(forKey: "musicRating")
            member?.saveEventually()
            imgRatingMusic.image = NSImage(named: "DeleteRating")
        } else {
            member?.setObject(sender.tag, forKey: "musicRating")
            member?.saveEventually()
        }
        loadRating()
    }
  
    func loadRating() {
        if let musicRating = member?["musicRating"] as? Int {
            switch musicRating {
            case 1:
               imgRatingMusic.image = NSImage(named: "1")
            case 2:
                imgRatingMusic.image = NSImage(named: "2")
            case 3:
                imgRatingMusic.image = NSImage(named: "3")
            default: imgRatingMusic.image = NSImage(named: "Question")
            }
        } else {
            imgRatingMusic.image = NSImage(named: "Question")
        }
        
        if let visualRating = member?["visualRating"] as? Int {
            switch visualRating {
            case 1:
                imgRatingVisual.image = NSImage(named: "1")
            case 2:
                imgRatingVisual.image = NSImage(named: "2")
            case 3:
                imgRatingVisual.image = NSImage(named: "3")
            default: imgRatingVisual.image = NSImage(named: "Question")
            }
        } else {
            imgRatingVisual.image = NSImage(named: "Question")
        }
    }
    
    //MARK:-
    //MARK:TABLE VIEW
    //MARK:-
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if arrayOfNotes?.count != nil {
            return arrayOfNotes!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var image:NSImage?
        var text:String = ""
        var cellIdentifier: String = ""
        
        guard let note = arrayOfNotes?[row] else {
            return nil
        }
        
        if tableColumn == tableView.tableColumns[1] { // DATE
            let date = note.createdAt! as Date
            let dateFormatter = DateFormatter()
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            dateFormatter.dateFormat = "MM-dd-yy hh:mm a"
            text = dateFormatter.string(from: date)
            cellIdentifier = "cellDate"
        }
        
        if tableColumn == tableView.tableColumns[0] { // NOTE
            text = note["note"] as? String ?? ""
            cellIdentifier = "cellNote"
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
    
    func tableView(_ tableView: NSTableView, shouldShowCellExpansionFor tableColumn: NSTableColumn?, row: Int) -> Bool {
        return true
    }
    
    func tableView(_ tableView: NSTableView, toolTipFor cell: NSCell, rect: NSRectPointer, tableColumn: NSTableColumn?, row: Int, mouseLocation: NSPoint) -> String {
        return "test"
    }

    func tableView(_ tableView: NSTableView, shouldTrackCell cell: NSCell, for tableColumn: NSTableColumn?, row: Int) -> Bool {
        return true
    }
    
    func tableView(_ tableView: NSTableView, willDisplayCell cell: Any, for tableColumn: NSTableColumn?, row: Int) {
        print("display")
    }
    
    @IBAction func btnNext(_ sender: Any) {
        let index = getInexOfMember() + 1
        member = arrayOfFilteredMembers?[index]
        loadProfile()
    }
    
    @IBAction func btnPrevious(_ sender: Any) {
        let index = getInexOfMember() - 1
        member = arrayOfFilteredMembers?[index]
        loadProfile()
    }
    
    func checkIndexForButtons() {
        let index = arrayOfFilteredMembers!.index(of: member!)!
        if index >= (arrayOfFilteredMembers?.count)! - 1 {
            btnNext.isHidden = true
        } else {
            btnNext.isHidden = false
        }
        
        if index <= 0 {
            btnPrevious.isHidden = true
        } else {
            btnPrevious.isHidden = false
        }
    }
    
    func getInexOfMember() -> Int {
        if member != nil && arrayOfFilteredMembers != nil {
            return arrayOfFilteredMembers!.index(of: member!)!
        } else {
            return 0
        }
    }
    
    @IBAction func btnClose_clicked(_ sender: Any) {
        self.dismiss(nil)
        tableParent?.reloadData()
    }
    
    func popoverDidClose(_ notification: Notification) {
        tableParent?.reloadData()
    }
    
    @IBAction func btnNote_click(_ sender: Any) {
        viewNote.isHidden = false
        btnSaveNote.isHidden = false
        txtNote.becomeFirstResponder()
    }
    
    @IBAction func btnCancelNote_clicked(_ sender: Any) {
        txtNote.stringValue = ""
        viewNote.isHidden = true
    }
    
    @IBAction func btnSave_clicked(_ sender: Any) {
        let newNote = PFObject(className: "MemberNotes")
        newNote["note"] = txtNote.stringValue
        newNote.setObject(member!, forKey: "member")
        newNote.saveEventually { (done: Bool, err: Error?) in
            if done {
                self.arrayOfNotes?.append(newNote)
                self.tableNotes.reloadData()
            }
        }
        btnCancelNote_clicked(self)
    }
    
    @IBAction func btnNumber_click(_ sender: Any) {
        if txtSetNumber.isHidden {
            txtSetNumber.isHidden = false
            btnSaveNumber.isHidden = false
            txtSetNumber.becomeFirstResponder()
        } else {
            txtSetNumber.isHidden = true
            btnSaveNumber.isHidden = true
            txtSetNumber.resignFirstResponder()
        }
    }
    
    @IBAction func btnSaveNumber_clicked(_ sender: Any) {
        saveNumber()
    }
    
    func saveNumber() {
        txtSetNumber.isHidden = true
        btnSaveNumber.isHidden = true
        member?["number"] = Int(txtSetNumber.stringValue)
        lblNumber.stringValue = txtSetNumber.stringValue
        member?.saveEventually()
        txtSetNumber.stringValue = ""
    }
    
    var selectedNote: PFObject?
    @IBAction func doubleClick(_ sender: Any) {
        // 1
        guard tableNotes.selectedRow >= 0 , let note = arrayOfNotes?[tableNotes.selectedRow] else {
            return
        }
        btnNote_click(self)
        btnSaveNote.isHidden = true
        txtNote.stringValue = note["note"] as! String
        selectedNote = note
    }
    
    @IBAction func saveNumber(_ sender: NSTextField) {
        saveNumber()
    }
    
 
}


