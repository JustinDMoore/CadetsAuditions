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
        lblAge.stringValue = "\(age)"
        
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
                let reason = member!["whyDecember"] as! String ?? ""
                lblDecember.stringValue = "I cannot come to the December Camp" + "\n \n \(reason)"
            } else {
                lblDecember.stringValue = "I can come to the December Camp"
            }
        } else {
            lblDecember.stringValue = "N/A"
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


