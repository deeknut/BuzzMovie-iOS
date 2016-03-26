//
//  Movie.swift
//  BuzzMovie
//
//  Created by Brian Wang on 2/23/16.
//  Copyright © 2016 DK. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Movie {
    
    //converts RT JSON Time to NSDate: 2016-3-26 -> NSDate
    static var dateFromRTFormatter:NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    //converts NSDate to US Locale: NSDate -> Jan 2, 2001
    static var localeFromDateFormatter: NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        return dateFormatter
    }
    
    
    //holds all movie information
    var json: JSON
    
    //id for rottentomatoes
    var RTid: String {
        return json["id"].string ?? "Nil"
    }
    
    //title of movie
    var title: String {
        return json["title"].string ?? "Nil"
    }
    
    //year of movie
    var year: Int {
        return json["year"].int!
    }
    
    //genres of movies in an array
    var genres: [String] {
        return json["genres"].arrayObject as! [String]
    }
    
    //mpaarating PG-13, MA, etc.
    var mpaaRating: String {
        return json["mpaa_rating"].string ?? "TBD"
    }
    
    //runtime converted into "1 hr. 43 min."
    var runtime: String {
        return json["runtime"].int!.runtimeString ?? "TBD"
    }
    
    //criticConsenus
    var criticsConsensus: String {
        return json["critics_consensus"].string ?? "No critic consensus"
    }
    
    //theater release date formatted to US Locale: "Jun 18, 2010"
    var theaterReleaseDate: String {
        if let string = json["release_dates"]["theater"].string {
            return Movie.localeFromDateFormatter.stringFromDate(Movie.dateFromRTFormatter.dateFromString(string)!)
        }

        return "TBD"
    }
    
    //dvd release date formatted to US Locale: "June 18, 2010"
    var dvdReleaseDate: String {
        if let string = json["release_dates"]["dvd"].string {
            return Movie.localeFromDateFormatter.stringFromDate(Movie.dateFromRTFormatter.dateFromString(string)!)
        }
        
        return "TBD"
    }
    
    //critic rating from 0 - 100
    var criticsRating: Int {
        return json["ratings"]["critics_score"].int ?? -1
    }
    
    //audience rating from 0 - 100
    var audienceRating: Int {
        return json["ratings"]["audience_score"].int ?? -1
    }
    
    //buzz rating from 0 - 10
    var buzzRating: Double {
        // do the firebase shit
        return 8.9
    }
    
    //synopsis
    var synopsis: String {
        return json["synopsis"].string ?? "No available synopsis"
    }
    
    
    var image: UIImage! {
        if let path = json["posters"]["original"].string {
            let imageurl:NSURL = NSURL(fileURLWithPath: path)
            let imagedata:NSData = NSData(contentsOfURL: imageurl)!
            return UIImage(data: imagedata)
        }
        return nil
    }
    var abridgedcast: [JSON] {
        return json["abridged_cast"].array ?? []
    }
    
    init(json:JSON) {
        self.json = json
    }
}

extension Int {
    var runtimeString:String {
        let hours = self/60
        let minutes = self%60
        let runTimeString = "\(hours) hr. \(minutes) min."
        return runTimeString
    }
}
