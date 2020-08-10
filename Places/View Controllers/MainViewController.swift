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
    
    private let searchController = UISearchController(searchResultsController: nil)
     var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    private var placesOfType: [[Place]] = []
    private var newPlaceVC = NewPlaceViewController()
    private var ascendingSorting = true
    
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var reversedSortingButton: UIBarButtonItem!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    private var firstSegmentSelected: Bool {
        return segmentedControl.selectedSegmentIndex == 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        newPlaceVC.typesRealm = realm.objects(Type.self)
        places = realm.objects(Place.self)
        
        for type in newPlaceVC.typesRealm {
            sortedByTypes(type: type.type!)
        }
        
        // Setup the search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false 
        searchController.searchBar.placeholder = "Поиск"
        
        tableView.rowHeight = 85
      
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 0.588359559, green: 0.8278771763, blue: 0.9216118847, alpha: 1)]
        let titleTextAttributes2 = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentedControl.setTitleTextAttributes(titleTextAttributes2, for: .normal)
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // MARK: - Table view data sourse
    
    func numberOfSections(in tableView: UITableView) -> Int {
       
        if isFiltering {
            return 1
        } else if firstSegmentSelected {
            return placesOfType.count
        }
        return  1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            return filteredPlaces.count
        }
        if firstSegmentSelected {
            return placesOfType[section].count
        }
        
         return places.count
     }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell

        let place: Place
        
        if isFiltering {
            place = filteredPlaces[indexPath.row]
        } else  if firstSegmentSelected {
            place = placesOfType[indexPath.section][indexPath.row]
        } else {
            place = places[indexPath.row]
        }
        
        cell.nameLabel?.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.mainImage.image = UIImage(data: place.imageData!)
        cell.cosmosView.rating = place.rating

        return cell
     }
    
     // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        var place = places[indexPath.row]
        
        if firstSegmentSelected {
            place = placesOfType[indexPath.section][indexPath.row]
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            StorageManager.deleteObject(place)
            
            let section = indexPath.section
            let row = indexPath.row
            
            if self.firstSegmentSelected {
                self.placesOfType[section].remove(at: row)
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        view.backgroundColor = #colorLiteral(red: 0.588359559, green: 0.8278771763, blue: 0.9216118847, alpha: 1)
               
        let label = UILabel(frame: CGRect(x: 15, y: -6, width: view.frame.width, height: 40))
        
        label.font = UIFont(name: "Gilroy-Bold", size: 20)
        label.textColor = .white
        view.addSubview(label)
        
        if firstSegmentSelected {
            label.text = placesOfType[section][0].type
        } else {
            label.text = "Все места"
        }
         return view
    }
    
    @IBAction func changeSegment() {
        
        if firstSegmentSelected {
            reversedSortingButton.image = .none
            
            placesOfType = []
            
            for type in newPlaceVC.typesRealm {
                sortedByTypes(type: type.type!)
            }
        } else {
            reversedSortingButton.image = ascendingSorting ? #imageLiteral(resourceName: "AZ") : #imageLiteral(resourceName: "ZA")
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            
            var place: Place
           
            if firstSegmentSelected {
                place = placesOfType[indexPath.section][indexPath.row]
            } else if isFiltering {
                place = filteredPlaces[indexPath.row]
            } else {
                place = places[indexPath.row]
            }
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
        }
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        newPlaceVC.savePlace()
    
        changeSegment()
       
        tableView.reloadData()
    }
    
    // MARK: - Sorting methods
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        
       sorting()
        }
    
    @IBAction func reversedSorting(_ sender: Any) {
        
        ascendingSorting.toggle()
        
        reversedSortingButton.image = ascendingSorting ? #imageLiteral(resourceName: "AZ") : #imageLiteral(resourceName: "ZA")
        
        sorting()
    }
    
    private func sorting() {
        
        if segmentedControl.selectedSegmentIndex == 1 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else if segmentedControl.selectedSegmentIndex == 2 {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        
        tableView.reloadData()
    }
    
    private func sortedByTypes(type: String) {
        
        var array: [Place] = []
        
        for place in places {
            if place.type == type {
                array.append(place)
            }
        }
        if array.count > 0 {
            placesOfType.append(array)
        }
    }
}

// MARK: - Searching methods

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContentForSearch(searchController.searchBar.text!)
    }
    
    private func filterContentForSearch(_ searchText: String) {
        
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        
        tableView.reloadData()
    }
}

