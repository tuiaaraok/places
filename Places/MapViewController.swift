//
//  MapViewController.swift
//  Places
//
//  Created by Айсен Шишигин on 24/07/2020.
//  Copyright © 2020 Туйаара Оконешникова. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

 protocol MapViewControllerDelegate {
    func getaddress(_ address: String?)
}

class MapViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapPinimage: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var goButton: UIButton!
    
    var mapViewControllerDelegate: MapViewControllerDelegate?
    
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    let regionInMeters = 10000.0
    var incomeSegueIdentifier = ""
    var placeCoordinate: CLLocationCoordinate2D?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressLabel.text = ""
        mapView.delegate = self
        setupMapView()
        checkLocationServices()
    }
    
    @IBAction func centerViewInUserLocation() {
        
        showUserLocation()
    }
    
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getaddress(addressLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction func goButtonPressed() {
        getdirections()
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    private func setupMapView() {
        
        goButton.isHidden = true
        
        if incomeSegueIdentifier == "showPlace" {
            setupPlacemark()
            mapPinimage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }
    
    private func setupPlacemark() { // позиционирует по местоположению заведения
        
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder() // отвечает за преобразование географ координат
        // преобразует стринговый адрес в географический
        geocoder.geocodeAddressString(location) { (placemarks, error) in // placemark - несколько адресов по названию заведения
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation() // описать точку на карте
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else { return } // метоположение маркера
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true) // чтобы на карте отоброжались все аннотации
            self.mapView.selectAnnotation(annotation, animated: true) // чтобы выделить созданную аннотацию
        }
    }
    
    private func checkLocationServices() { // будем проверять включена ли служба геолокации
        
        if CLLocationManager.locationServicesEnabled() { // если службы включены
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // позв отложить время вызова алерта секунд
                self.showAlert(
                title: "Ваше местоположение недоступно",
                message: "Измените данные в настройках геолокации")
            }
        }
    }
    
    private func setupLocationManager() { // опр точность местоположения пользователя
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // будем вып проверку статуса пользов
    private func checkLocationAuthorization() {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "getAddress" { showUserLocation() }
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Ваше местоположение недоступно",
                    message: "Измените данные в настройках геолокации")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is avaliable")
        }
    }
    
    private func showUserLocation() {
        
        if let location = locationManager.location?.coordinate { // если получается определить координаты пользователя, то определяем регион для позиционирования карты
                   let region = MKCoordinateRegion(center: location,
                                                   latitudinalMeters: regionInMeters,
                                                   longitudinalMeters: regionInMeters)
                   mapView.setRegion(region, animated: true)
               }
    }
    
    private func getdirections() {
        
        // определ координаты местополож пользователя
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        // запрос на проклудку маршрута
        guard let request = createDirectionsRequest(for: location) else {
            showAlert(title: "Error", message: "Destination is not fount")
            return
        }
        
        let directions = MKDirections(request: request)
        
        directions.calculate { (response, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                self.showAlert(title: "Error", message: "Direction is not avaliable")
                return
            }
            
             // routes нужен для построения неск маршрутов
            for route in response.routes {
                self.mapView.addOverlay(route.polyline) // полилайн содержит подробную геометриювсе маршрута
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true) // фокусируем карту, чтобы путь от а до б был виден
                
                // расстояние и время в пути
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                
                print(distance)
                print(timeInterval)
            }
            
        }
    }
    
    // настройка запроса для построения маршрута, возвращает настроенный запрос
    
    private func createDirectionsRequest(for coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true // позволит построить неск маршрутов
        
        return request
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation { // возвращает текущ координаты центральной точки
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showAlert (title: String, message: String?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    
    //метод делает баннер по аннотации
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil } //если маркер это местоположение пользователя, то выходим
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true // отобразить аннотацию в виде баннера
        }
        
        if let imageData = place.imageData {
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) { // вызывается каждый раз при смене отображаемого региона
        
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        // должны преобразовать геогр данные в строку
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                
                if streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                     self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }
    
    // настраиваем линию маршрута
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolygonRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) { // вызывается при каждом изм статуса авторизации для исп служб геолокации
        checkLocationAuthorization()
    }
}



