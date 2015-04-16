//
//  HFCell.swift
//  TasksToday
//
//  Created by Shachar Udi on 4/10/15.
//  Copyright (c) 2015 Shachar Udi. All rights reserved.
//

import UIKit

class HFCell: UITableViewCell {

    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var priorityView: UIView!
    @IBOutlet weak var checkmarkButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
//        let orColor:UIColor = self.priorityView.backgroundColor!
//        super.setSelected(selected, animated: animated)
//        self.priorityView.backgroundColor = orColor
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
//        let orColor:UIColor = self.priorityView.backgroundColor!
//        super.setHighlighted(highlighted, animated: animated)
//        self.priorityView.backgroundColor = orColor
    }
}
