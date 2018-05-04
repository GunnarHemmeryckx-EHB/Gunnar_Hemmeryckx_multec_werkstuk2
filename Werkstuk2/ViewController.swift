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
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        self.managedContext = appDelegate.persistentContainer.viewContext
        
        //https://stackoverflow.com/questions/27208103/detect-first-launch-of-ios-app
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
            makeAnnotation()
        } else {
            print("First launch, setting UserDefault.")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            loadData()
        }
        
        //loadData()
        //makeAnnotation()
        print("ARRAY: \(self.opgehaaldeStations)")
        mapView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData(){
        //self.deleteData()
        print("LOAD")
        let url = URL(string: "https://api.jcdecaux.com/vls/v1/stations?apiKey=6d5071ed0d0b3b68462ad73df43fd9e5479b03d6&contract=Bruxelles-Capitale")
        let urlRequest = URLRequest(url: url!)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for errors
            guard error == nil else{
                print("error calling GET")
                print(error!)
                return
            }// make sure we got data
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
                    if let firstObject = stations.first {
                    }
                    for i in 0..<5{
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
                        let last_update = station["last_update"] as? Int64
                        let status = station["status"] as? String
                        
                        let villo_station = NSEntityDescription.insertNewObject(forEntityName: "Villo_Station", into: self.managedContext!) as! Villo_Station
                        villo_station.name = name
                        villo_station.address = adress
                        villo_station.lat = lat!
                        villo_station.long = long!
                        villo_station.available_bike_stands = available_bike_stands!
                        villo_station.available_bikes = available_bikes!
                        villo_station.bike_stands = bike_stands!
                        villo_station.contract_name = contract_name!
                        villo_station.last_update = last_update!
                        villo_station.status = status
                        do{
                            self.opgehaaldeStations.append(villo_station)
                            try self.managedContext!.save()
                            self.makeAnnotation()
                        }
                        catch{
                            fatalError("Failure to save context: \(error)")
                            
                        }
                    }
                    for station in stations {
                        // access all objects in array
                        // print(object)
                    }
                }
            }
            catch{
                
            }
        }
        task.resume()
    }
    func makeAnnotation(){
        
        let stationFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Villo_Station")
        //let opgehaaldePersonen:[Persoon]
        do{
            self.opgehaaldeStations = try self.managedContext!.fetch(stationFetch) as! [Villo_Station]
            //print(self.opgehaaldePersonen[0].naam!)
            //print(self.opgehaaldePersonen.count)
        }
        catch{
            fatalError("Failed to fetch employees: \(error)")
            
        }
        for station in self.opgehaaldeStations {
            let annotation = MyAnnotation(coordinate: CLLocationCoordinate2D(latitude: station.lat, longitude: station.long), title: station.name!, subtitle: String(station.available_bikes))
            self.mapView.addAnnotation(annotation)
        }
        
    }
    //https://cocoacasts.com/how-to-delete-every-record-of-a-core-data-entity
    func deleteData(){
        let stationFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Villo_Station")
        //let opgehaaldePersonen:[Persoon]
        do{
            self.opgehaaldeStations = try self.managedContext!.fetch(stationFetch) as! [Villo_Station]
            
            for station in self.opgehaaldeStations {
                self.managedContext!.delete(station)
            }
            self.opgehaaldeStations.removeAll()
            
            print("ManagedContext in deleteData: \(managedContext!)")
            print("delete")
            print("ARRAY in deleteData: \(self.opgehaaldeStations)")
            // Save Changes
            try self.managedContext!.save()
        }
        catch{
            fatalError("Failed to delete stations \(error)")
        }
    }
    
    
    
    
    //https://www.raywenderlich.com/160517/mapkit-tutorial-getting-started
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 2
        guard let annotation = annotation as? MyAnnotation else { return nil }
        // 3
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .infoLight)
        }
        return view
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        //if let annotationTitle = view.annotation?.title{
            print("User tapped on annotation with title: \(view.annotation!)")
        //}
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            //print("button tapped")
            performSegue(withIdentifier: "toTheMoon", sender: view)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toTheMoon" )
        {
            var destinationVC = segue.destination as! DetailViewController
            
            destinationVC.antitle = (sender as! MKAnnotationView).annotation!.title!
            
        }
    }
    
}

