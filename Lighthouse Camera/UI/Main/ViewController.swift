//
//  ViewController.swift
//  Lighthouse Camera
//
//  Created by David Teller on 16/12/16.
//  Copyright © 2016 Lighthouse. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    var bridge: Bridge!

    var isBusy: Bool

    required init?(coder aCoder: NSCoder) {
        isBusy = false
        super.init(coder:aCoder)
    }

    //MARK: Properties
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    //MARK: Actions

    // Invoked when the user has clicked on "record".
    @IBAction func onRecordClick(_ sender: Any) {
        if self.isBusy {
            bridge.onStopCapture()
            self.isBusy = false
        } else {
            bridge.onRecordObject();
            self.isBusy = true
        }
    }

    // Invoked when the user clicks to stop the ongoing action.
    @IBAction func onEmptyClick(_ sender: Any) {
        bridge.onStopCapture();
    }

    // Invoked when the user has clicked on "identify".
    @IBAction func onIdentifyClick(_ sender: Any) {
        let image = self.imageView.image;
        var matches: Array<Dictionary<String, String>> = Array();

        do {
            matches = try bridge.match(image)
        } catch let error as NSError {
            let message = error.domain == "ImageQuality" ?
                "Image does not have enough keypoints. Please try again." :
                "Unexpected exception occurred during image matching."

            let alert = UIAlertController(title: "Error", message: message,
                preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default))
            self.present(alert, animated: true, completion: nil)
        }

        let hasMatches = matches.isEmpty == false

        let alertMessage = hasMatches ? "Best score: \(matches[0]["score"]!) out of 105." : "No matches found!"
        let alert = UIAlertController(title: "Match Result", message: alertMessage,
            preferredStyle: UIAlertControllerStyle.alert)

        // Define alert actions.
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)

        let rememberAction = UIAlertAction(title: "Remember", style: UIAlertActionStyle.default, handler: {
            action in
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    self.bridge.saveDescription(image)
                } else{
                    let alert = UIAlertController(title: "Microphone access is disabled.",
                        message: "Please, go to Settings > Privacy > Microphone and enable that permission for the app",
                        preferredStyle: UIAlertControllerStyle.alert)

                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        })

        let showKeypointsAction = UIAlertAction(title: "Show Keypoints", style: UIAlertActionStyle.default, handler: {
            action in
            self.imageView.image = self.bridge.drawKeypoints(image)
        })

        alert.addAction(defaultAction)
        alert.addAction(rememberAction)
        alert.addAction(showKeypointsAction)

        self.present(alert, animated: true, completion: nil)

        // Play voice label for the item with the highest score.
        if hasMatches {
            bridge.playVoiceLabel(matches[0]["id"])
        }
    }

    private func showError(message: String) {
        let alert = UIAlertView()
        alert.title = "Error"
        alert.message = message
        alert.addButton(withTitle: "Ok")
        alert.show()
    }
    
    @objc(operationComplete)
    public dynamic func operationComplete() {
        self.isBusy = false
    }

    // Used by `Feedback` to show frames currently being recorded
    // from the camera.
    @objc(showFrame:)
    public dynamic func showFrame(frame: UIImage) {
        NSLog("ViewController.showFrame %f x %f\n", frame.size.width * frame.scale, frame.size.height * frame.scale);
        self.imageView.image = frame;
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bridge = Bridge()
        self.isBusy = false;
        sViewController = self;

        self.registerSettingsBundle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func registerSettingsBundle() {
        let defaults = UserDefaults.standard

        defaults.set(500, forKey: "Matching:NumberOfFeatures")
    }
}

