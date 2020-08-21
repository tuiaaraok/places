//
//  Extention NewPlaceViewController.swift
//  Places
//
//  Created by Айсен Шишигин on 15/08/2020.
//  Copyright © 2020 Туйаара Оконешникова. All rights reserved.
//

import Foundation
import UIKit

extension NewPlaceViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldChanged() {
        
        if placeName.text?.isEmpty == false  {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
               topItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
           }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
       
    func setupNavigationBarItem() {
           
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Gilroy-Medium", size: 17)!], for: .normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Gilroy-Medium", size: 17)!], for: .normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Gilroy-Medium", size: 17)!], for: .disabled)
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
             textView.textColor = .lightGray
        }
    }
    
    func setupTextView() {
        
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
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        placeImage.image = info[.editedImage] as? UIImage
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
    
    func setupPickerView() {
        typePickerView.delegate = self
        typePickerView.dataSource = self
        typePickerView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        placeType.inputView = typePickerView
    }
}

// MARK: - Action sheet
extension NewPlaceViewController {
    
     func showActionSheet() {
        
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
    }
}
