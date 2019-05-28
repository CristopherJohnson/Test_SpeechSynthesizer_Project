//
//  SpeechSynthesizerManager.swift
//  TestSpeechSynthesizer
//
//  Created by Алексей Казаков on 25/04/2019.
//  Copyright © 2019 Алексей Казаков. All rights reserved.
//

import Foundation
import AVFoundation
import Speech

class SpeechSynthesizerManager {
    static let shared = SpeechSynthesizerManager()
    private init () {}
    let speechSynthesizer = AVSpeechSynthesizer()
    
    private var currentText = ""
    
    private var isPaused: Bool = false
    
    public var languageCode: String = "en-US"
    
    func speak (text: String) {
        self.speak(text: text, language: self.languageCode)
    }
    
    func speak (text: String, language: String) {
        
        if self.currentText == text {
            if self.isPaused == false && self.speechSynthesizer.isSpeaking == false {
                let speechUtterance = AVSpeechUtterance(string: text)
                speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
                speechUtterance.voice = AVSpeechSynthesisVoice.init(language: language)
                self.speechSynthesizer.speak(speechUtterance)
            } else if self.isPaused == false {
                self.speechSynthesizer.pauseSpeaking(at: .immediate)
                self.isPaused = true
            } else if self.isPaused == true {
                self.speechSynthesizer.continueSpeaking()
                self.isPaused = false
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

class SpeechRecognitionMeneger {
    
    static let shared = SpeechRecognitionMeneger()
    private init () {}
    
    private let audioEngine = AVAudioEngine()
    private var speechRecognizer = SFSpeechRecognizer()
    private let request = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private var isRecording: Bool = false
    private var text = ""
    public var languageCode: String = "en-US"
    public func startRecognition() {
        self.startRecognition(language: languageCode)
    }
    
    public func startRecognition (language: String) {
        if self.isRecording {
            self.stopRecognition()
        }
        self.text = ""
        self.isRecording = true
        
//        self.speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: language))
        
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
            
        node.installTap(onBus: 0, bufferSize: 1024,
                            format: recordingFormat) { [unowned self]
                                (buffer, _) in
                                self.request.append(buffer)
        }
            
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch let error {
            print("There was a problem starting recording: \(error.localizedDescription)")
            return
        }
            
        recognitionTask = speechRecognizer?.recognitionTask(with: request) {
            [unowned self]
            (result, error) in
            if let transcription = result?.bestTranscription {
                self.text = transcription.formattedString
            }
            if let error = error {
                print("recognitionTask error: \(error.localizedDescription)")
            }
        }
    }
    
    public func stopRecognition () -> String {
        audioEngine.stop()
        request.endAudio()
        recognitionTask?.cancel()
        audioEngine.inputNode.removeTap(onBus: 0)
        self.isRecording = false
        return self.text
    }
}

