//
//  TypeTableViewCell.swift
//  Places
//
//  Created by Туйаара Оконешникова on 31/07/2020.
//  Copyright © 2020 Туйаара Оконешникова. All rights reserved.
//

import UIKit

class TypeTableViewCell: UITableViewCell {

    @IBOutlet var deleteButton: UIButton!
    
    func configure(type: String) {
        textLabel?.text = type
        textLabel?.font = UIFont(name: "Gilroy-Medium", size: 17)
    }
}
