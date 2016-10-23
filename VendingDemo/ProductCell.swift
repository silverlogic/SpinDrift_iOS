//
//  ProductCell.swift
//  VendingDemo
//
//  Created by Cristina Escalante on 10/22/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

import Foundation
import UIKit

class ProductCell : UICollectionViewCell {
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!

  //  func configureCell(machine: Machine, image: UIImage) {
        
    func configureCell() {
        productNameLabel.text = "test name"
        productPriceLabel.text = "test price / test units"
        productImageView.image = UIImage(named:"background")
    }
}
