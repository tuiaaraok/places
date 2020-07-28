//
//  MapManager.swift
//  Places
//
//  Created by Айсен Шишигин on 28/07/2020.
//  Copyright © 2020 Туйаара Оконешникова. All rights reserved.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    
    private let regionInMeters = 1000.0
    private var directionsArray: [MKDirections] = []
    private var placeCoordinate: CLLocationCoordinate2D?
    
    func setupPlacemark(place: Place, mapView: MKMapView) { // позиционирует по местоположению заведения
           
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
               annotation.title = place.name
               annotation.subtitle = place.type
               
               guard let placemarkLocation = placemark?.location else { return } // метоположение маркера
               
               annotation.coordinate = placemarkLocation.coordinate
               self.placeCoordinate = placemarkLocation.coordinate
               
               mapView.showAnnotations([annotation], animated: true) // чтобы на карте отоброжались все аннотации
               mapView.selectAnnotation(annotation, animated: true) // чтобы выделить созданную аннотацию
           }
       }
    
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) { // будем проверять включена ли служба геолокации
           
           if CLLocationManager.locationServicesEnabled() { // если службы включены
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIdentifire: segueIdentifier)
            closure()
           } else {
               DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // позв отложить время вызова алерта секунд
                   self.showAlert(
                   title: "Ваше местоположение недоступно",
                   message: "Измените данные в настройках геолокации")
               }
           }
       }
    
    func checkLocationAuthorization(mapView: MKMapView, segueIdentifire: String) {
           
           switch CLLocationManager.authorizationStatus() {
           case .authorizedWhenInUse:
               mapView.showsUserLocation = true
               if segueIdentifire == "getAddress" { showUserLocation(mapView: mapView) }
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
    
    func showUserLocation(mapView: MKMapView) {
        
        if let location = locationManager.location?.coordinate { // если получается определить координаты пользователя, то определяем регион для позиционирования карты
                   let region = MKCoordinateRegion(center: location,
                                                   latitudinalMeters: regionInMeters,
                                                   longitudinalMeters: regionInMeters)
                   mapView.setRegion(region, animated: true)
               }
    }
    
    func getdirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
           
           // определ координаты местополож пользователя
           guard let location = locationManager.location?.coordinate else {
               showAlert(title: "Error", message: "Current location is not found")
               return
           }
           
           locationManager.startUpdatingLocation() // влючаем режим постоянного отслеживания местополож пользователя
           previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
           
           // запрос на проклудку маршрута
           guard let request = createDirectionsRequest(for: location) else {
               showAlert(title: "Error", message: "Destination is not fount")
               return
           }
           
           let directions = MKDirections(request: request)
        resetMApView(withNew: directions, mapView: mapView)
           
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
                   mapView.addOverlay(route.polyline) // полилайн содержит подробную геометриювсе маршрута
                   mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true) // фокусируем карту, чтобы путь от а до б был виден
                   
                   // расстояние и время в пути
                   let distance = String(format: "%.1f", route.distance / 1000)
                   let timeInterval = route.expectedTravelTime
                   
                   print(distance)
                   print(timeInterval)
               }
           }
       }
    
    // настройка запроса для построения маршрута, возвращает настроенный запрос
       
    func createDirectionsRequest(for coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
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
    
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
           
           guard let location = location else { return }
           let center = getCenterLocation(for: mapView)
           guard center.distance(from: location) > 50 else { return } // meters
    
          closure(center)
       }
    
    // метод отменяет все действующие маршруты и удаляет их с карты
    func resetMApView(withNew directions: MKDirections, mapView: MKMapView) {
           
           mapView.removeOverlays(mapView.overlays)
           directionsArray.append(directions)
           let _ = directionsArray.map {$0.cancel()}
           directionsArray.removeAll()
       }
       
    func getCenterLocation(for mapView: MKMapView) -> CLLocation { // возвращает текущ координаты центральной точки
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func showAlert (title: String, message: String?) {
           
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           let okAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
           
           alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
       }
}
