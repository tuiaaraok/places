//
//  PlaceModel.swift
//  Places
//
//  Created by Айсен Шишигин on 22/07/2020.
//  Copyright © 2020 Туйаара Оконешникова. All rights reserved.
//

import RealmSwift

class Place: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
    @objc dynamic var date = Date()
    @objc dynamic var rating = 0.0
    @objc dynamic var placeDescription: String?
    
    convenience init (name: String, location: String?, type: String?, imageData: Data?, rating: Double, placeDescription: String?) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        self.rating = rating
        self.placeDescription = placeDescription
    }
}

class Type: Object {
    @objc dynamic var type: String?
    
    convenience init(type: String?) {
        self.init()
        self.type = type
    }
}
