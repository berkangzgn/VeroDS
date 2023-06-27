//
//  TableViewItemDataSource.swift
//  VeroDS
//
//  Created by Murat Çiçek on 27.06.2023.
//

import Foundation
import UIKit

protocol TableViewDataSource: AnyObject {
    var numberOfItems: Int { get }
    
    func itemCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
}
