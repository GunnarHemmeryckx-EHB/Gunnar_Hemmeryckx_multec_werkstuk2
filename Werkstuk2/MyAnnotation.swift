//
//  MyAnnotation.swift
//  Werkstuk2
//
//  Created by Gunnar Hemmeryckx on 30/04/18.
//  Copyright © 2018 Gunnar Hemmeryckx. All rights reserved.
//

import UIKit
import MapKit

class MyAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    //SUBTITLE WANNEER MEN TAPT OP ANNOTATION: https://developer.apple.com/documentation/mapkit/mkannotation/1429520-subtitle
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
