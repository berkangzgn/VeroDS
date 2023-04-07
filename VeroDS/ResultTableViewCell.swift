//
//  ResultTableViewCell.swift
//  VeroDS
//
//  Created by Berkan Gezgin on 6.04.2023.
//

import UIKit

class ResultTableViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var cellV: UIView!
    @IBOutlet weak var textV: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        textV.textColor = .gray
        textV.backgroundColor = UIColor.clear
        textV.isUserInteractionEnabled = false
        textV.font = UIFont(name: "Helvetica-Bold", size: 16)
        textV.delegate = self
        
        cellV.layer.cornerRadius = 10
    }
}
