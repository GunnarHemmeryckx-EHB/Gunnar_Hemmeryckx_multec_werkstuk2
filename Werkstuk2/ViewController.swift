//
//  ViewController.swift
//  Werkstuk2
//
//  Created by Gunnar Hemmeryckx on 27/04/18.
//  Copyright © 2018 Gunnar Hemmeryckx. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    var opgehaaldeStations = [Villo_Station]()
    var managedContext:NSManagedObjectContext?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
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
            let station = NSEntityDescription.insertNewObject(forEntityName: "Villo_Station", into: self.managedContext!) as! Villo_Station
            
            
            self.opgehaaldeStations.append(station);
            
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

