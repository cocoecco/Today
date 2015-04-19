//
//  SendCell.swift
//  TasksToday
//
//  Created by Shachar Udi on 4/16/15.
//  Copyright (c) 2015 Shachar Udi. All rights reserved.
//

import UIKit

class SendCell: UITableViewCell {

    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var checkmarkBtn: UIButton!
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.backgroundColor = UIColor.whiteColor()
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.backgroundColor = UIColor.whiteColor()
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }


}
