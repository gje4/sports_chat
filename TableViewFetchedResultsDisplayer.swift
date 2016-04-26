//
//  TableViewFetchedResultsDisplayer.swift
//  NanChat
//
//  Created by George Fitzgibbons on 4/8/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import Foundation
import UIKit

// have this protocol in its' own file since we will be using this procotol in multiple spot
protocol TableViewFetchedResultsDisplayer{
    func configureCell(cell:UITableViewCell, atIndexPath indexPath: NSIndexPath)
}