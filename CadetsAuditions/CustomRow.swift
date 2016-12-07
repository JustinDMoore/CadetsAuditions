//
//  CustomRow.swift
//  CadetsAuditions
//
//  Created by Justin Moore on 12/7/16.
//  Copyright © 2016 Justin Moore. All rights reserved.
//

import Cocoa

class CustomRow: NSTableRowView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if isSelected == true {
            let color = NSColor(calibratedRed: 97/255, green: 21/255, blue: 21/255, alpha: 1)
            color.set()
            NSRectFill(dirtyRect)
        }
    }
}
