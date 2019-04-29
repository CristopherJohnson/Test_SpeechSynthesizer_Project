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
    
    private var isSpeaking: Bool = false
    private var isPaused: Bool = false
    
    public var languageCode: String = "en-US"
    
    func speak (text: String) {
        self.speak(text: text, language: self.languageCode)
    }
    
    func speak (text: String, language: String) {
        
        if self.currentText == text {
            if self.isPaused == false && self.isSpeaking == false {
                let speechUtterance = AVSpeechUtterance(string: text)
                speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
                speechUtterance.voice = AVSpeechSynthesisVoice.init(language: language)
                self.speechSynthesizer.speak(speechUtterance)
                self.isSpeaking = true
            } else if self.isSpeaking == true {
                self.speechSynthesizer.pauseSpeaking(at: .immediate)
                self.isSpeaking = false
                self.isPaused = true
            } else if self.isPaused == true {
                print("continue")
                self.speechSynthesizer.continueSpeaking()
                self.isPaused = false
                self.isSpeaking = true
            }
        } else if self.currentText != text {
            self.speechSynthesizer.stopSpeaking(at: .immediate)
            self.currentText = text
            let speechUtterance = AVSpeechUtterance(string: text)
            speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
            speechUtterance.voice = AVSpeechSynthesisVoice.init(language: language)
            self.speechSynthesizer.speak(speechUtterance)
            self.isSpeaking = true
        }
    }
    
}


