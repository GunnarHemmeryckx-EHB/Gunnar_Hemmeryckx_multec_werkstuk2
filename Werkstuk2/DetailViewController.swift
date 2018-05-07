//
//  DetailViewController.swift
//  Werkstuk2
//
//  Created by Gunnar Hemmeryckx on 4/05/18.
//  Copyright © 2018 Gunnar Hemmeryckx. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {

    
    var managedContext:NSManagedObjectContext?
    var opgehaaldeStations = [Villo_Station]()
    var antitle:String?
    
    @IBOutlet weak var lblContract_name: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAdress: UILabel!
    @IBOutlet weak var lblAvailable_Bike_Stands: UILabel!
    @IBOutlet weak var lblAvailableBikes: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let station = opgehaaldeStations.first(where: { $0.name == self.antitle })
        
        self.lblName.lineBreakMode = .byWordWrapping
        self.lblName.numberOfLines = 0
        self.lblName.adjustsFontSizeToFitWidth = true
        self.lblName.text = station?.name
        self.lblContract_name.text = station?.contract_name
        self.lblAdress.lineBreakMode = .byWordWrapping
        self.lblAdress.numberOfLines = 0
        self.lblAdress.adjustsFontSizeToFitWidth = true
        self.lblAdress.text = station?.address
        self.lblAvailableBikes.text = "\(station!.available_bikes)"
        self.lblAvailable_Bike_Stands.text = "\(station!.available_bike_stands)"
        
        /*let stationFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Villo_Station")
        do{
            self.opgehaaldeStations = try self.managedContext!.fetch(stationFetch) as! [Villo_Station]
        }
        catch{
            fatalError("Failed to fetch employees: \(error)")
            
        }*/
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
