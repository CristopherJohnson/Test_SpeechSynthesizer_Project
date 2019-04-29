//
//  SpeechSynthesizerManager.swift
//  TestSpeechSynthesizer
//
//  Created by Алексей Казаков on 25/04/2019.
//  Copyright © 2019 Алексей Казаков. All rights reserved.
//

import Foundation
import AVFoundation

class SpeechSynthesizerManager {
    static let shared = SpeechSynthesizerManager()
    private init () {}
    let speechSynthesizer = AVSpeechSynthesizer()
    
    private var currentText = ""
    
    public var languageCode: String = "en-US"
    
    func speak (text: String) {
        self.speak(text: text, language: self.languageCode)
    }
    
    func speak (text: String, language: String) {
        
        if self.currentText == text {
            if self.speechSynthesizer.isPaused == false && self.speechSynthesizer.isSpeaking == false {
                let speechUtterance = AVSpeechUtterance(string: text)
                speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
                speechUtterance.voice = AVSpeechSynthesisVoice.init(language: language)
                self.speechSynthesizer.speak(speechUtterance)
            } else if self.speechSynthesizer.isSpeaking == true {
                self.speechSynthesizer.pauseSpeaking(at: .immediate)
            } else if self.speechSynthesizer.isPaused == true {
                print("continue")
                self.speechSynthesizer.continueSpeaking()
            }
        } else if self.currentText != text {
            self.speechSynthesizer.stopSpeaking(at: .immediate)
            self.currentText = text
            let speechUtterance = AVSpeechUtterance(string: text)
            speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
            speechUtterance.voice = AVSpeechSynthesisVoice.init(language: language)
            self.speechSynthesizer.speak(speechUtterance)
        }
    }
    
}


