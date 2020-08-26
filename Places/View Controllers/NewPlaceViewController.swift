//
//  NewPlaceViewController.swift
//  Places
//
//  Created by Айсен Шишигин on 22/07/2020.
//  Copyright © 2020 Туйаара Оконешникова. All rights reserved.
//

import UIKit
import Cosmos
import RealmSwift
import BonsaiController
 
class NewPlaceViewController: UITableViewController {
    
    var currentPlace: Place!
    var imageIsChanged = false
    var currentRating = 0.0
    var typePickerView = UIPickerView()
    var textViewPlaceholderText: String = "Добавьте описание"
    var typesRealm: Results<Type>!
    var types = ["Ресторан", "Кафе", "Приключения", "Путешествия", "Событие"]


    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var placeName: UITextField!
    @IBOutlet var placeLocation: UITextField!
    @IBOutlet var placeType: UITextField!
    @IBOutlet var ratingControl: RatingControl!
    @IBOutlet var cosmosView: CosmosView!
    @IBOutlet var placeDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        typesRealm = realm.objects(Type.self)
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: tableView.frame.size.width,
                                                         height: 1))
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
      
        cosmosView.settings.fillMode = .full
        cosmosView.didTouchCosmos = { rating in
            self.currentRating = rating
        }
        
        setupTextView()
        setupEditScreen()
        setupNavigationBarItem()
        setupPickerView()
    }
       
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            showActionSheet()
        } else {
            view.endEditing(true)
        }
    }
    
    //MARK: - Navigation
       
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           
      if let identifier = segue.identifier,
        let mapVC = segue.destination as? MapViewController {
        mapVC.incomeSegueIdentifier = identifier
        mapVC.mapViewControllerDelegate = self
           
        if identifier == "showPlace" {
            mapVC.place.name = placeName.text!
            mapVC.place.location = placeLocation.text
            mapVC.place.type = placeType.text
            mapVC.place.imageData = placeImage.image?.pngData()
            mapVC.place.placeDescription = placeDescription.text
        }
    }
           
        if segue.destination is TypeEditSmallViewController {
            segue.destination.transitioningDelegate = self
            segue.destination.modalPresentationStyle = .custom
        }
    }

    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        guard let newPlaceVC = segue.source as? TypeEditSmallViewController else { return }
        placeType.text = newPlaceVC.typeTextField.text!

        typePickerView.reloadAllComponents()
    }
    
    func savePlace() {

        let image = imageIsChanged ? placeImage.image : #imageLiteral(resourceName: "Шар")
        let imageData = image?.pngData()

        let newPlace = Place(name: placeName.text!,
                            location: placeLocation.text,
                            type: placeType.text!.isEmpty ? "Разное" : placeType.text,
                            imageData: imageData,
                            rating: currentRating,
                            placeDescription: placeDescription.text)

        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.type = newPlace.type
                currentPlace?.location = newPlace.location
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
                currentPlace?.placeDescription = newPlace.placeDescription
            }
        } else {
            StorageManager.saveObct(newPlace)
        }
    }
    
    private func setupEditScreen() {
        if currentPlace != nil {
            setupNavigationBar()
            imageIsChanged = true
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            cosmosView.rating = currentPlace.rating
            placeDescription.text = currentPlace?.placeDescription
            placeDescription.textColor = .black
        }
    }
    
    @IBAction func chooseType() {
        
        if placeType.placeholder == textViewPlaceholderText {
            placeType.willRemoveSubview(typePickerView)
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
}
