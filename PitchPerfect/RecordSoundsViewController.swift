//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Daniel Soutar on 21/08/2020.
//  Copyright © 2020 Daniel Soutar. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    // MARK: - Properties
    var audioRecorder: AVAudioRecorder!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI(ifRecording: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - UI Configuration
    func configureUI(ifRecording isRecording: Bool) {
        if isRecording {
            recordButton.isEnabled = false
            stopRecordingButton.isEnabled = true
            recordingLabel.text = "Recording in Progress"
        } else {
            recordButton.isEnabled = true
            stopRecordingButton.isEnabled = false
            recordingLabel.text = "Tap to Record"
        }
    }
    
    // MARK: - Audio Recording and Stopping
    @IBAction func recordAudio(_ sender: Any) {
        configureUI(ifRecording: true)
        
        let dirPath = NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.documentDirectory,  // Directory to search in
            FileManager.SearchPathDomainMask.userDomainMask,    // Domain mask (user-level, local (to device), network)
            true)[0] as String                                  // Expand tilde at user-level directory to give full path.
        
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playAndRecord,
                                 mode: AVAudioSession.Mode.default,
                                 options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        
        /**
         * TODO: Seems to be a warning of some kind when the audioRecorder is initialised.
         * An error along the lines of '2020-x-x xxxx PitchPerfect[x:x]  PropertyID=1667788144 is NULL'
         * seems to crop up. This doesn't reflect on usage - app works fine - but worth investigating
         * in the future. Seems like an issue internally and to do with audioFormats, but
         * nothing concrete.
         */
        do {
            try audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        configureUI(ifRecording: false)
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    // MARK: - Segue to Next Controller
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("Recording was not successful")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
}
