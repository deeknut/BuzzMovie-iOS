//
//  Movie.swift
//  BuzzMovie
//
//  Created by Brian Wang on 2/23/16.
//  Copyright © 2016 DK. All rights reserved.
//

import UIKit
import SwiftyJSON

//enum MPAARating:String {
//    case G = "G", PG = "PG", PG13 = "PG-13", R = "R", NC = "NC-17"
//}

struct Movie {
    var json: JSON{
        didSet {
            
        }
    }
//    var RTid: String!
//    var title: String!
//    var year: Int!
//    var mpaaRating: MPAARating!
//    var criticsConsensus: String!
//    var synopsis: String!
//    var image: UIImage?
//    var avgRating: Double?
    
    init(json:JSON) {
        self.json = json
    }
}

