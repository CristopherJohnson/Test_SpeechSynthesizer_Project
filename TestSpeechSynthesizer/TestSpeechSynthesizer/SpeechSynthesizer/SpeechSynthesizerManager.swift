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
    
    func speechRate() -> Float {
        return (AVSpeechUtteranceDefaultSpeechRate - AVSpeechUtteranceMinimumSpeechRate) * 0.75
    }
    
    func speak (text: String) {
        self.speak(text: text, language: self.languageCode)
    }
    
    func speak (text: String, language: String) {
        
        if self.currentText == text {
            if self.isPaused == false && self.speechSynthesizer.isSpeaking == false {
                let speechUtterance = AVSpeechUtterance(string: text)
                speechUtterance.rate = self.speechRate()
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
            speechUtterance.rate = self.speechRate()
            speechUtterance.voice = AVSpeechSynthesisVoice.init(language: language)
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
    
    public var resultUpdateClosure: ( (_ resultText: String?, _ error: Error?) -> () )?
    
    public func requestPermission(completion: @escaping (Bool) -> ()) {
        SFSpeechRecognizer.requestAuthorization { (status: SFSpeechRecognizerAuthorizationStatus) in
            OperationQueue.main.addOperation({
                completion(.authorized == status)
            })
        }
    }
    
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
        
        let recordingFormat = self.audioEngine.inputNode.outputFormat(forBus: 0)
        self.audioEngine.inputNode.installTap(onBus: 0,
                                              bufferSize: 1024,
                                              format: recordingFormat) { [unowned self] (buffer, _) in
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
            
            if let transcription = result?.bestTranscription {
                self.text = transcription.formattedString
            }
            
            if let resultUpdateClosure = self.resultUpdateClosure {
                resultUpdateClosure(result?.bestTranscription.formattedString, error)
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
        self.request.endAudio()
        
        if self.audioEngine.isRunning {
            self.audioEngine.stop()
            self.audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        if let recognitionTask = self.recognitionTask {
            recognitionTask.finish()
        }
        self.recognitionTask = nil
        
        self.isRecording = false
        
        return self.text
    }
}
