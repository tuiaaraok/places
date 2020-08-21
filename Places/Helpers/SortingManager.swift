//
//  SortingManager.swift
//  Places
//
//  Created by Айсен Шишигин on 20/08/2020.
//  Copyright © 2020 Туйаара Оконешникова. All rights reserved.
//

import Foundation
import RealmSwift

class SortingManager {
    
    func sorting(_ places: Results<Place>!, _ selectedSegment: Int, _ ascendingSorting: Bool) -> Results<Place> {
        var sortedPlaces: Results<Place>!
        
        switch selectedSegment {
        case 0:
            sortedPlaces = places
        case 1:
            sortedPlaces = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        case 2:
            sortedPlaces = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        default:
            break
        }
        return sortedPlaces
    }
    
    func sortedByTypes(type: String, _ places: Results<Place>!) -> [[Place]] {
     
        var array: [Place] = []
        var placesOfType: [[Place]] = []
        
        for place in places {
            if place.type == type {
                array.append(place)
            }
        }
        if array.count > 0 {
            placesOfType.append(array)
        }
        return placesOfType
    }
}
