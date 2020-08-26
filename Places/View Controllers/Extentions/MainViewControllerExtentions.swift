//
//  MainViewControllerExtentions.swift
//  Places
//
//  Created by Айсен Шишигин on 26/08/2020.
//  Copyright © 2020 Туйаара Оконешникова. All rights reserved.
//

import UIKit

// MARK: - Searching settings

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearch(searchController.searchBar.text!)
    }
    
    private func filterContentForSearch(_ searchText: String) {
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
}

// MARK: - Setup table view cell and swipe delete action

extension MainViewController {
    
    func setupSegmentedControl() {
           
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 0.588359559, green: 0.8278771763, blue: 0.9216118847, alpha: 1)]
        let titleTextAttributes2 = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentedControl.setTitleTextAttributes(titleTextAttributes2, for: .normal)
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
    }
    
    func setupSearchController() {
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func createSwipeDeleteAction(_ indexPath: IndexPath, _ place: Place, _ tableView: UITableView) -> UISwipeActionsConfiguration? {
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
    
    func getPlaceForCell( _ indexPath: IndexPath) -> Place{
     
     let place: Place
     if isFiltering {
         place = filteredPlaces[indexPath.row]
     } else  if firstSegmentSelected {
         place = placesOfType[indexPath.section][indexPath.row]
     } else {
         place = places[indexPath.row]
     }
     return place
    }
    
    func setupViewForHeaderInSection(_ view: UIView, _ section: Int) {
        
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
    }
}
