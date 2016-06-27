//
//  SpeechWithAVAudioEngineViewController.swift
//  SpeechTest
//
//  Created by mrJacob on 6/25/16.
//  Copyright © 2016 SushiGrass. All rights reserved.
//

import UIKit
import Speech

class SpeechWithAVAudioEngineViewController: UIViewController {

    private let recognizer = SFSpeechRecognizer()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var inputNode: AVAudioInputNode?
    
    private let audioEngine = AVAudioEngine()

    @IBOutlet var resultLabel: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SFSpeechRecognizer.requestAuthorization {
            (status) in
            DispatchQueue.main.async(execute: { 
                switch status {
                case .authorized:
                    do {
                        try self.startRecording()
                    }
                    catch {
                        
                    }
                default:
                    break
                    //Doh
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioEngine.stop()
        inputNode?.removeTap(onBus: 0)
        
        request = nil
        task = nil
    }
    
    func startRecording() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        
        request = SFSpeechAudioBufferRecognitionRequest()
        
        inputNode = audioEngine.inputNode
        
        guard let checkedInputNode = inputNode  else { return }
        
        request?.shouldReportPartialResults = true
        
        task = recognizer?.recognitionTask(with: request!, resultHandler: {
            (optionalResult, optionalError) in
            var isDone = false
            
            if let result = optionalResult {
                self.resultLabel.text = result.bestTranscription.formattedString
                isDone = result.isFinal
            }
            else if let error = optionalError {
                self.resultLabel.text = "\(error.localizedDescription)"
            }
            
            if isDone {
                self.audioEngine.stop()
                self.inputNode?.removeTap(onBus: 0)
                
                self.request = nil
                self.task = nil
            }
            
        })
        
        let recordingFormat = checkedInputNode.outputFormat(forBus: 0)
        checkedInputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            (buffer: AVAudioPCMBuffer, audioTime: AVAudioTime) in
            self.request?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
    }
}
