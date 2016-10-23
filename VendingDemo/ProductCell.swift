//
//  ProductCell.swift
//  VendingDemo
//
//  Created by Cristina Escalante on 10/22/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

import Foundation
import UIKit
import YYWebImage

class ProductCell : UICollectionViewCell {
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!

  //  func configureCell(machine: Machine, image: UIImage) {
        
    func configureCell(product: Product!) {
        productNameLabel?.text = product.name
        productPriceLabel?.text = product.price
        productImageView.yy_setHighlightedImage(with: product.imageUrl, placeholder:nil)

    }
}
