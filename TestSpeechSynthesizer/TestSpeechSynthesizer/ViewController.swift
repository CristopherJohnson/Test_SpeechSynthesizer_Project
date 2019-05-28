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
    
//    @IBAction func touchDown () {
//        SpeechRecognitionMeneger.shared.startRecognition()
//    }
    
    @IBAction func touch () {
        if self.isRecording {
            let text = SpeechRecognitionMeneger.shared.stopRecognition()
            print(text)
            self.isRecording = false
        } else {
            SpeechRecognitionMeneger.shared.startRecognition()
            self.isRecording = true
        }
    }
        

}
