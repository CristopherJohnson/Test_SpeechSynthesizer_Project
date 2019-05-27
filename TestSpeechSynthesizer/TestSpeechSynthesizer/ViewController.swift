//
//  ViewController.swift
//  TestSpeechSynthesizer
//
//  Created by Алексей Казаков on 27/05/2019.
//  Copyright © 2019 Алексей Казаков. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var button: UIButton?
    
    private var isRecording: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func touch () {
        if self.isRecording {
            SpeechRecognitionMeneger.shared.stopRecording { (str: String) in
                print("Text is \(str)")
                self.isRecording = false
            }
        } else {
            self.isRecording = true
            SpeechRecognitionMeneger.shared.startRecording()
        }
    }

}
