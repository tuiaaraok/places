//
//  StorageManager.swift
//  Places
//
//  Created by Айсен Шишигин on 22/07/2020.
//  Copyright © 2020 Туйаара Оконешникова. All rights reserved.
//

import RealmSwift
let realm = try! Realm()

class StorageManager {
    
    static func saveObct ( _ place: Place) {
        
        try! realm.write {
            realm.add(place)
        }
    }
    
    static func deleteObject (_ place: Place) {
        
        try! realm.write {
            realm.delete(place)
        }
    }
    
    static func deleteType (_ type: Type) {
           
           try! realm.write {
               realm.delete(type)
           }
       }
    
    static func saveType (_ type: Type) {
        
        try! realm.write {
            realm.add(type)
        }
    }
    
    static func changeType (_ place: Place, newType: String) {
           
           try! realm.write {
            place.type = newType
           }
       }
}
