//
//  ViewController.swift
//  FindWay_Abhishek_C0769778
//
//  Created by user166476 on 6/10/20.
//  Copyright © 2020 user166476. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    // Outlets and variables
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnZoomIn: UIButton!
    @IBOutlet weak var btnZoomOut: UIButton!
    @IBOutlet weak var btnFindMyWay: UIButton!
    @IBOutlet weak var segmentType: UISegmentedControl!
    
    var locationManager = CLLocationManager()
    var aLat: CLLocationDegrees??
    var aLon: CLLocationDegrees??
    var location: CLLocation?
    var favoritePlaces: [FavoritePlace]?
    var favoriteAddress: String?
    var favLocation: CLLocation?
    let defaults = UserDefaults.standard
    
    var lat: Double = 0.0
    var long: Double = 0.0
    var drag: Bool = false
    
        override func viewDidLoad()
        {
            super.viewDidLoad()
            
            mapView.delegate = self
            locationManager.delegate = self
            
            //Permission and finding inital location
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.startUpdatingLocation()
            
            //Map interactivity
            mapView.showsUserLocation = true
            mapView.isZoomEnabled = false
            
            //Added double tap gesture
            addDoubleTap()
            loadData()
            
        }
        func getDataFilePath() -> String
        {
            //Getting path to txt file
            let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let filePath = documentPath.appending("/places-data.txt")
            return filePath
        }
            
        func loadData()
        {
            favoritePlaces = [FavoritePlace]()
                
            let filePath = getDataFilePath()
                
            if FileManager.default.fileExists(atPath: filePath)
            {
                do
                  {
                    //Reading content from file path string
                     let fileContent = try String(contentsOfFile: filePath)
                     let contentArray = fileContent.components(separatedBy: "\n")
                     for content in contentArray
                     {
                           
                        let placeContent = content.components(separatedBy: ",")
                        if placeContent.count == 6
                            {
                                let place = FavoritePlace(placeLat: Double(placeContent[0]) ?? 0.0, placeLong: Double(placeContent[1]) ?? 0.0, placeName: placeContent[2], city: placeContent[3], postalCode: placeContent[4], country: placeContent[5])
                                favoritePlaces?.append(place)
                            }
                     }
                  }
                    catch
                    {
                        print(error)
                    }
             }
         }
            
        override func prepare(for segue: UIStoryboardSegue, sender: Any?)
        {
            if let sbPlacesList = segue.destination as? PlacesListTableViewController{
            sbPlacesList.places = self.favoritePlaces
        }
}
            
             
        func saveData()
        {
            let filePath = getDataFilePath()
            var saveString = ""
            for place in favoritePlaces!
            {
                saveString = "\(saveString)\(place.placeLat),\(place.placeLong),\(place.placeName),\(place.city),\(place.country),\(place.postalCode)\n"
                     do
                     {
                        try saveString.write(toFile: filePath, atomically: true, encoding: .utf8)
                     }
                     catch
                     {
                         print(error)
                     }
            }
        }
    
        func addDoubleTap()
        {
            //Configuring doubletap gesture to add marker
            let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
                   tap.numberOfTapsRequired = 2
                   mapView.addGestureRecognizer(tap)
        }
    
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
        {
            //Getting user location
            location = locations.first!
            let coordinateRegion = MKCoordinateRegion(center: location!.coordinate, latitudinalMeters: 1000, longitudinalMeters:1000)
            mapView.setRegion(coordinateRegion, animated: true)
            locationManager.stopUpdatingLocation()
        }
    
        @objc func doubleTapped(sender: UITapGestureRecognizer)
        {
           // Getting coordinate of double tapped point and adding annotation
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            addAnnotation(location: locationOnMap)
            //getLocationInfo()
        }

        func addAnnotation(location: CLLocationCoordinate2D)
        {
            //Removing previous annotations and route
            self.mapView.removeOverlays(self.mapView.overlays)
            let oldAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(oldAnnotations)
            
            //Adding new annotation
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            aLat = annotation.coordinate.latitude
            aLon = annotation.coordinate.longitude
            annotation.title = "Destination"
            
            self.mapView.addAnnotation(annotation)
        }
    
        @IBAction func indexChanged(_ sender: Any)
        {
            //Controlling method of transport
            routeMapping()

        }
            
        @IBAction func findMyWay(_ sender: Any)
        {
            //Calculating route
            routeMapping()
        }
    
        func enableLocationServicesAlert()
        {
            //Alert when location services are not enabled
            let alertController = UIAlertController(title: "Error", message:
            "Please enable location services in settings", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

            self.present(alertController, animated: true, completion: nil)
        }
    
        func routeMapping()
        {
            self.mapView.removeOverlays(self.mapView.overlays)
            //Getting desination locations
            let request = MKDirections.Request()
            if(location?.coordinate.longitude == nil || location?.coordinate.latitude == nil)
            {
                enableLocationServicesAlert()
                return
            }
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!), addressDictionary: nil))
            //Handling case when no marker is placed
            
            if(aLat == nil || aLon == nil)
            {
                let alertController = UIAlertController(title: "Error", message:
                "No destination selected", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

                self.present(alertController, animated: true, completion: nil)
            }
            else
            {
                //Getting destination location
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: aLat as! CLLocationDegrees, longitude: aLon as! CLLocationDegrees), addressDictionary: nil))
                request.requestsAlternateRoutes = false
            }
            //Transport type based on segment selection
            switch segmentType.selectedSegmentIndex
            {
                case 0:
                    request.transportType = .walking
                case 1:
                    request.transportType = .automobile
                default:
                    break
            }
            let directions = MKDirections(request: request)

            directions.calculate { [unowned self] response, error in
                guard let unwrappedResponse = response else { return }

                for route in unwrappedResponse.routes {
                    self.mapView.addOverlay(route.polyline)
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                }
            }
    }
    
        //Adding overlays
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            renderer.strokeColor = UIColor.blue
            //Polyline style for automobile route
            if(segmentType.selectedSegmentIndex == 0)
            {
                renderer.lineWidth = 3;
            }
            //Polyline style for the on foot route
            if(segmentType.selectedSegmentIndex == 1)
            {
                renderer.lineWidth = 4.0
                renderer.lineDashPhase = 5
                renderer.lineDashPattern = [NSNumber(value: 1),NSNumber(value:6)]
            }
            return renderer
        }
        
            //Zoom in feature
            @IBAction func zoomIn(_ sender: Any)
            {
                var region: MKCoordinateRegion = mapView.region
                region.span.latitudeDelta /= 2.0
                region.span.longitudeDelta /= 2.0
                mapView.setRegion(region, animated: true)
            }
        
            //Zoom out feature
            @IBAction func zoomOut(_ sender: Any)
            {
                var region: MKCoordinateRegion = mapView.region
                region.span.latitudeDelta = min(region.span.latitudeDelta * 2.0, 180.0)
                region.span.longitudeDelta = min(region.span.longitudeDelta * 2.0, 180.0)
                mapView.setRegion(region, animated: true)
            }
    
    func getFavLocation()
    {
    //Using reverse geolocation to get address information
    CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: aLat as! CLLocationDegrees, longitude: aLon as! CLLocationDegrees)) {  placemark, error in
      if let error = error as? CLError
      {
          print("CLError:", error)
          return
      }
      else if let placemark = placemark?[0]
      {
       
       var placeName = ""
       var city = ""
       var postalCode = ""
       var country = ""
       
       // Getting address information from placemarks
       if let name = placemark.name { placeName += name }
       if let locality = placemark.subLocality { city += locality }
       if let code = placemark.postalCode { postalCode += code }
       if let country_pc = placemark.country { country += country_pc }

        let place = FavoritePlace(placeLat: self.aLat as! Double, placeLong:self.aLon as! Double, placeName: placeName, city: city, postalCode: postalCode, country: country)
     
       self.favoritePlaces?.append(place)
       self.saveData()
       self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}
// Extension for annotation handling
extension MapViewController: MKMapViewDelegate {
    
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
        {
            //Show nothing if loction is user's location
            if annotation is MKUserLocation
            {
                return nil
            }
            
            //Adding a custom pin
            let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
            pinAnnotation.pinTintColor = UIColor.blue
            pinAnnotation.canShowCallout = true
            
            //Adding custom button
            let button = UIButton()
            button.setImage(UIImage(named :"heart")?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
            pinAnnotation.rightCalloutAccessoryView = button
            
            return pinAnnotation
        }

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
        {
            //Alert to confirm user action
            let alertController = UIAlertController(title: "Add to Favourites", message:
                        "Do you want to add to favourites?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Yes", style:  .default, handler: { (UIAlertAction) in
            self.getFavLocation() }))
                
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alertController, animated: true, completion: nil)
        }
}



