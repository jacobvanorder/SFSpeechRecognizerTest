//
//  SpeechWithAVFoundationViewController.swift
//  SpeechTest
//
//  Created by mrJacob on 6/24/16.
//  Copyright © 2016 SushiGrass. All rights reserved.
//

import UIKit
import Speech
import AVFoundation

let USE_DELEGATE_METHODS: Bool = false

class SpeechWithAVFoundationViewController: UIViewController {
    
    let session = AVCaptureSession()
    let output = AVCaptureAudioDataOutput()
    var device: AVCaptureDeviceInput!
    
    let recognizer = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    
    @IBOutlet var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        session.beginConfiguration()
        
        if let devices = AVCaptureDevice.devices (withMediaType: AVMediaTypeAudio) as! [AVCaptureDevice]? where devices.count > 0,
            let microphone = devices.first {
            do {
                device = try AVCaptureDeviceInput(device: microphone)
                if session.canAddInput(device) {
                    session.addInput(device)
                }
                
                output.setSampleBufferDelegate(self, queue: DispatchQueue.main)
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                session.commitConfiguration()
                session.startRunning()
            }
            catch {
                print("\(error)")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SFSpeechRecognizer.requestAuthorization {
            (status) in
            switch status {
            case .authorized:
                DispatchQueue.main.async(execute: {
                    self.request.shouldReportPartialResults = true
                    if USE_DELEGATE_METHODS {
                        self.recognizer?.recognitionTask(with: self.request, delegate: self)
                    }
                    else {
                        self.recognizer?.recognitionTask(with: self.request, resultHandler: {
                            (optionalResult, optionalError) in
                            if let result = optionalResult  {
                                self.resultLabel.text = result.bestTranscription.formattedString
                            }
                        })
                    }
                })
            default:
                return
            }
        }
        if SFSpeechRecognizer.authorizationStatus() == .authorized {
        }
    }
}

extension SpeechWithAVFoundationViewController: SFSpeechRecognitionTaskDelegate {
    // MARK: SFSpeechRecognitionTaskDelegate
    func speechRecognitionDidDetectSpeech(_ task: SFSpeechRecognitionTask) {
        
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        DispatchQueue.main.async {
            self.resultLabel.text = recognitionResult.bestTranscription.formattedString
        }
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
        DispatchQueue.main.async {
            self.resultLabel.text = transcription.formattedString
        }
    }
}

extension SpeechWithAVFoundationViewController: AVCaptureAudioDataOutputSampleBufferDelegate {
    // MARK : AVCaptureAudioDataOutputSampleBufferDelegate
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        guard let formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer) else { return }
        let mediaType = CMFormatDescriptionGetMediaType(formatDesc)
        if (mediaType == kCMMediaType_Audio) {
            // process audio here
            request.appendAudioSampleBuffer(sampleBuffer)
        }
    }
}
