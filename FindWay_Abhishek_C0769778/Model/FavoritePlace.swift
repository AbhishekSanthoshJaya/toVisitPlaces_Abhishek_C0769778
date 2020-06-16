//
//  ToVisitPlaces.swift
//  FindWay_Abhishek_C0769778
//
//  Created by user166476 on 6/15/20.
//  Copyright © 2020 user166476. All rights reserved.
//

import Foundation

class FavoritePlace{
    
    var placeLat: Double
    var placeLong: Double
    var placeName :String
    var city :String
    var postalCode : String
    var country : String
    
    init(placeLat:Double , placeLong: Double, placeName:String, city:String, postalCode: String, country:String) {
        self.placeLat = placeLat
        self.placeLong = placeLong
        self.placeName = placeName
        self.city = city
        self.postalCode = postalCode
        self.country = country
    }
    
    
}

