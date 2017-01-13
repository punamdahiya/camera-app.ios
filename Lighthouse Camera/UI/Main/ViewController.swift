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
      if self.isBusy {
        bridge.onStopCapture()
        self.isBusy = false
      } else {
        bridge.onIdentifyObject();
        self.isBusy = true
      }
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message,
            preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default))

        self.present(alert, animated: true, completion: nil)
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

      // Establish audio session.
      // FIXME: We should probably start session only when we really need it and stop when we don't.
      let session = AVAudioSession.sharedInstance()
      try! session.setCategory(AVAudioSessionCategoryPlayAndRecord,
          with: AVAudioSessionCategoryOptions.defaultToSpeaker)
      try! session.setActive(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func registerSettingsBundle() {
        let defaults = UserDefaults.standard

        defaults.set(500, forKey: "Matching:NumberOfFeatures")
    }
}

