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

enum SpeechRecognitionManagerError: Error {
    case emptyRecognitionRequest
    case emptySpeechRecognizer
    case inProgress
}

class SpeechSynthesizerManager {
    static let shared = SpeechSynthesizerManager()
    private init () {}
    let speechSynthesizer = AVSpeechSynthesizer()
    
    private var currentText = ""
    
    private var isPaused: Bool = false
    
    public var languageCode: String = "en-US"
    
    func speechRate() -> Float {
        return (AVSpeechUtteranceDefaultSpeechRate - AVSpeechUtteranceMinimumSpeechRate) * 0.9
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
    // MARK: -
    
    private init () {}
    
    private let audioEngine = AVAudioEngine()
    private var speechRecognizer:   SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask:    SFSpeechRecognitionTask?
    
    private var isRecording: Bool = false
    private var text = ""
    private var languageCode: String = "en-US"

    
    public func setCanNotTalk() {
        UserDefaults.standard.set(Date().timeIntervalSince1970 + 1 * 60 * 60, forKey: "Can not talk")
    }
    
    public func canTalk() -> Bool {
        let currentDate = Date().timeIntervalSince1970
        let savedDate   = UserDefaults.standard.double(forKey: "Can not talk")
        
        return currentDate > savedDate
    }
    
    public var resultUpdateClosure: ( (_ resultText: String?, _ error: Error?, _ isFinal: Bool) -> () )?
    
    public func requestPermission(completion: @escaping (Bool) -> ()) {
        SFSpeechRecognizer.requestAuthorization { (status: SFSpeechRecognizerAuthorizationStatus) in
            if .authorized != status {
                OperationQueue.main.addOperation({ completion(false) })
            } else {
                AVAudioSession.sharedInstance().requestRecordPermission({ (isMicroGranted: Bool) in
                    OperationQueue.main.addOperation({ completion(isMicroGranted) })
                })
            }
        }
    }
    
    public func startRecognition() throws {
        try self.startRecognition(language: self.languageCode)
    }
    
    public func startRecognition (language: String) throws {
        if self.isRecording {
            throw SpeechRecognitionManagerError.inProgress
        }
        
        if nil != recognitionTask {
            throw SpeechRecognitionManagerError.inProgress
        }
        
        guard let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: language)) else {
            throw SpeechRecognitionManagerError.emptySpeechRecognizer
        }
        
        self.text = ""
        
        self.isRecording = true
        
        self.speechRecognizer = speechRecognizer
        
        let audioSession = AVAudioSession.sharedInstance()
        try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
        try audioSession.setMode(AVAudioSession.Mode.measurement)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { throw SpeechRecognitionManagerError.emptyRecognitionRequest }
        
        let inputNode = audioEngine.inputNode
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            let isFinal = result?.isFinal ?? false
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.isRecording = false
            }
            
            if let resultUpdateClosure = self.resultUpdateClosure {
                let text = result?.bestTranscription.formattedString ?? ""
                resultUpdateClosure(text, error, isFinal)
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
    }
    
    public func stopRecognition () -> String {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            
            do {
                let audioSession = AVAudioSession.sharedInstance()
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try audioSession.setMode(AVAudioSession.Mode.default)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                #if DEBUG
                fatalError("Exception \(#file) \(#function) \(#line) \(error)")
                #else
                debugPrint("Exception \(#file) \(#function) \(#line) \(error)")
                #endif
            }
        }

        return self.text
    }
    

}
