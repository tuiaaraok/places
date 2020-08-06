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
    var textViewPlaceholderText: String = "Добавьте описание"
    var pickerView = UIPickerView()
    var types = ["Ресторан", "Кафе", "Путешествия", "Приключение", "Событие"]
    var typesRealm: Results<Type>! 

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
        
        pickerView.delegate = self
        pickerView.dataSource = self
        placeType.inputView = pickerView
        pickerView.backgroundColor = #colorLiteral(red: 0.6277194619, green: 0.8501312137, blue: 0.9382870197, alpha: 1)
        
        
        
        setupTextView()
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: tableView.frame.size.width,
                                                         height: 1))
        saveButton.isEnabled = false // кнопка неактивна
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged) // следит а тем, заполнено ли текстовое поле или нет. в заисимости от этого блок кнопки
        setupEditScreen()
        
        cosmosView.settings.fillMode = .full
        cosmosView.didTouchCosmos = { rating in
            self.currentRating = rating
        }
        
       setupNavigationBarItem()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewWillAppear(anim)
//    }
       
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            let actionSheet = UIAlertController(
                title: nil,
                message: nil,
                preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Камера", style: .default) { (_) in
                self.chooseImagePicker(source: .camera)
            }
            
            let photo = UIAlertAction(title: "Галерея", style: .default) { (_) in
                self.chooseImagePicker(source: .photoLibrary)
            }
            
            let cancel = UIAlertAction(title: "Отмена", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true) // убираем выделение
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
        placeType.text = typesRealm.last?.type
        pickerView.reloadAllComponents()
    }
    
       func savePlace() {
        
        let image = imageIsChanged ? placeImage.image : #imageLiteral(resourceName: "Шар")
        let imageData = image?.pngData()
           
        let newPlace = Place(name: placeName.text!,
                            location: placeLocation.text,
                            type: placeType.text!.isEmpty ? "Разное" : placeType.text,
                            imageData: imageData,
                            rating: currentRating,
                            placeDescription: placeDescription.text)//Double(ratingControl.rating))
           
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
            cosmosView.rating = currentPlace.rating//Int(currentPlace.rating)
            placeDescription.text = currentPlace?.placeDescription
            placeDescription.textColor = .black
        }
    }
    
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
    
    private func setupNavigationBarItem() {
        
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Gilroy-Medium", size: 17)!], for: .normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Gilroy-Medium", size: 17)!], for: .normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Gilroy-Medium", size: 17)!], for: .disabled)
    }
    
    @IBAction func chooseType() {
        
        if placeType.placeholder == textViewPlaceholderText {
            placeType.willRemoveSubview(pickerView)
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - Text field delegate

extension NewPlaceViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // скрытие по тапу на ячейку
        return true
    }
    
    @objc private func textFieldChanged() {
        
        if placeName.text?.isEmpty == false  { // если строка заполнена, кнопка активизируется
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}

// MARK: - Text view delegate

extension NewPlaceViewController: UITextViewDelegate {
   func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
          if text == "\n" {
              textView.resignFirstResponder()
              return false
          }
          return true
   }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceholderText {
            textView.text = ""
            textView.textColor = .black
        } else if !textView.text.isEmpty {
             textView.textColor = .black
        }
    }
    
    private func setupTextView() {
        
        placeDescription.delegate = self
        placeDescription.text = textViewPlaceholderText
        placeDescription.textColor = .lightGray
        placeDescription.font = UIFont(name: "Gilroy-Medium", size: 17)
        placeDescription.returnKeyType = .done
    }
}

// MARK: - Work with image

extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) { // если источник выбора изобр будет достуаен
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true // позволит редактировать выбранное изобр, например масшаб
            imagePicker.sourceType = source //source  тип источника для выбранного изобр
            present(imagePicker, animated: true)
        }
    }
    
    // присваиваем изобр
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        placeImage.image = info[.editedImage] as? UIImage // editedImage позвол исп отредакт вариант изобр
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        
        imageIsChanged = true
        dismiss(animated: true)
    }
}

extension NewPlaceViewController: MapViewControllerDelegate {
    func getaddress(_ address: String?) {
        placeLocation.text = address
    }
}

// MARK: - UIPickerViewDataSource

extension NewPlaceViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        typesRealm.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return typesRealm[row].type
    }
    
// MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        placeType.text = typesRealm[row].type
        placeType.resignFirstResponder()
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let title = UILabel()
            title.font = UIFont(name: "Gilroy-Bold", size: 22)
            title.textColor = UIColor.white
        title.text =  typesRealm[row].type
            title.textAlignment = .center

        return title
    }
}

// MARK: - Bonsai Controller Delegate
extension NewPlaceViewController: BonsaiControllerDelegate {
    
    // return the frame of your Bonsai View Controller
    func frameOfPresentedView(in containerViewFrame: CGRect) -> CGRect {
        
        return CGRect(origin: CGPoint(x: 0, y: containerViewFrame.height / 2), size: CGSize(width: containerViewFrame.width, height: containerViewFrame.height / (2)))
    }
    
    // return a Bonsai Controller with SlideIn or Bubble transition animator
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    
        /// With Background Color ///
    
        // Slide animation from .left, .right, .top, .bottom
        return BonsaiController(fromDirection: .bottom, backgroundColor: UIColor(white: 0, alpha: 0.5), presentedViewController: presented, delegate: self)
        
        // or Bubble animation initiated from a view
        //return BonsaiController(fromView: yourOriginView, backgroundColor: UIColor(white: 0, alpha: 0.5), presentedViewController: presented, delegate: self)
    
    
        /// With Blur Style ///
        
        // Slide animation from .left, .right, .top, .bottom
        //return BonsaiController(fromDirection: .bottom, blurEffectStyle: .light, presentedViewController: presented, delegate: self)
        
        // or Bubble animation initiated from a view
        //return BonsaiController(fromView: yourOriginView, blurEffectStyle: .dark,  presentedViewController: presented, delegate: self)
    }
}
