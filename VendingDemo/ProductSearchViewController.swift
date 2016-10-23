//
//  ProductSearchViewController.swift
//  VendingDemo
//
//  Created by Cristina Escalante on 10/22/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

import UIKit
import CoreLocation

let CellIdentifier = "SearchCell"
let images = [#imageLiteral(resourceName: "Vending-1"), #imageLiteral(resourceName: "Vending-2"), #imageLiteral(resourceName: "Vending-3"), #imageLiteral(resourceName: "Vending-4")]


class ProductSearchViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pairingButton: UIButton!
//    @IBOutlet weak var vendingMap: MKMapView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
// MARK: - Cell
class VendingCell : UITableViewCell {
    @IBOutlet weak var machineImageView: UIImageView!
    @IBOutlet weak var machineNameLabel: UILabel!
    @IBOutlet weak var machineDistanceLabel: UILabel!
    @IBOutlet weak var machineAddressLabel: UILabel!
    
    func configureCell(machine: Machine, image: UIImage) {
        machineNameLabel.text = machine.name
        machineDistanceLabel.text = machine.formatDistance()
        machineAddressLabel.text = machine.address
        machineImageView.image = image
    }
}

