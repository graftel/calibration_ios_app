//
//  QuoteRequest.swift
//  Shorabh
//
//  Created by Shorabh on 8/4/16.
//  Copyright © 2016 Graftel. All rights reserved.
//

import UIKit
import AVFoundation
import SendGrid
import Zip

class QuoteRequest:UIViewController, AVAudioRecorderDelegate {
    
   
    @IBOutlet var text: DLRadioButton!
    @IBOutlet var voice: DLRadioButton!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var menuButton: UIBarButtonItem!
    //@IBOutlet var countdown: UITextField!
    @IBOutlet var countdown: UILabel!
    @IBOutlet var textView: UITextView!
    @IBOutlet var Scroller:UIScrollView!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    var dest:NSURL!
    let MODE_RECORD_START = 1;
    let MODE_RECORD_STOP = 0;
    let MODE_PLAY_START = 1;
    let MODE_PLAY_STOP = 0;
    let audio = false;
    var mRecordMode = 0;
    var mPlayMode = 0;
    var flag:Bool = false
    var timer = Timer()
    var counter = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        textView.layer.borderWidth = 1
        if((voice.selected()) != nil) {
            textView.isHidden=true
        }
        else {
            recordButton.isHidden = true
        }
        text.addTarget(self, action: #selector(QuoteRequest.logSelectedButton), for: UIControl.Event.touchUpInside);
        voice.addTarget(self, action: #selector(QuoteRequest.logSelectedButton), for: UIControl.Event.touchUpInside);
        
        mRecordMode = MODE_RECORD_STOP;
        mPlayMode = MODE_PLAY_STOP;
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        Scroller.isScrollEnabled = true
        Scroller.contentSize = CGSize(width: 300, height: 620)
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            print("true")
            
        }
    }
    
    @objc func logSelectedButton(_ radioButton : DLRadioButton) {
        if ((radioButton.selected())?.titleLabel!.text == "Text Message") {
            recordButton.isHidden=true
            textView.isHidden=false
            countdown.isHidden = true
            playButton.isHidden = true
        }
        if ((radioButton.selected())?.titleLabel!.text == "Voice Message") {
            recordButton.isHidden=false
            textView.isHidden=true
        }
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func StartRecord(_ sender: AnyObject)
    {
        if mRecordMode == MODE_RECORD_START
        {
            mRecordMode = MODE_RECORD_STOP
            if audioRecorder != nil {
                finishRecording(success: true)
            }
            sendButton.isEnabled = true
            
        }
        else
        {
            mRecordMode = MODE_RECORD_START
            sendButton.isEnabled = false
            //if audioRecorder == nil {
                startRecording()
            //}
        }
    }
    
    @objc func updateCounter() {
        counter = counter - 1
        countdown.text = "Time Remaining: \(counter)"
        //countdown.text = String(counter--)
        if(self.counter == 0) {
            self.finishRecording(success: true)
        }
    }
    
    
    class func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
     }
    
    var audioFilename:URL!
    func startRecording() {
        
        timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(QuoteRequest.updateCounter), userInfo: nil, repeats: true)
        countdown.isHidden = false
        counter = 59
        countdown.text = "Time Remaining: \(counter)"
        playButton.isHidden = true
        self.recordButton.setBackgroundImage(UIImage(named:"stop.png"),for:UIControl.State())
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSession.Category.playAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { (allowed: Bool) -> Void in
                DispatchQueue.main.async {
                    if allowed {
                        self.audioFilename = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent("recording.m4a")
                        let audioURL = self.audioFilename
                        let settings = [
                            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: 12000.0,
                            AVNumberOfChannelsKey: 1 as NSNumber,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue] as [String : Any]
                        do {
                            self.audioRecorder = try AVAudioRecorder(url: audioURL!, settings: settings)
                            self.audioRecorder.delegate = self
                            self.audioRecorder.record(forDuration: 60)
                            self.audioRecorder.record()
                            
                        } catch {
                            self.finishRecording(success: false)
                        }

                    } else {
                        // failed to record!
                    }
                }
            }
            
        }
        catch {
            
        }
    }
    
    func finishRecording(success: Bool) {
        self.recordButton.setBackgroundImage(UIImage(named:"record1.png"),for:UIControl.State())
        timer.invalidate()
        counter = 0
        audioRecorder.stop()
        if success {
            countdown.isHidden = false
            countdown.text = "Audio Recorded!"
            playButton.isHidden = false
            /*do {
                try audioPlayer = AVAudioPlayer(contentsOf: audioRecorder.url)
                audioPlayer.play()
            } catch {
            }*/
            do {
                //if FileManager.default.fileExists(atPath: String(describing: audioFilename)) {
                    //print("Zipping")
                dest = try Zip.quickZipFiles([audioFilename], fileName: "audio") as NSURL? // Zip
                //}
            }
            catch {
                print("Something went wrong")
            }
        } else {
            countdown.text = "Audio Not Recorded!"
            //countdown.hidden = true
            playButton.isHidden = true
        }
        //audioRecorder = nil
    }
    
    @IBAction func StartPlay(_ sender: AnyObject)
    {
        if(audioRecorder != nil) {
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: audioRecorder.url)
                if mPlayMode == MODE_PLAY_START
                {
                    mPlayMode = MODE_PLAY_STOP
                    self.playButton.setBackgroundImage(UIImage(named:"play.png"),for:UIControl.State())
                    audioPlayer.stop()
                }
                else
                {
                    mPlayMode = MODE_PLAY_START
                    self.playButton.setBackgroundImage(UIImage(named:"pause.png"),for:UIControl.State())
                    audioPlayer.play()
                    let time = DispatchTime.now() + Double(Int64(audioPlayer.duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: time, execute: {
                        self.audioPlayer.stop()
                        self.playButton.setBackgroundImage(UIImage(named:"play.png"),for:UIControl.State())
                    })
                    
                }
            }
            catch {
            }
        }
    }
     
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
       if !flag {
           finishRecording(success: false)
       }
    }
    @IBAction func SendQuote(_ sender: AnyObject) {
        let oldQuoteTimestamp = defaults.object(forKey: "oldQuoteTimestamp") as? Double ?? 0.0
        if (NSDate().timeIntervalSince1970 - oldQuoteTimestamp) >= 60 {
            defaults.set(NSDate().timeIntervalSince1970, forKey: "oldQuoteTimestamp")
            defaults.synchronize()
            var body:String = "\nThis a confirmation that your quote request has been successfully sent to Graftel, we will respond to you within 24 hours.\n"+"\nThank you for contacting Graftel LLC. Below is the original message.\n"+"\n---------------------------------------------------------------------------------------------------------------------------------\n"+"\nQuote request from "+User.contactPersonName+" ( "+User.loginEmail+" ) \n"
            var yes:Bool = false
            let session = SendGrid.Session()
            session.authentication = Authentication.apiKey(SendGridKey)
            let personalization = Personalization(to: [Address(stringLiteral: User.loginEmail)], bcc: [Address("scott@graftel.com"),Address("kangmin@graftel.com"),Address("esther@graftel.com"),Address("pdavis@graftel.com")])
            if text.isSelected == true {
                if textView?.text.isEmpty != true {
//                    body = body + "\n" + textView!.text!
//                    let plainText = Content(contentType: ContentType.plainText, value: body)
//                    let email = Email(
//                        personalizations: [personalization],
//                        from: Address(email: "scott@graftel.com", name: "Graftel APP"),
//                        replyTo: Address(stringLiteral: User.loginEmail),
//                        content: [plainText],
//                        subject: "[Graftel APP] Your quote request has been sent to Graftel"
//                    )
//                    do {
//                        try session.send(request: email)
//                        yes=true
//                    }
//                    catch {
//                        print(error)
//                    }
                }
                else {
                    let alert = UIAlertController(title: "Error", message: "Please enter required fields!", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK!", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else {
                if(audioRecorder != nil) {
//                    let plainText = Content(contentType: ContentType.plainText, value: "Audio Message in Attachment")
//                    let email = Email(
//                        personalizations: [personalization],
//                        from: Address(email: "scott@graftel.com", name: "Graftel APP"),
//                        replyTo: Address(stringLiteral: User.loginEmail),
//                        content: [plainText],
//                        subject: "[Graftel APP] Your quote request has been sent to Graftel"
//                    )
//                    do {
//                        let attachment = Attachment(
//                            filename: "audio.zip",
//                            content: try Data(contentsOf: dest as URL),
//                            disposition: .attachment,
//                            type: .zip,
//                            contentID: nil
//                        )
//                        email.attachments = [attachment]
//                        try session.send(request: email)
//                        yes=true
//                    }
//                    catch {
//                        print(error)
//                    }
                }
                else {
                    let alert = UIAlertController(title: "Error", message: "Please record a Quote!", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK!", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            if(yes == true) {
                let alert = UIAlertController(
                    title: "",
                    message: "Mail Sent, Thank you!",
                    preferredStyle: .alert
                )
                self.present(alert, animated: true, completion: nil)
                let time = DispatchTime.now() + Double(Int64(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time, execute: {
                    alert.dismiss(animated: true, completion: nil)
                })
            }
        }
        else {
            let alert = UIAlertController(
                title: "",
                message: "Cannot Send a Quote within a minute.",
                preferredStyle: .alert
            )
            self.present(alert, animated: true, completion: nil)
            let time = DispatchTime.now() + Double(Int64(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        }
    }
    
}
