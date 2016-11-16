//
//  ProfileViewController.swift
//  CadetsAuditions
//
//  Created by Justin Moore on 11/9/16.
//  Copyright © 2016 Justin Moore. All rights reserved.
//

import Cocoa
import Parse

class ProfileViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    var member: PFObject? = nil
    
    @IBOutlet weak var imgPicture: NSImageView!

    @IBOutlet weak var lblAge: NSTextField!
    @IBOutlet weak var btnEmail: NSButton!
    @IBOutlet weak var lblSections: NSTextField!
    @IBOutlet weak var imgCorps: NSImageView!
    @IBOutlet weak var lblName: NSTextField!
    @IBOutlet weak var lblNumber: NSTextField!
    @IBOutlet weak var lblRating: NSTextField!
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableNotes.delegate = self
        tableNotes.dataSource = self
        loadProfile()
    }

    func loadProfile() {
        if let imageFile = member?["picture"] as? PFFile {
            imageFile.getDataInBackground(block: { (data: Data?, err: Error?) in
                if data != nil {
                    self.imgPicture.image = NSImage(data: data!)
                }
            })
        } else {
            imgPicture.image = NSImage(named: "Picture")
        }
        
//        let number = member?["number"] as? Int ?? 0
//        let name = member?["name"] as? String ?? ""
//        lblName.stringValue = name
//        lblNumber.stringValue = String(number)
//        
//        if let dob = member?["dob"] as? Date {
//            let now = Date()
//           // let ageComponents = Calendar.dateComponents([.year], from: dob, to: now)
//        } else {
//            lblAge.stringValue = "Unknown"
//        }
        
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
   }
//
//    func calculateAge (birthday: NSDate) -> NSInteger {
//        
////        var userAge : NSInteger = 0
////        var calendar : NSCalendar = NSCalendar.currentCalendar
////        var unitFlags : NSCalendarUnit = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay
////        var dateComponentNow : NSDateComponents = calendar.components(unitFlags, fromDate: NSDate.date())
////        var dateComponentBirth : NSDateComponents = calendar.components(unitFlags, fromDate: birthday)
////        
////        if ( (dateComponentNow.month < dateComponentBirth.month) ||
////            ((dateComponentNow.month == dateComponentBirth.month) && (dateComponentNow.day < dateComponentBirth.day))
////            )
////        {
////            return dateComponentNow.year - dateComponentBirth.year - 1
////        }
////        else {
////            return dateComponentNow.year - dateComponentBirth.year
////        }
//    }
    
    @IBAction func btnRating_click(_ sender: NSButtonCell) {
        lblRating.stringValue = "\(sender.tag)"
        //save the rating to profile
    }
    
    //MARK:-
    //MARK:TABLE VIEW
    //MARK:-
    
//    func numberOfRows(in tableView: NSTableView) -> Int {
//        if arrayOfFilteredMembers?.count != nil {
//            return arrayOfFilteredMembers!.count
//        } else {
//            return 0
//        }
//    }
//    
//    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
//        
//        var image:NSImage?
//        var text:String = ""
//        var cellIdentifier: String = ""
//        
//        guard let member = arrayOfFilteredMembers?[row] else {
//            return nil
//        }
//        
//        if tableColumn == tableView.tableColumns[0] { // NUMBER
//            if let num = member["number"] as? Int {
//                text = String(num)
//            }
//            cellIdentifier = "cellNumber"
//        }
//        
//        if tableColumn == tableView.tableColumns[1] { // NAME
//            text = member["name"] as? String ?? ""
//            cellIdentifier = "cellName"
//        }
//            
//            
//        else if tableColumn == tableView.tableColumns[2] { // CADETS LOGO
//            let C = member["cadets"] as! Bool
//            if C {
//                image = NSImage(named: "Cadets")
//            }
//            cellIdentifier = "cellAuditioningForCadets"
//        }
//            
//        else if tableColumn == tableView.tableColumns[3] { // CADETS2 LOGO
//            let C2 = member["cadets2"] as! Bool
//            if C2 {
//                image = NSImage(named: "Cadets2")
//            }
//            cellIdentifier = "cellAuditioningForCadets2"
//        }
//            
//        else if tableColumn == tableView.tableColumns[4] { // SECTION
//            if let arrayOfInstruments = member["sections"] as! [String]? {
//                var strInstruments = ""
//                if arrayOfInstruments.count > 1 {
//                    for instrument in arrayOfInstruments {
//                        strInstruments += instrument + "    "
//                    }
//                } else if arrayOfInstruments.count == 1 {
//                    strInstruments = arrayOfInstruments.first!
//                }
//                
//                text = strInstruments
//            }
//            cellIdentifier = "cellSections"
//        }
//            
//            
//        else if tableColumn == tableView.tableColumns[5] { // RATING
//            if let rating = member["rating"] as! Int? {
//                text = "\(rating)"
//            } else {
//                text = ""
//            }
//            cellIdentifier = "cellRating"
//        }
//            
//        else if tableColumn == tableView.tableColumns[6] { // PICTURE
//            text = ""
//            if let _ = member["picture"] as? PFFile {
//                image = NSImage(named: "Picture")
//            } else {
//                image = nil
//            }
//            cellIdentifier = "cellPicture"
//        }
//        
//        
//        // 3
//        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
//            cell.textField?.stringValue = text
//            cell.imageView?.image = image ?? nil
//            return cell
//        } else {
//            print("no \(cellIdentifier)")
//        }
//        return nil
//        
//    }
}


