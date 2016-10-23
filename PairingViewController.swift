//
//  PairingViewController.swift
//  VendingDemo
//
//  Created by Cristina Escalante on 10/23/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

import UIKit
import CircularSpinner



class PairingViewController: UIViewController {

    @IBOutlet private var containerView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
        
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                completion()
            }
        }

    
     override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.isHidden = true
        statusLabel.text = "Success"
        CircularSpinner.show("Pairing...", animated: true,  type: .indeterminate, showDismissButton: true)
        CircularSpinner.setValue(0.1, animated: true)
        
        delayWithSeconds(5) {
            CircularSpinner.hide()
            self.statusLabel.isHidden = false

        }
    }

     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
        
}






