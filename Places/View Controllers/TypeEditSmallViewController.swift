//
//  TypeEditSmallViewController.swift
//  Places
//
//  Created by Айсен Шишигин on 31/07/2020.
//  Copyright © 2020 Туйаара Оконешникова. All rights reserved.
//

import UIKit

class TypeEditSmallViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var typeTextField: UITextField!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var stackViewBottomConstraint: NSLayoutConstraint!
    
    var newPlaceVC = NewPlaceViewController()
    var mainVC = MainViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newPlaceVC.typesRealm = realm.objects(Type.self)
        mainVC.places = realm.objects(Place.self)
        addButton.isEnabled = false
        typeTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        typeTextField.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
    
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        addButton.layer.cornerRadius = 10
        typeTextField.layer.cornerRadius = 10
    }
    
    @IBAction func addButtonPressed() {
        
        guard let newType = typeTextField.text else { return }
        StorageManager.saveType(Type(type: newType))
        
        tableView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }

    @objc func keyBoardWillShow(notification: Notification) {
        
        if let userInfo = notification.userInfo as? Dictionary<String, AnyObject> {
            let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey]
            let keyBoardRect = frame?.cgRectValue
            if let keyBoardHeight = keyBoardRect?.height {
                self.stackViewBottomConstraint.constant = keyBoardHeight
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    @objc func keyBoardWillHide(notification: Notification){
        
        self.stackViewBottomConstraint.constant = 10.0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc private func textFieldChanged() {
           
           if typeTextField.text?.isEmpty == false  { 
               addButton.isEnabled = true
           } else {
               addButton.isEnabled = false
           }
       }
}

 // MARK: - Table vie data source

extension TypeEditSmallViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newPlaceVC.typesRealm.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "typeCell", for: indexPath) as! TypeTableViewCell

        cell.configure(type: newPlaceVC.typesRealm[indexPath.row].type!)
        
        if let deleteButton = cell.deleteButton {
            deleteButton.addTarget(self, action: #selector(deleteRow(_ :)), for: .touchUpInside)
        }
        
        return cell
    }
    
    @objc func deleteRow(_ sender: UIButton) {
        
        let point = sender.convert(CGPoint.zero, to: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        
        for place in mainVC.places {
            if place.type == newPlaceVC.typesRealm[indexPath.row].type {
                StorageManager.changeType(place, newType: "Разное")
            }
        }
        StorageManager.deleteType(newPlaceVC.typesRealm[indexPath.row])
        tableView.reloadData()
    }
}
