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

class ViewController: UIViewController {
    
    var opgehaaldeStations = [Villo_Station]()
    var managedContext:NSManagedObjectContext?
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        loadData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData(){
        
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
                let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [AnyObject]
                
                //var stations = [String]()
                
                if let stations = json {
                    if let firstObject = stations.first {
                       /* print(firstObject)
                        let name = firstObject["name"] as? String
                        let position = firstObject["position"] as? [String: AnyObject]
                        let lat = position!["lat"] as? Double
                        let long = position!["lng"] as? Double
                        
                        // access individual object in array
                        let annotation = MyAnnotation(coordinate: CLLocationCoordinate2D(latitude: lat!, longitude: long!), title: name!, subtitle: "")
                        self.mapView.addAnnotation(annotation)*/
                    }
                    for i in 0..<2{
                        let station = stations[i]
                        let name = station["name"] as? String
                        let position = station["position"] as? [String: AnyObject]
                        let lat = position!["lat"] as? Double
                        let long = position!["lng"] as? Double
                        
                        // access individual object in array
                        /*let annotation = MyAnnotation(coordinate: CLLocationCoordinate2D(latitude: lat!, longitude: long!), title: name!, subtitle: "")
                        self.mapView.addAnnotation(annotation)
                        print(name!)*/
                            
                        
                        let villo_station = NSEntityDescription.insertNewObject(forEntityName: "Villo_Station", into: self.managedContext!) as! Villo_Station
                        villo_station.name = name;
                        villo_station.address = station["adress"] as? String
                        villo_station.available_bike_stands = (station["available_bike_stands"] as? Int16)!
                        villo_station.available_bikes = (station["available_bikes"] as? Int16)!
                        villo_station.contract_name = station["contract_name"] as? String
                        villo_station.status = station["status"] as? String
                        villo_station.last_update = (station["last_update"] as? Int16)!
                        villo_station.lat = lat!
                        villo_station.long = long!
                        self.SaveData(station: villo_station)
                    }
                    for object in stations {
                        // access all objects in array
                        // print(object)
                    }
                    
                    for case let string as String in stations {
                        print(string)
                        // access only string values in array
                    }
                }
                
                //let coordinatesJSON = json!["position"] as? [String: Double]
                
                //let locationNameJSON = json!["name"] as? String
                //let latitude = coordinatesJSON!["lat"]
                //let longitude = coordinatesJSON!["lng"]
                //print("locations = \(latitude) \(longitude)")
            }
            catch{
                
            }
        }
        task.resume()
        
    }
    func SaveData(station:Villo_Station) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        self.managedContext = appDelegate.persistentContainer.viewContext
        let stationFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Villo_Station")
        //let opgehaaldePersonen:[Persoon]
        do{
            self.opgehaaldeStations = try self.managedContext!.fetch(stationFetch) as! [Villo_Station]
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            self.managedContext = appDelegate.persistentContainer.viewContext
            let villo_station = NSEntityDescription.insertNewObject(forEntityName: "Villo_Station", into: self.managedContext!) as! Villo_Station
            
            self.opgehaaldeStations.append(villo_station);
            
            do{
                try self.managedContext!.save()
                self.loadData()
            }
            catch{
                fatalError("Failure to save context: \(error)")
                
            }
            //print(self.opgehaaldePersonen[0].naam!)
            //print(self.opgehaaldePersonen.count)
            //tableView.reloadData()
        }
        catch{
            fatalError("Failed to fetch employees: \(error)")
            
        }
    }
}

