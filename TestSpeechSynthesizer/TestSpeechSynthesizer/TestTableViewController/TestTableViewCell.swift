//
//  TestTableViewCell.swift
//  TestSpeechSynthesizer
//
//  Created by Алексей Казаков on 25/04/2019.
//  Copyright © 2019 Алексей Казаков. All rights reserved.
//

import UIKit

class TestTableViewCell: UITableViewCell {

    @IBOutlet weak var testTextLabel: UILabel?
    
    func setup (text: String) {
        self.testTextLabel?.text = text
    }

}
