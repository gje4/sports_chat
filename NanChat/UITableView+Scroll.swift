//
//  UITableView+Scroll.swift
//  NanChat
//
//  Created by George Fitzgibbons on 1/21/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

//moduler helper to control all scrolling in the ui table

import Foundation
import UIKit

extension UITableView {
    func scrollToBottom() {
//find how many rows there are if there are more than 1.  Subtract 1 to get to the last indexpath
        if self.numberOfSections > 1{
            let lastSection = self.numberOfSections - 1
            self.scrollToRowAtIndexPath(NSIndexPath(forRow:self.numberOfRowsInSection(lastSection) - 1, inSection: lastSection), atScrollPosition: .Bottom, animated: true)
        }
            //only run if there is data in the row (message)

        else if self.numberOfSections == 1 && self.numberOfRowsInSection(0) > 0 {
            self.scrollToRowAtIndexPath(NSIndexPath(forRow: self.numberOfRowsInSection(0)-1, inSection: 0), atScrollPosition: .Bottom, animated: true)
        }
    }
}