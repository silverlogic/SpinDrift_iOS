//
//  MachineInfoViewController.swift
//  VendingDemo
//
//  Created by Muhammad Azeem on 9/27/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MachineInfoViewController : UIViewController {
    @IBOutlet weak var vendingTypeLabel: UILabel!
    @IBOutlet weak var machineDescriptionLabel: UILabel!
    @IBOutlet weak var machineDistanceLabel: UILabel!
    @IBOutlet weak var machineAddressLabel: UILabel!
    @IBOutlet weak var showOnMapButton: UIButton!
    @IBOutlet weak var pairButton: UIButton!
    
    var machine: Machine? {
        didSet {
            configureView()
        }
    }
    
    var pairCallback: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Action methods
    @IBAction func showOnMapButtonPressed(sender: UIButton) {
        guard let machine = machine else {
            return
        }
        
        let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(machine.latitude), CLLocationDegrees(machine.longitude))
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = machine.name
        // TODO: Fix issue
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    @IBAction func pairButtonPressed(_ sender: AnyObject) {
        if let pairCallback = pairCallback {
            pairCallback()
        }
    }
    
    // MARK: - Private Methods
    func configureView() {
        guard let machine = self.machine else {
            self.vendingTypeLabel.text = "<INVALID DEVICE>"
            self.machineDescriptionLabel.text = "<INVALID DEVICE>"
            self.machineAddressLabel.text = "<INVALID DEVICE>"
            self.machineDistanceLabel.text = "<INVALID DEVICE>"
            
            self.showOnMapButton.isEnabled = false
            self.pairButton.isEnabled = false
            
            return
        }
        
        self.vendingTypeLabel.text = machine.name
        self.machineDescriptionLabel.text = "Fruit juices, soft drinks and  tea drinks are available for sale"
        self.machineAddressLabel.text = machine.address
        self.machineDistanceLabel.text = machine.formatDistance()
        
        self.showOnMapButton.isEnabled = true
        self.pairButton.isEnabled = true
    }
}
