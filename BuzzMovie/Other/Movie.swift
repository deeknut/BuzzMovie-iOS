//
//  Movie.swift
//  BuzzMovie
//
//  Created by Brian Wang on 2/23/16.
//  Copyright © 2016 DK. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire



struct Movie {
    
    //list of all genre ids
    static let genreMap:[String:String] = [
        "28":       "Action",
        "12":       "Adventure",
        "16":       "Animation",
        "35":       "Comedy",
        "80":       "Crime",
        "99":       "Documentary",
        "18":       "Drama",
        "10751":    "Family",
        "14":       "Fantasy",
        "10769":    "Foreign",
        "36":       "History",
        "27":       "Horror",
        "10402":    "Music",
        "9648":     "Mystery",
        "10749":    "Romance",
        "878":      "Science Fiction",
        "10770":    "TV Movie",
        "53":       "Thriller",
        "10752":    "War",
        "37":       "Western"
    ]
    
    
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
    
    var cell:GeneralCell?
    
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
        return json["year"].int ?? -1
    }
    
    //genres of movies in an array
    var genres: [String] {
        return json["genres"].arrayObject as! [String]
    }
    
    //mpaarating PG-13, MA, etc.
    var mpaaRating: String {
        if json["mpaa_rating"].string == "Unrated" {
            return "TBD"
        }
        return json["mpaa_rating"].string ?? "TBD"
    }
    
    //runtime converted into "1 hr. 43 min."
    var runtime: String {
        if let runtime = json["runtime"].int {
            return runtime.runtimeString
        }
        return "TBD"
    }
    
    //criticConsenus
    var criticsConsensus: String {
        return json["critics_consensus"].string ?? "No critic consensus"
    }
    
    //theater release date formatted to US Locale: "Jun 18, 2010"
    var theaterReleaseDate: String {
        print(json)
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
    
    
    
    var image:UIImage?
    var imdbid:String? {
        return json["alternate_ids"]["imdb"].string
    }
    
    var abridgedcast: [JSON] {
        return json["abridged_cast"].array ?? []
    }
    
    init(json:JSON) {
        self.json = json
    }
    
    func setImageAndGenreForCell() {
        let searchurl = "https://api.themoviedb.org/3/search/movie"
        let imagebaseurl = "http://image.tmdb.org/t/p/w185"
        let parameters = [
            "api_key": TMDB_API_KEY,
            "query": title
        ]
        Alamofire.request(.GET, searchurl, parameters: parameters)
            .responseJSON { response in
                //                print(response.request)  // original URL request
                //                print(response.response) // URL response
                //                print(response.data)     // server data
                //                print(response.result)   // result of response serialization
                
                if let unconvertedJSON = response.result.value {
                    //                    print("\(unconvertedJSON)")
                    let json:JSON = JSON(unconvertedJSON)
                    for moviejson in json["results"].array! {
                        if self.title.lowercaseString == moviejson["original_title"].string!.lowercaseString || self.title == moviejson["title"].string!.lowercaseString {
                            //looking for poster
                            if let posterurl = moviejson["poster_path"].string {
                                let imageurl:NSURL = NSURL(string: imagebaseurl + posterurl)!
                                if let imagedata = NSData(contentsOfURL: imageurl) {
                                    let image = UIImage(data: imagedata)
                                    if let cell = self.cell {
                                        cell.dataReceived = true
                                        cell.posterImageView.image = image
                                        (cell as? MovieTableViewCell)?.backgroundImageView.image = image
                                    }
                                }
                            } else {
//                                print("movie.title: \(self.movie.title.lowercaseString)")
//                                print("moviejson[original_title]: \(moviejson["original_title"].string!.lowercaseString)")
//                                print("moviejson[title]: \(moviejson["title"].string!.lowercaseString)")
//                                print(moviejson)
                            }
                            
                            //looking for genres
                            if let genrelist = moviejson["genre_ids"].arrayObject as! [Int]? {
                                var genreString = ""
                                for i in genrelist{
                                    if let g = Movie.genreMap[String(i)] {
                                        genreString += g
                                        if i != genrelist.last {
                                            genreString += "/"
                                        }
                                    }
                                }
                                if let cell = self.cell {
                                    cell.genreLabel.text = genreString
                                }
                            }
                            return
                        }
                    }
                }
        }

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
