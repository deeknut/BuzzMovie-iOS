//
//  Cells.swift
//  BuzzMovie
//
//  Created by Brian Wang on 2/23/16.
//  Copyright © 2016 DK. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
let baseurl = "http://image.tmdb.org/t/p/w185"
let TMDB_API_KEY = "a45a0f8d482aeac6e5ea456259ac1cd6"

class MovieTableViewCell:UITableViewCell{

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mpaaRatingLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var theaterDateLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var consensusTextView: UITextView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    var imageReceived:Bool = false
    var imagePending:Bool = false
    
    var movie: Movie! {
        didSet {
            mpaaRatingLabel.text = movie.mpaaRating
            titleLabel.text = movie.title
            genreLabel.text = "No Genre Info Available"
            averageRatingLabel.text = String(movie.buzzRating)
            theaterDateLabel.text = "In Theatres: \(movie.theaterReleaseDate)"
            runtimeLabel.text = "Runtime: \(movie.runtime)"
            consensusTextView.text = movie.synopsis
            if !imageReceived && !imagePending {
                getImage()
            }
        }
    }
    
    func getImage() {
        let url = "https://api.themoviedb.org/3/search/movie"
        let parameters = [
            "api_key": TMDB_API_KEY,
            "query": movie.title
        ]
        imagePending = true
        Alamofire.request(.GET, url, parameters: parameters)
            .responseJSON { response in
//                print(response.request)  // original URL request
//                print(response.response) // URL response
//                print(response.data)     // server data
//                print(response.result)   // result of response serialization
                
                if let unconvertedJSON = response.result.value {
//                    print("\(unconvertedJSON)")
                    let json:JSON = JSON(unconvertedJSON)
                    for moviejson in json["results"].array! {
                        if self.movie.title.lowercaseString == moviejson["original_title"].string!.lowercaseString || self.movie.title == moviejson["title"].string!.lowercaseString {
                            //looking for poster
                            if let posterurl = moviejson["poster_path"].string {
                                let imageurl:NSURL = NSURL(string: baseurl + posterurl)!
                                if let imagedata = NSData(contentsOfURL: imageurl) {
                                    let image = UIImage(data: imagedata)
                                    self.posterImageView.image = image
                                    self.backgroundImageView.image = image
                                    self.imageReceived = true
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
                                self.genreLabel.text = genreString
                            }
                            return
                        }
                    }
                }
        }
    }
}

class SearchTableViewCell:UITableViewCell {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var avgRatingLabel: UILabel!
    @IBOutlet weak var mpaaRatingLabel: UILabel!
    
    var imageReceived:Bool = false
    var imagePending:Bool = false
    
    var movie: Movie! {
        didSet {
            mpaaRatingLabel.text = movie.mpaaRating
            titleLabel.text = movie.title
            genreLabel.text = "No Genre Info Available"
            runtimeLabel.text = "Runtime: \(movie.runtime)"
            if !imageReceived && !imagePending {
                getImage()
            }
        }
    }
    
    func getImage() {
        let url = "https://api.themoviedb.org/3/search/movie"
        let parameters = [
            "api_key": TMDB_API_KEY,
            "query": movie.title
        ]
        imagePending = true
        Alamofire.request(.GET, url, parameters: parameters)
            .responseJSON { response in
                //                print(response.request)  // original URL request
                //                print(response.response) // URL response
                //                print(response.data)     // server data
                //                print(response.result)   // result of response serialization
                
                if let unconvertedJSON = response.result.value {
                    //                    print("\(unconvertedJSON)")
                    let json:JSON = JSON(unconvertedJSON)
                    for moviejson in json["results"].array! {
                        if self.movie.title.lowercaseString == moviejson["original_title"].string!.lowercaseString || self.movie.title == moviejson["title"].string!.lowercaseString {
                            //looking for poster
                            if let posterurl = moviejson["poster_path"].string {
                                let imageurl:NSURL = NSURL(string: baseurl + posterurl)!
                                if let imagedata = NSData(contentsOfURL: imageurl) {
                                    let image = UIImage(data: imagedata)
                                    self.posterImageView.image = image
//                                    self.backgroundImageView.image = image
                                    self.imageReceived = true
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
                                self.genreLabel.text = genreString
                            }
                            return
                        }
                    }
                }
        }
    }

    
}