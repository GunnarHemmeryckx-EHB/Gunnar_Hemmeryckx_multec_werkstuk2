//
//  DetailViewController.swift
//  Werkstuk2
//
//  Created by Gunnar Hemmeryckx on 4/05/18.
//  Copyright © 2018 Gunnar Hemmeryckx. All rights reserved.
//ICONEN AFKOMSTIG VAN Flaticon.com

import UIKit
import CoreData

class DetailViewController: UIViewController {

    
    var managedContext:NSManagedObjectContext?
    var opgehaaldeStations = [Villo_Station]()
    var myTitle:String?
    
    //LABELS DIE VAN TAAL VERANDEREN
    @IBOutlet weak var CityLabel: UILabel!
    @IBOutlet weak var AddressLabel: UILabel!
    @IBOutlet weak var StatusLabel: UILabel!
    @IBOutlet weak var StatusImage: UIImageView!
    
    @IBOutlet weak var lblContract_name: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAdress: UILabel!
    @IBOutlet weak var lblAvailable_Bike_Stands: UILabel!
    @IBOutlet weak var lblAvailableBikes: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Station gelijkstellen aan die uit opgehaalde array met zelfde naam
        let station = opgehaaldeStations.first(where: { $0.name == self.myTitle })
        
        self.CityLabel.text = NSLocalizedString("City", comment: "")
        self.AddressLabel.text = NSLocalizedString("Address", comment: "")
        
        
        //---GROTE VAN LABEL AANPASSEN AAN TEKST----
        self.lblName.lineBreakMode = .byWordWrapping
        self.lblName.numberOfLines = 2
        self.lblName.adjustsFontSizeToFitWidth = true
        //---------------
        self.lblName.text = station?.name
        
        self.lblAvailableBikes.text = "\(station!.available_bikes)"
        self.lblAvailable_Bike_Stands.text = "\(station!.available_bike_stands)"
        
        self.lblContract_name.text = station?.contract_name
        
        //---GROTE VAN LABEL AANPASSEN AAN TEKST----
        self.lblAdress.lineBreakMode = .byWordWrapping
        self.lblAdress.numberOfLines = 0
        self.lblAdress.adjustsFontSizeToFitWidth = true
        //-----------------
        self.lblAdress.text = station?.address
        
        
        self.lblStatus.text = station?.status
        //ICOON VAN STATUS AANPASSEN NAARGELANG DE STATUS
        if(station?.status == "OPEN"){
            self.StatusImage.image = UIImage(named: "unlocked")
            self.StatusLabel.text = NSLocalizedString("Status", comment: "")
            self.lblStatus.text = NSLocalizedString("Open", comment: "")
        }else if (station?.status == "CLOSED"){
             self.StatusImage.image = UIImage(named: "locked")
            self.StatusLabel.text = NSLocalizedString("Status", comment: "")
            self.lblStatus.text = NSLocalizedString("Closed", comment: "")
        }
        
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
