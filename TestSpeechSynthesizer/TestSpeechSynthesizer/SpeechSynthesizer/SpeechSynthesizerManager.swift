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
    
    public var languageCode: String = "en-US"
    
    func speak (text: String) {
        self.speak(text: text, language: self.languageCode)
    }
    
    func speak (text: String, language: String) {
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
        speechUtterance.voice = AVSpeechSynthesisVoice.init(language: language)
        self.speechSynthesizer.speak(speechUtterance)
    }
    
}


