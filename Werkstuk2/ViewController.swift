//
//  ViewController.swift
//  Werkstuk2
//
//  Created by Gunnar Hemmeryckx on 27/04/18.
//  Copyright © 2018 Gunnar Hemmeryckx. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var opgehaaldeStations = [Villo_Station]()
    var managedContext:NSManagedObjectContext?
    let lastUpdateUserDef = UserDefaults.standard
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var lblLastUpdate: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor(red:1.00, green:0.83, blue:0.20, alpha:1.0)//UIColor.yellow//fed332
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        self.managedContext = appDelegate.persistentContainer.viewContext
        
        
        //USERDEFAULT TOEVOEGEN ALS DE APP VOOR DE EERSTE KEER WORD GESTART + GEGEVENS LADEN -> ANDERS ENKEL ANNOTATIION TOEVOEGEN
        //https://stackoverflow.com/questions/27208103/detect-first-launch-of-ios-app
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
            makeAnnotation()
        } else {
            print("First launch, setting UserDefault.")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            loadData()
            lastUpdateUserDef.set(Date(), forKey:"lastUpdate")
        }
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        //locationManager.delegate = self
        
        //Date omzetten naar dd-MM-yyy HH:mm formaat
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "HH:mm dd/MM/yyy"
        let lastUpdateTime = lastUpdateUserDef.object(forKey: "lastUpdate") as! Date
        self.lblLastUpdate.text = "\(NSLocalizedString("last update", comment: "")): \(dateFormatterGet.string(from: lastUpdateTime))"
        print("ARRAY: \(self.opgehaaldeStations)")
        
        mapView.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    //JSON GEGEVENS OPHALEN UIT API EN OPSLAAN NAAR CORE DATA
    //VIA FOR LOOP -> SLAAT DUS NIET ALLE GEGEVENS UIT DE JSON OP IN DE CORE DATA -> ANDERS WERKT DE APP VEEL TE TRAAG OP MIJN PC -> ZIE LAATSTE FUNCTIE VOOR VOLLEDIG LADEN VAN GEGEVENS
    func loadData(){
        self.opgehaaldeStations.removeAll()
        print("ARRAY IN LOAD: \(self.opgehaaldeStations)")
        let url = URL(string: "https://api.jcdecaux.com/vls/v1/stations?apiKey=6d5071ed0d0b3b68462ad73df43fd9e5479b03d6&contract=Bruxelles-Capitale")
        let urlRequest = URLRequest(url: url!)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            guard error == nil else{
                print("error calling GET")
                print(error!)
                return
            }
            guard let responseData = data else{
                print("Error: did not receive data")
                return
            }
            do{
                guard let json = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [AnyObject] else {
                    print("failed JSONSerialization")
                    return
                }
                
                //var stations = [String]()
                
                if let stations = json {
                    for i in 0..<25{
                        let station = stations[i]
                        let name = station["name"] as? String
                        let adress = station["address"] as? String
                        let position = station["position"] as? [String: AnyObject]
                        let lat = position!["lat"] as? Double
                        let long = position!["lng"] as? Double
                        let available_bike_stands = station["available_bike_stands"] as? Int16
                        let available_bikes = station["available_bikes"] as? Int16
                        let bike_stands = station["available_bikes"] as? Int16
                        let contract_name = station["contract_name"] as? String
                        let status = station["status"] as? String
                        
                        //GETAL VOORAAN IN NAAM WEGHALEN //https://stackoverflow.com/questions/47297053/swift-4-cannot-subscript-a-value-of-type-string-with-an-index-of-type-counta
                        let villoName = name!
                        let idx = villoName.index(villoName.startIndex, offsetBy: 6)
                        let verkorteNaam = villoName[idx...]
                        
                        //JSON GEGEVENS IN CORE DATA OPSLAAN
                        let villo_station = NSEntityDescription.insertNewObject(forEntityName: "Villo_Station", into: self.managedContext!) as! Villo_Station
                        villo_station.name = String(verkorteNaam)
                        villo_station.address = adress
                        villo_station.lat = lat!
                        villo_station.long = long!
                        villo_station.available_bike_stands = available_bike_stands!
                        villo_station.available_bikes = available_bikes!
                        villo_station.bike_stands = bike_stands!
                        villo_station.contract_name = contract_name!
                        villo_station.status = status
                        
                        self.opgehaaldeStations.append(villo_station)
                        do{
                            try self.managedContext!.save()
                        }
                        catch{
                            fatalError("Failure to save context: \(error)")
                            
                        }
                    }
                    
                    DispatchQueue.main.async{
                        self.makeAnnotation()
                    }
                }
            }
            catch{
                
            }
        }
        task.resume()
    }
    
    //ANNOTATION VOOR GEGEVENS IN CORE DATA AANMAKEN
    func makeAnnotation(){
        
        let stationFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Villo_Station")
        do{
            self.opgehaaldeStations = try self.managedContext!.fetch(stationFetch) as! [Villo_Station]
        }
        catch{
            fatalError("Kon geen stations ophalen \(error)")
            
        }
        for station in self.opgehaaldeStations {
            let annotation = MyAnnotation(coordinate: CLLocationCoordinate2D(latitude: station.lat, longitude: station.long), title: station.name!, subtitle: "\(NSLocalizedString("Available bikes", comment: "")): \(String(station.available_bikes))", status: station.status!)
            self.mapView.addAnnotation(annotation)
        }
        
    }
    
    //FUNCTIE OM DATA TE VERWIJDEREN
    //https://cocoacasts.com/how-to-delete-every-record-of-a-core-data-entity
    func deleteData(){
        let stationFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Villo_Station")
        do{
            self.opgehaaldeStations = try self.managedContext!.fetch(stationFetch) as! [Villo_Station]
            
            for station in self.opgehaaldeStations {
                self.managedContext!.delete(station)
            }
            // Save Changes
            try self.managedContext!.save()
        }
        catch{
            fatalError("Failed to delete stations \(error)")
        }
    }
    
    
    //CUSTOM ANNOTATION
    //https://www.raywenderlich.com/160517/mapkit-tutorial-getting-started
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MyAnnotation else { return nil }
        let identifier = "marker"
        var view: MKAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: 0, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        //ALS DE STATUS VAN HET STATION GESLOTEN IS, DE RODE ANNOTATION WEERGEVEN
        if(annotation.status == "OPEN"){
            view.image = UIImage(named: "VilloAnnotation")
        }
        else{
            view.image = UIImage(named: "VilloAnnotationFull")
        }
        return view
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        print("Druk op annotation: \(view.annotation?.title!)")
    }
    
    //SEGUE NAAR DETAIL
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            //print("button tapped")
            performSegue(withIdentifier: "toDetail", sender: view)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toDetail" )
        {
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.opgehaaldeStations = self.opgehaaldeStations
            destinationVC.myTitle = (sender as! MKAnnotationView).annotation!.title!
            
        }
    }
    @IBAction func btnReload(_ sender: Any) {
        print("reload btn click")
        //delete annotations
        self.mapView.removeAnnotations(self.mapView.annotations)
        //DELETE GEGEVENS
        deleteData()
        //LAAD DATA OPNIEUW IN
        loadData()
        //PAS USERDEFAULT VOOR LAATSTE UPDATE AAN
        lastUpdateUserDef.set(Date(), forKey:"lastUpdate")
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "HH:mm dd/MM/yyy"
        let lastUpdateTime = lastUpdateUserDef.object(forKey: "lastUpdate") as! Date
        //WIJZIG TEXT VAN LAATSTE UPDATE
        self.lblLastUpdate.text = "\(NSLocalizedString("last update", comment: "")): \(dateFormatterGet.string(from: lastUpdateTime))"
    }
    
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //Locatie Brussel: latitude: 50.848676, longitude: 4.350378
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
    
    
    
    
    //FUNCTIE DIE ALLE GEGEVENS UIT DE JSON OPSLAAT IN DE CORE DATA -> IK GEBRUIK DEZE NU NIET WANT DIT WERKT EXTREEM TRAAG OP MIJN PC
    func loadALLData(){
        self.opgehaaldeStations.removeAll()
        print("ARRAY IN LOAD: \(self.opgehaaldeStations)")
        let url = URL(string: "https://api.jcdecaux.com/vls/v1/stations?apiKey=6d5071ed0d0b3b68462ad73df43fd9e5479b03d6&contract=Bruxelles-Capitale")
        let urlRequest = URLRequest(url: url!)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            guard error == nil else{
                print("error calling GET")
                print(error!)
                return
            }
            guard let responseData = data else{
                print("Error: did not receive data")
                return
            }
            do{
                guard let villoJson = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [AnyObject] else {
                    print("failed JSONSerialization")
                    return
                }
                
                //var stations = [String]()
                
                if let stations = villoJson {
                    for station in stations {
                        //let station = stations[i]
                        let name = station["name"] as? String
                        let adress = station["address"] as? String
                        let position = station["position"] as? [String: AnyObject]
                        let lat = position!["lat"] as? Double
                        let long = position!["lng"] as? Double
                        let available_bike_stands = station["available_bike_stands"] as? Int16
                        let available_bikes = station["available_bikes"] as? Int16
                        let bike_stands = station["available_bikes"] as? Int16
                        let contract_name = station["contract_name"] as? String
                        let status = station["status"] as? String
                        
                        //GETAL VOORAAN IN NAAM WEGHALEN //https://stackoverflow.com/questions/47297053/swift-4-cannot-subscript-a-value-of-type-string-with-an-index-of-type-counta
                        let villoName = name!
                        let idx = villoName.index(villoName.startIndex, offsetBy: 6)
                        let verkorteNaam = villoName[idx...]
                        
                        //JSON GEGEVENS IN CORE DATA OPSLAAN
                        let villo_station = NSEntityDescription.insertNewObject(forEntityName: "Villo_Station", into: self.managedContext!) as! Villo_Station
                        villo_station.name = String(verkorteNaam)
                        villo_station.address = adress
                        villo_station.lat = lat!
                        villo_station.long = long!
                        villo_station.available_bike_stands = available_bike_stands!
                        villo_station.available_bikes = available_bikes!
                        villo_station.bike_stands = bike_stands!
                        villo_station.contract_name = contract_name!
                        villo_station.status = status
                        
                        self.opgehaaldeStations.append(villo_station)
                        do{
                            try self.managedContext!.save()
                        }
                        catch{
                            fatalError("Failure to save context: \(error)")
                            
                        }
                    }
                    DispatchQueue.main.async{
                        self.makeAnnotation()
                    }
                }
            }
            catch{
                
            }
        }
        task.resume()
    }
}

