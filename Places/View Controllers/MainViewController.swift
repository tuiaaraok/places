//
//  ViewController.swift
//  Places
//
//  Created by Туйаара Оконешникова on 22/07/2020.
//  Copyright © 2020 Туйаара Оконешникова. All rights reserved.
//

import UIKit
import RealmSwift

class   MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var places: Results<Place>!
    var filteredPlaces: Results<Place>!
    var ascendingSorting = true
    var placesOfType: [[Place]] = []
    let searchController = UISearchController(searchResultsController: nil)
   
    private var newPlaceVC = NewPlaceViewController()
    private var sortingManager = SortingManager()
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    var firstSegmentSelected: Bool {
        return segmentedControl.selectedSegmentIndex == 0
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var reversedSortingButton: UIBarButtonItem!
    @IBOutlet var segmentedControl: UISegmentedControl!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newPlaceVC.typesRealm = realm.objects(Type.self)
        places = realm.objects(Place.self)
        
        for type in newPlaceVC.typesRealm {
            placesOfType += sortingManager.sortedByTypes(type: type.type!, places)
        }
        
        setupSearchController()
        setupSegmentedControl()
        
        tableView.rowHeight = 85
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
        
        cell.configureCell(indexPath, place: getPlaceForCell(indexPath))
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
        
        return createSwipeDeleteAction(indexPath, place, tableView)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        setupViewForHeaderInSection(view, section)
         return view
    }
    
    @IBAction func changeSegment() {
        
        if firstSegmentSelected {
            reversedSortingButton.image = .none

            placesOfType = []
            
            for type in newPlaceVC.typesRealm {
                placesOfType += sortingManager.sortedByTypes(type: type.type!, places)
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
    
    // MARK: - Sorting IBActions
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        places = sortingManager.sorting(places, segmentedControl.selectedSegmentIndex, ascendingSorting)
        tableView.reloadData()
        }
    
    @IBAction func reversedSorting(_ sender: Any) {
        
        ascendingSorting.toggle()
        reversedSortingButton.image = ascendingSorting ? #imageLiteral(resourceName: "AZ") : #imageLiteral(resourceName: "ZA")
        places = sortingManager.sorting(places, segmentedControl.selectedSegmentIndex, ascendingSorting)
        tableView.reloadData()
    }
}
