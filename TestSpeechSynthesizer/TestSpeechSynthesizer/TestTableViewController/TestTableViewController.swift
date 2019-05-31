//
//  TestTableViewController.swift
//  TestSpeechSynthesizer
//
//  Created by Алексей Казаков on 25/04/2019.
//  Copyright © 2019 Алексей Казаков. All rights reserved.
//

import UIKit

class TestTableViewController: UITableViewController {
    
    var testStringArray: [String] = ["Calling this method adds the utterance to a queue; utterances are spoken in the order in which they are added to the queue", "If the synthesizer is not currently speaking, the utterance is spoken immediately"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestCell", for: indexPath) as! TestTableViewCell
        cell.setup(text: testStringArray[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SpeechSynthesizerManager.shared.speak(text: testStringArray[indexPath.row])
    }

}
