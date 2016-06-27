//
//  SpeechWithPrerecordedAudioViewController.swift
//  SpeechTest
//
//  Created by mrJacob on 6/27/16.
//  Copyright © 2016 SushiGrass. All rights reserved.
//

import UIKit
import Speech

class SpeechWithPrerecordedAudioViewController: UIViewController {
    
    @IBOutlet var resultLabel: UILabel!
    
    let recognizer = SFSpeechRecognizer()
    var request: SFSpeechURLRecognitionRequest?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resultLabel.text = "Loading"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SFSpeechRecognizer.requestAuthorization {
            (status) in
            DispatchQueue.main.async(execute: {
                switch status {
                case .authorized:
                    self.load(recordedAudioWithFileName: "test", inBundle: Bundle.main())
                default:
                    break
                    //Doh
                }
            })
        }
    }
    
    func load(recordedAudioWithFileName fileName: String, inBundle bundle: Bundle) {
        guard let audioURL = bundle.urlForResource(fileName, withExtension: "m4a") else {
            assert(false)
            return
        }
        
        request = SFSpeechURLRecognitionRequest(url: audioURL)
        guard let checkedRequest = request else { return }
        recognizer?.recognitionTask(with: checkedRequest, resultHandler: {
            (optionalResult, optionalError) in
            if let result = optionalResult {
                self.resultLabel.text = result.bestTranscription.formattedString
                self.request?.finalize()
            }
            else if let error = optionalError {
                self.resultLabel.text = "\(error.localizedDescription)"
            }
        })
    }
    
}
