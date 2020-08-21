//
//  CustomTableViewCell.swift
//  Places
//
//  Created by Айсен Шишигин on 22/07/2020.
//  Copyright © 2020 Туйаара Оконешникова. All rights reserved.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {

    @IBOutlet var mainImage: UIImageView! {
        didSet {
            mainImage.layer.cornerRadius = (mainImage?.frame.size.height)! / 2
            mainImage.clipsToBounds = true
        }
    }
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var cosmosView: CosmosView! {
        didSet {
            cosmosView.settings.updateOnTouch = false 
        }
    }
    
    func configureCell( _ indexPath: IndexPath, place: Place) {
           
           nameLabel?.text = place.name
           locationLabel.text = place.location
           typeLabel.text = place.type
           mainImage.image = UIImage(data: place.imageData!)
           cosmosView.rating = place.rating
          }
}
