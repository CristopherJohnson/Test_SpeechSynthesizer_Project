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
    public var speechRate: Float = AVSpeechUtteranceDefaultSpeechRate
    public var needMaleVoice = true
    
    func speak (text: String) {
        self.speak(text: text, language: self.languageCode, speechRate: self.speechRate, needMaleVoice: self.needMaleVoice)
    }
    
    func speak (text: String, language: String, speechRate: Float, needMaleVoice: Bool) {
        var speed: Float = AVSpeechUtteranceDefaultSpeechRate
        if speed <= 1 && speed >= 0{
            speed = speechRate
        }
        print(AVSpeechSynthesisVoice.speechVoices())
        
        if self.currentText == text {
            if self.isPaused == false && self.speechSynthesizer.isSpeaking == false {
                let speechUtterance = AVSpeechUtterance(string: text)
                speechUtterance.rate = speed
                if needMaleVoice && language.contains("en") {
                    speechUtterance.voice = AVSpeechSynthesisVoice.init(language: "en-GB")
                    speechUtterance.voice = AVSpeechSynthesisVoice.init(identifier: "com.apple.ttsbundle.Daniel-compact")
                } else {
                    speechUtterance.voice = AVSpeechSynthesisVoice.init(language: language)
                }
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
            speechUtterance.rate = speed
            if needMaleVoice && language.contains("en") {
                speechUtterance.voice = AVSpeechSynthesisVoice.init(language: "en-GB")
                speechUtterance.voice = AVSpeechSynthesisVoice.init(identifier: "com.apple.ttsbundle.Daniel-compact")
            } else {
                speechUtterance.voice = AVSpeechSynthesisVoice.init(language: language)
            }
            self.speechSynthesizer.speak(speechUtterance)
        }
    }
    
}

class SpeechRecognitionMeneger {
    
    static let shared = SpeechRecognitionMeneger()
    private init () {}
    
    private let audioEngine = AVAudioEngine()
    private var speechRecognizer: SFSpeechRecognizer?
    private let request = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private var isRecording: Bool = false
    private var text = ""
    private var languageCode: String = "en-US"
    
    public func startRecognition() {
        self.startRecognition(language: self.languageCode)
    }
    
    public func startRecognition (language: String) {
        if self.isRecording {
            _ = self.stopRecognition()
        }
        self.languageCode = language
        self.text = ""
        self.isRecording = true
        
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: language))
        
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024,
                        format: recordingFormat) { [unowned self]
                            (buffer, _) in
                            self.request.append(buffer)
        }
        
        self.audioEngine.prepare()
        do {
            try self.audioEngine.start()
        } catch let error {
            print("There was a problem starting recording: \(error.localizedDescription)")
            return
        }
        
        self.recognitionTask = self.speechRecognizer?.recognitionTask(with: request) { [unowned self] (result: SFSpeechRecognitionResult?, error: Error?) in
            
            print("result?.bestTranscription \(String(describing: result?.bestTranscription))")
            
            if let transcription = result?.bestTranscription {
                self.text = transcription.formattedString
            }
            
            if let error = error {
                print("recognitionTask error: \(error.localizedDescription)")
                _ = self.stopRecognition()
            }
            
            if let isFinal = result?.isFinal, isFinal {
                _ = self.stopRecognition()
            }
        }
    }
    
    public func stopRecognition () -> String {
        if self.audioEngine.isRunning {
            self.audioEngine.stop()
            self.audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        self.request.endAudio()
        
        if let recognitionTask = self.recognitionTask {
            recognitionTask.finish()
        }
        self.recognitionTask = nil
        
        self.isRecording = false
        
        return self.text
    }
}

