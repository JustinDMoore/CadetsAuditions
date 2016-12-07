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

class ProfileViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSPopoverDelegate, NSComboBoxDelegate {
    
    var arrayOfFilteredMembers: [PFObject]?
    var arrayOfNotes: [PFObject]?
    var member: PFObject? = nil
    var tableParent: NSTableView? = nil
    var arrayOfLeaderPositions: [PFObject]?
    var arrayOfSectionPositions: [PFObject]?
    var initialMemberIndex: Int?
    
    let session = AVCaptureSession()
    let video_connection = AVCaptureConnection()
    let still_image_output = AVCaptureStillImageOutput()
    
    @IBOutlet weak var imgPicture: NSImageView!

    @IBOutlet weak var lblMemberCount: NSTextField!
    @IBOutlet weak var lblAge: NSTextField!
    @IBOutlet weak var btnEmail: NSButton!
    @IBOutlet weak var lblSections: NSTextField!
    @IBOutlet weak var imgCorps: NSImageView!
    @IBOutlet weak var lblName: NSTextField!
    @IBOutlet weak var btnNumber: NSButton!
    @IBOutlet weak var tableNotes: NSTableView!
    @IBOutlet weak var tableFilteredMembers: NSTableView!
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
    @IBOutlet weak var checkContract: NSButton!
    
    @IBOutlet weak var checkLeader: NSButton!
    @IBOutlet weak var comboLeader: NSComboBox!
    @IBOutlet weak var comboPosition: NSComboBox!
    
    @IBOutlet weak var lblMultiple: NSTextField!
    
    @IBOutlet weak var btnNext: NSButton!
    @IBOutlet weak var btnPrevious: NSButton!

    @IBOutlet weak var imgRatingVisual: NSImageView!
    @IBOutlet weak var imgRatingMusic: NSImageView!

    @IBOutlet weak var txtNote: NSTextField!

    @IBOutlet weak var progressWheel: NSProgressIndicator!
    
    @IBOutlet weak var imgRecommended: NSImageView!
    
    @IBOutlet weak var checkCadetsVet: NSButton!
    @IBOutlet weak var checkCadets2Vet: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        comboLeader.delegate = self
        comboLeader.isEditable = false
        comboPosition.delegate = self
        comboPosition.isEditable = false
        
        tableNotes.delegate = self
        tableNotes.dataSource = self
        tableFilteredMembers.delegate = self
        tableFilteredMembers.dataSource = self
        imgPicture.image = nil
        loadProfile()
        let indexSet = NSIndexSet(index: initialMemberIndex!)
        tableFilteredMembers.selectRowIndexes(indexSet as IndexSet, byExtendingSelection: false)
        
        comboLeader.removeAllItems()
        if arrayOfLeaderPositions != nil {
            for pos in arrayOfLeaderPositions! {
                comboLeader.addItem(withObjectValue: pos["Position"])
            }
        }
        
        comboPosition.removeAllItems()
        if arrayOfSectionPositions != nil {
            for pos in arrayOfSectionPositions! {
                comboPosition.addItem(withObjectValue: "\(pos["Section"]!) - \(pos["Position"]!)")
            }
        }
        
        txtNote.drawsBackground = false
        txtNote.isBezeled = false
        lblMemberCount.stringValue = "\(arrayOfFilteredMembers!.count) members"
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
                member?.saveEventually()
            }
        } else if sender.tag == 2 {
            if sender.state == NSOnState {
                member?["cadets2Vet"] = true
                member?.saveEventually()
            } else {
                member?["cadets2Vet"] = false
                member?.saveEventually()
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
    
    @IBAction func deleteNOte(_ sender: NSButton) {
        if selectedNote == nil {
            let msg = NSAlert()
            msg.addButton(withTitle: "OK")      // 1st button
            msg.messageText = "Delete Note"
            msg.informativeText = "Select a note to delete."

            msg.runModal()

        } else {
            let msg = NSAlert()
            msg.addButton(withTitle: "Yes")      // 1st button
            msg.addButton(withTitle: "Cancel")  // 2nd button
            msg.messageText = "Delete Note"
            msg.informativeText = "Are you sure you want to delete this note?"
   
            let response: NSModalResponse = msg.runModal()
            
            if (response == NSAlertFirstButtonReturn) {

                selectedNote?.deleteInBackground(block: { (done: Bool, err: Error?) in
                    self.arrayOfNotes?.remove(at: self.tableNotes.selectedRow)
                    self.tableNotes.reloadData()
                })
                
            } else {
                return
            }
        }
    }
    
    func loadNotes() {
        arrayOfNotes?.removeAll()
        let query = PFQuery(className: "MemberNotes")
        query.limit = 1000
        query.includeKey("staff")
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
            btnNumber.title = "\(number)"
        } else {
            btnNumber.title = "No #"
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
        
        if let leaderPos = member?["leaderPosition"] as? String {
            comboLeader.stringValue = leaderPos
        }
        
        if let position = member?["position"] as? String {
            comboPosition.stringValue = position
        }
        
        if let leader = member?["leader"] as? Bool {
            if leader {
                checkLeader.state = NSOnState
                comboLeader.isEnabled = true
            } else {
                checkLeader.state = NSOffState
                comboLeader.isEnabled = false
                comboLeader.stringValue = ""
            }
        } else {
            checkLeader.state = NSOffState
            comboLeader.isEnabled = false
        }
        
        if let contract = member?["contract"] as? Bool {
            if contract {
                checkContract.state = NSOnState
            } else {
                checkContract.state = NSOffState
            }
        } else {
            checkContract.state = NSOffState
            checkContract.isEnabled = false
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
        if tableView == tableNotes {
            if arrayOfNotes?.count != nil {
                return arrayOfNotes!.count
            } else {
                return 0
            }
        } else if tableView == tableFilteredMembers {
            if arrayOfFilteredMembers?.count != nil {
                return arrayOfFilteredMembers!.count
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if tableView == tableNotes {
            return noteView(tableView, viewFor: tableColumn, row: row)
        } else if tableView == tableFilteredMembers {
            return memberView(tableView, viewFor: tableColumn, row: row)
        } else {
            return nil
        }
    }

    func memberView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text:String = ""
        var cellIdentifier: String = ""
        
        guard let member = arrayOfFilteredMembers?[row] else {
            return nil
        }
        
        if tableColumn == tableView.tableColumns[0] { // MEMBER
            let str = "\(member["number"] ?? "") - \(member["name"] ?? "")"
            text = str
            cellIdentifier = "cellMember"
        }
        
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        } else {
            print("no \(cellIdentifier)")
        }
        return nil
    }
    
    func noteView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text:String = ""
        var cellIdentifier: String = ""
        
        guard let note = arrayOfNotes?[row] else {
            return nil
        }
        
        if tableColumn == tableView.tableColumns[2] { // DATE
            let date = note.createdAt! as Date
            let dateFormatter = DateFormatter()
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            dateFormatter.dateFormat = "MM-dd-yy hh:mm a"
            text = dateFormatter.string(from: date)
            cellIdentifier = "cellDate"
        }

        
        if tableColumn == tableView.tableColumns[1] { // STAFF
            if let staff = note["staff"] as? PFObject {
                text = staff["fullname"] as? String ?? ""
            } else {
                text = "Unknown"
            }
            cellIdentifier = "cellStaff"
        }
        
        
        if tableColumn == tableView.tableColumns[0] { // NOTE
            text = note["note"] as? String ?? ""
            cellIdentifier = "cellNote"
        }
        
        // 3
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        } else {
            print("no \(cellIdentifier)")
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, shouldShowCellExpansionFor tableColumn: NSTableColumn?, row: Int) -> Bool {
        return true
    }
    
    func tableView(_ tableView: NSTableView, shouldTrackCell cell: NSCell, for tableColumn: NSTableColumn?, row: Int) -> Bool {
        return true
    }
    
    func tableView(_ tableView: NSTableView, willDisplayCell cell: Any, for tableColumn: NSTableColumn?, row: Int) {
        
        if tableView.selectedRowIndexes.contains(row) {
            if let c = cell as? NSCell {
                c.controlView?.layer?.backgroundColor = NSColor.red.cgColor
            }
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        if tableView == tableNotes {
            if let note = arrayOfNotes?[row] {
                
                let string = note["note"] as! String
                
                let someWidth: CGFloat = tableView.frame.size.width
                let stringAttributes = [NSFontAttributeName: NSFont.systemFont(ofSize: 12)] //change to font/size u are using
                let attrString: NSAttributedString = NSAttributedString(string: string, attributes: stringAttributes)
                let frame: NSRect = NSMakeRect(0, 0, someWidth, CGFloat.greatestFiniteMagnitude)
                let tv: NSTextView = NSTextView(frame: frame)
                tv.textStorage?.setAttributedString(attrString)
                tv.isHorizontallyResizable = false
                tv.sizeToFit()
                let height: CGFloat = tv.frame.size.height + 20 // + other objects...
                
                return height
                
            }
        }
        
        return 22 //Fail
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let myCustomView = CustomRow()
        return myCustomView
    }
    
    @IBAction func btnNext(_ sender: NSButton) {
        let index = getInexOfMember() + 1
        member = arrayOfFilteredMembers?[index]
        loadProfile()
        let indexSet = NSIndexSet(index: index)
        tableFilteredMembers.selectRowIndexes(indexSet as IndexSet, byExtendingSelection: false)
    }
    
    @IBAction func btnPrevious(_ sender: NSButton) {
        let index = getInexOfMember() - 1
        member = arrayOfFilteredMembers?[index]
        loadProfile()
        let indexSet = NSIndexSet(index: index)
        tableFilteredMembers.selectRowIndexes(indexSet as IndexSet, byExtendingSelection: false)
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
    
    @IBAction func btnClose_clicked(_ sender: NSButton) {
        self.view.window?.close()
        tableParent?.reloadData()
    }
    
    func popoverDidClose(_ notification: Notification) {
        tableParent?.reloadData()
    }
    
    @IBAction func saveNote(_ sender: NSTextField) {
        let newNote = PFObject(className: "MemberNotes")
        newNote["note"] = txtNote.stringValue
        newNote.setObject(member!, forKey: "member")
        newNote.setObject(PFUser.current()!, forKey: "staff")
        newNote.saveEventually { (done: Bool, err: Error?) in
            if done {
                self.txtNote.stringValue = ""
                self.arrayOfNotes?.append(newNote)
                self.tableNotes.reloadData()
            }
        }
    }
    
    
    @IBAction func btnNumber_click(_ sender: NSButton) {
//        if txtSetNumber.isHidden {
//            txtSetNumber.isHidden = false
//            btnSaveNumber.isHidden = false
//            txtSetNumber.becomeFirstResponder()
//        } else {
//            txtSetNumber.isHidden = true
//            btnSaveNumber.isHidden = true
//            txtSetNumber.resignFirstResponder()
//        }
        
        let msg = NSAlert()
        msg.addButton(withTitle: "OK")      // 1st button
        msg.addButton(withTitle: "Cancel")  // 2nd button
        msg.messageText = "\(member?["name"])"
        msg.informativeText = "Enter new audition number:"
        
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        txt.stringValue = ""
        
        msg.accessoryView = txt
        let response: NSModalResponse = msg.runModal()
        
        if (response == NSAlertFirstButtonReturn) {
            member?["number"] = Int(txt.stringValue)
            member?.saveEventually()
            btnNumber.title = txt.stringValue
        } else {
            return
        }
    }
    
    var selectedNote: PFObject?
    
    @IBAction func doubleClick(_ sender: Any) {
//        // 1
//        guard tableNotes.selectedRow >= 0 , let note = arrayOfNotes?[tableNotes.selectedRow] else {
//            return
//        }
//        btnNote_click(self)
//        btnSaveNote.isHidden = true
//        txtNote.stringValue = note["note"] as! String
//        selectedNote = note
    }

    @IBAction func checkLeader_changed(_ sender: NSButton) {
        if sender.state == NSOnState {
            comboLeader.isEnabled = true
        } else {
            comboLeader.stringValue = ""
            comboLeader.isEnabled = false
            member?.remove(forKey: "leader")
            member?.remove(forKey: "leaderPosition")
            member?.saveEventually()
        }
    }
    
    
    @IBAction func checkContract_changed(_ sender: NSButton) {
        if sender.state == NSOnState {
            member?["contract"] = true
            member?.saveEventually()
        } else {
            member?.remove(forKey: "contract")
            member?.saveEventually()
        }
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        let combo = notification.object as! NSComboBox
        if combo == comboLeader {
            let pos = comboLeader.objectValueOfSelectedItem as! String
            member?["leaderPosition"] = pos
            member?["leader"] = true
            member?.saveEventually()
        } else if combo == comboPosition {
            let pos = comboPosition.objectValueOfSelectedItem as! String
            member?["position"] = pos
            member?.saveEventually()
        }
    }
    
    @IBAction func click(_ sender: NSTableView) {
        // 1
        guard tableNotes.selectedRow >= 0 , let note = arrayOfNotes?[tableNotes.selectedRow] else {
            return
        }
        selectedNote = note
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let table = notification.object as! NSTableView
        if table == tableFilteredMembers {
            clickMember(tableFilteredMembers)
        } else if table == tableNotes {
            click(tableNotes)
        }
    }
    
    @IBAction func clickMember(_ sender: NSTableView) {
        // 1
        guard tableFilteredMembers.selectedRow >= 0 , let member = arrayOfFilteredMembers?[tableFilteredMembers.selectedRow] else {
            return
        }
        self.member = member
        loadProfile()
    }
    
    @IBAction func deletePosition(_ sender: NSButton) {
        comboPosition.stringValue = ""
        member?.remove(forKey: "position")
        member?.saveEventually()
    }
    
    @IBAction func deleteLeader(_ sender: NSButton) {
        comboLeader.stringValue = ""
        checkLeader.state = NSOffState
        comboLeader.isEnabled = false
        member?.remove(forKey: "leader")
        member?.remove(forKey: "leaderPosition")
        member?.saveEventually()
    }
    
}


