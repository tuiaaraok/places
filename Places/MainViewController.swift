//
//  ViewController.swift
//  Places
//
//  Created by Айсен Шишигин on 22/07/2020.
//  Copyright © 2020 Туйаара Оконешникова. All rights reserved.
//

import UIKit
import RealmSwift

class   MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
 
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var reversedSortingButton: UIBarButtonItem!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    var places: Results<Place>!
    var ascendingSorting = true


    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 85
        
        places = realm.objects(Place.self)
    }
    
    
    // MARK: - Table view data sourse
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
     }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell

        let place = places[indexPath.row]


        cell.nameLabel?.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.mainImage.image = UIImage(data: place.imageData!)

        cell.mainImage?.layer.cornerRadius = (cell.mainImage?.frame.size.height)! / 2
        cell.mainImage?.clipsToBounds = true

        return cell
     }
    
    
     // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let place = places[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Удалить") { (_, _) in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return [deleteAction]
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            let place = places[indexPath.row]
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
            
            
        }
    }
    
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        newPlaceVC.savePlace()
       
        tableView.reloadData()
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        
       sorting()
        }
    
    @IBAction func reversedSorting(_ sender: Any) {
        
        ascendingSorting.toggle()
        
        if ascendingSorting {
            reversedSortingButton.image = #imageLiteral(resourceName: "AZ")
        } else {
            reversedSortingButton.image = #imageLiteral(resourceName: "ZA")
        }
        
        sorting()
        
    }
    
    private func sorting() {
        
        if segmentedControl.selectedSegmentIndex == 0{ // если нулевой сегмент
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting) // в завис от того, какое знач имеет свойство, сортировка будет  другой
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        
        tableView.reloadData()
    }
}

