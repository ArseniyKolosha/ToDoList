//
//  SpeechViewController.swift
//  ToDoList
//
//  Created by Ars on 11/5/18.
//  Copyright © 2018 ArsenIT. All rights reserved.
//

import UIKit
import Speech

class SpeechViewController: UIViewController {

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var recognizeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    private var tb = TableViewController()
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SFSpeechRecognizer.requestAuthorization { [unowned self] (status) in
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    [unowned self] in
                    self.recognizeButton.isEnabled = true
                }
            case .denied:
                print("status denied")
            case .notDetermined:
                print("status not determined")
            case .restricted:
                print("status restricted")
            }
        }
        
    }
   
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        resultLabel.text = "Tap 'Record' and say"
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let newItem = resultLabel.text
        if newItem != "" {
            addItem(nameItem: newItem!)
        }
//        let destination = TableViewController() // Your destination
//        navigationController?.pushViewController(destination, animated: true)
    }
    
    
    @IBAction func recognizeButtonPressed(_ sender: UIButton) {
        if sender.isSelected{
            audioEngine.stop()
            request.endAudio()
            recognitionTask?.cancel()
            saveButton.isEnabled = true
            deleteButton.isEnabled = true
            //resultLabel.text = "Tap 'Record' and say"
        } else {
            startRecognition()
            saveButton.isEnabled = false
            deleteButton.isEnabled = false
            resultLabel.text = ""
        }
        sender.isSelected = !sender.isSelected
    }
    
    func startRecognition() {
        let node = audioEngine.inputNode
        let recognitionFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1025, format: recognitionFormat) { [unowned self](buffer, audioTime) in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch let error {
            print("\(error.localizedDescription)")
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { [unowned self](result, error) in
            if let res = result {
                DispatchQueue.main.async {
                    [unowned self] in
                    self.resultLabel.text = res.bestTranscription.formattedString
                }
                if res.isFinal{
                    node.removeTap(onBus: 0)
                }
            } else if let error = error {
                print("\(error.localizedDescription)")
                node.removeTap(onBus: 0)
            }
        })
        
    }
    
}
