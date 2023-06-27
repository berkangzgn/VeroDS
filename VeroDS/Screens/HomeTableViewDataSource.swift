//
//  HomeTableViewDataSource.swift
//  VeroDS
//
//  Created by Murat Çiçek on 27.06.2023.
//

import Foundation
import UIKit

final class HomeTableViewDataSource: TableViewDataSource {
    
    private var entities: HomeEntities!

    init(entities: HomeEntities!) {
        self.entities = entities
    }
    
    var numberOfItems: Int {
        return entities.data?.count ?? 0
    }
    
    func itemCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultTableViewCell
        var resultText: String?
        let currentResult = entities.data?[indexPath.row]
        
        if currentResult?.title != nil { resultText = "\(String(describing: currentResult?.title ?? ""))\n" }
        if currentResult?.task != nil { resultText = "\(String(describing: currentResult?.task ?? ""))\n" }
        if currentResult?.description != nil { resultText = "\(String(describing: currentResult?.description ?? ""))" }
        if currentResult?.colorCode != nil { cell.cellV.backgroundColor = UIColor().colorFromHex(hexString: currentResult?.colorCode ?? "") }
        
        if resultText == "" {
            resultText = "Sorry, there's no information that can be shown right now"
        }
        
        cell.textV.text = "\(resultText!)"
        cell.selectionStyle  = .none
        
        return cell
    }
}
