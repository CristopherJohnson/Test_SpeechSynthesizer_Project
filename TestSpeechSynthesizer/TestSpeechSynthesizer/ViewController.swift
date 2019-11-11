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
    private var recognizedText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.button?.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        self.button?.addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
        self.button?.addTarget(self, action: #selector(buttonTouchEnded), for: .touchUpOutside)
        self.button?.addTarget(self, action: #selector(buttonTouchEnded), for: .touchCancel)
        SpeechRecognitionMeneger.shared.requestPermission { [weak self] (authorized: Bool) in
               self?.button?.isEnabled = authorized
        }
        
        SpeechRecognitionMeneger.shared.resultUpdateClosure = { [weak self] (resultText: String?, error: Error?, isFinal: Bool) in
            if let error = error {
                debugPrint("error \(error)")
                self?.recognizedText = ""
            } else {
                self?.recognizedText = resultText ?? ""
            }
            
            if isFinal, let resultText = resultText, resultText.count > 0 {
                self?.recognizedText = resultText
                print("resultText: \(resultText)")
            } else {
                self?.recognizedText = ""
            }
        }
    }
    
    @objc private func buttonTouchDown () {
        do {
            try SpeechRecognitionMeneger.shared.startRecognition()
            self.isRecording = true
        } catch {
            debugPrint("Exception \(#file) \(#function) \(#line) \(error)")
            #if DEBUG
            self.recognizedText = "\(error)"
            #endif
        }
    }

    @objc private func buttonTouchUpInside () {
        self.isRecording = false
        let text = SpeechRecognitionMeneger.shared.stopRecognition()
        print("text: \(text)")
    }

    @objc private func buttonTouchEnded () {
        self.isRecording = false
        let text = SpeechRecognitionMeneger.shared.stopRecognition()
        print("text: \(text)")
    }
    

        

}
