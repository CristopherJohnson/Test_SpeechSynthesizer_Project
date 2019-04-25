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
    
    func speak (text: String) {
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
        speechUtterance.voice = AVSpeechSynthesisVoice.init(language: "US")
        speechUtterance.voice = AVSpeechSynthesisVoice.init(identifier: AVSpeechSynthesisVoiceIdentifierAlex)
        let speechSynthesizer = AVSpeechSynthesizer()
        speechSynthesizer.speak(speechUtterance)
    }
    
    
}


