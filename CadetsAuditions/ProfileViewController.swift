//
//  ProfileViewController.swift
//  CadetsAuditions
//
//  Created by Justin Moore on 11/9/16.
//  Copyright © 2016 Justin Moore. All rights reserved.
//

import Cocoa
import Parse

class ProfileViewController: NSViewController {
    
    var member: PFObject? = nil
    
    @IBOutlet weak var imgPicture: NSImageView!

    @IBOutlet weak var lblAge: NSTextField!
    @IBOutlet weak var lblEmail: NSButton!
    @IBOutlet weak var lblSections: NSTextField!
    @IBOutlet weak var imgCorps: NSImageView!
    @IBOutlet weak var lblName: NSTextField!
    @IBOutlet weak var lblNumber: NSTextField!
    @IBOutlet weak var lblRating: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
}


