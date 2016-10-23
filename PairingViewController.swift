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


protocol VendingFlow2 : class {
    func flowComplete()
    func showReceipt(machineName: String, quantity: Int, amount: String, cardMaskedPan: String)
}


class PairingViewController: UIViewController {
    @IBOutlet weak var statusLabel: UILabel!
    @IBAction func reconnectButton(_ sender: UIButton) {
        connect()
    }
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
    }

     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Private methods
    func connect() {
//        if let resultType = settings.resultType {
//            print("Using fake bluetooth")
//            vendController = VendController(config: resultType)
//        } else {
            print("Using bluetooth dongle")
        //hardcoded for testing
            vendController = VendController(deviceModel: "1", deviceSerial: "1018", serviceId: "fff0", maxAmount: Amount(amount: 10.0))
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
}







