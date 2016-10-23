//
//  PairingViewController.swift
//  VendingDemo
//
//  Created by Cristina Escalante on 10/23/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

import UIKit
import CircularSpinner
import VendingSDK
import ObjectMapper
import YouTubePlayer


protocol VendingFlow2 : class {
    func flowComplete()
    func showReceipt(machineName: String, quantity: Int, amount: String, cardMaskedPan: String)
}


class PairingViewController: UIViewController {
    @IBOutlet weak var statusLabel: UILabel!
    @IBAction func reconnectButton(_ sender: UIButton) {
        connect()
    }
    @IBOutlet var videoPlayer: YouTubePlayerView!
    
    weak var delegate: VendingFlow2?
    
    let settings = Settings.sharedInstance
    var vendController: VendController!
    var machine: Machine!
    
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                completion()
            }
        }

     override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.isHidden = true
        connect()
        loadVideo()
    }

     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Private methods
    func connect() {
//        if let resultType = settings.resultType {
            print("Using fake bluetooth")
//            vendController = VendController(config: resultType)
//            vendController = VendController(config: settings.resultType!)
//        } else {
            print("Using bluetooth dongle")
        //hardcoded for testing
            vendController = VendController(deviceModel: machine.model, deviceSerial: machine.serial, serviceId: machine.serviceId, maxAmount: Amount(amount: 1000.0))
//        }
        
                vendController.delegate = self
        do {
            try vendController.connect()
//          self.statusLabel.text = NSLocalizedString("Pairing with the vending machine...", comment: "")
            CircularSpinner.show("Pairing...", animated: true,  type: .indeterminate, showDismissButton: true)
            CircularSpinner.setValue(0.1, animated: true)
            statusLabel.isHidden = false
        } catch {
            print(error)
        }
        CircularSpinner.hide()
    }
}

extension PairingViewController : VendControllerDelegate {
    func connected() {
        print("Connected")
        self.statusLabel.isHidden = true
        CircularSpinner.show("Pick Item...", animated: true,  type: .indeterminate, showDismissButton: true)
        CircularSpinner.setValue(0.1, animated: true)
        }
    
    func disconnected(_ error: VendError) {
        print("Connection disconnected: \(error)")
        self.statusLabel.text = "Disconnected"
        switch error {
        case .connectionTimedOut:
            print("Timeout!")
            self.statusLabel.text = "Timeout"
        case .invalidDeviceResponse:
            self.statusLabel.text = "Invalid Response"
            fallthrough
        case .bluetoothNotAvailable:
            self.statusLabel.text = "No Bluetooth"
            fallthrough
        default:
            print("fail")
            self.statusLabel.text = "Error"
        }
        self.vendController.delegate = nil
        self.vendController = nil
    }
    
    func authRequest(_ amount: NSNumber, token: String?) {
        print("Auth requested")
        self.statusLabel.isHidden = true
        CircularSpinner.show("Authorizing", animated: true,  type: .indeterminate, showDismissButton: true)
        CircularSpinner.setValue(0.1, animated: true)
        
        // charity case
        if amount.floatValue < 500 {
            CircularSpinner.hide()
            playVideo()
            return
        }
        if amount.floatValue == 1200 {
            CircularSpinner.hide()
            promptForBirthday()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
            CircularSpinner.show("Paying", animated: true,  type: .indeterminate, showDismissButton: true)
            self?.vendController.approveAuth("dummyPayload")
        }
    }
    
    func processStarted() {
        CircularSpinner.show("Processing", animated: true,  type: .indeterminate, showDismissButton: true)
        print("Process started")
    }
    
    func processCompleted(_ finalAmount: NSNumber, processStatus: ProcessStatus, completedPayload: String) {
        print("Process completed")
        CircularSpinner.show("Complete", animated: true,  type: .indeterminate, showDismissButton: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
            if processStatus == .success {
                CircularSpinner.hide()
                // Show receipt
                let amount = String(format: "%0.2f", finalAmount.floatValue)
//                self?.delegate?.showReceipt(machineName: self?.machine.name ?? "", quantity: 1, amount: "USD \(amount)", cardMaskedPan: "**** 4567")
                self?.statusLabel.isHidden = false
                self?.statusLabel.text = "Using Bluetooth";
                self?.delegate?.flowComplete()
            } else {
                CircularSpinner.hide()
                self?.statusLabel.isHidden = false
                self?.statusLabel.text = "Vending Failed";
            }
        }
    }
    
    func invalidProduct() {
        print("Invalid product requested")
    }
    
    func timeoutWarning() {
        print("Timeout warning")
        
        self.vendController.keepAlive()
    }
    
    func playVideo(videoURL: URL = URL(string: "https://www.youtube.com/embed/H_Gn6THezTU")!) {
        videoPlayer.isHidden = false
        videoPlayer.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.videoPlayer.isHidden = true
            self.videoPlayer.pause()
            CircularSpinner.show("Sponsored", animated: true,  type: .indeterminate, showDismissButton: true)
            self.vendController.approveAuth("dummyPayload")
        }
    }
    
    func loadVideo(videoId: String = "H_Gn6THezTU") {
//        DispatchQueue.main.async {
        videoPlayer.loadVideoID(videoId)
//    }
    }
    
    func promptForBirthday() {
        let alert = UIAlertController.init(title: "Verification", message: "Please verify your date of birth", preferredStyle: UIAlertControllerStyle.alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = "7/8/1991"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (_) in
            let textField = alert.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField.text)")
            CircularSpinner.show("Verified", animated: true,  type: .indeterminate, showDismissButton: true)
            self.vendController.approveAuth("dummyPayload")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
            CircularSpinner.show("Canceled", animated: true,  type: .indeterminate, showDismissButton: true)
            self.vendController.disapprove()
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)

    }
}





