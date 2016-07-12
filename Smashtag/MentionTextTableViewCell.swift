//
//  MentionTextTableViewCell.swift
//  Smashtag
//
//  Created by WangQi on 16/7/5.
//  Copyright © 2016年 WangQi. All rights reserved.
//

import UIKit

class MentionTextTableViewCell: UITableViewCell {
    
    var keywordA: String? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var mentionKeyword: UILabel!
    
    private func updateUI() {
        mentionKeyword?.text = keywordA
    }

}
