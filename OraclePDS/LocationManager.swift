//
//  LocationManager.swift
//  OraclePDS
//
//  Created by Arun CP on 27/05/21.
//

import UIKit
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
//    var description = String
    
    static let shared = LocationManager()
    
    let manager = CLLocationManager()
    var completion : ((CLLocation)-> Void)?
    public func getUserLocation(completion: @escaping ((CLLocation)->Void)){
        self.completion = completion
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        completion?(location)
        manager.stopUpdatingLocation()
    }
    
     func resolveLocationName(with location : CLLocation, completion:@escaping ((String?)->Void)){
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, preferredLocale: .current) { placeMarks, error in
            guard let place = placeMarks?.first, error == nil else {
                completion(nil)
                return
            }
            print(place)
            var name = ""
            if let locality = place.locality{
                name += locality
            }
            if let locality = place.administrativeArea{
                name += locality
            }
            if let locality = place.country{
                name += locality
            }
            
            completion(name)
        }
    }
}
