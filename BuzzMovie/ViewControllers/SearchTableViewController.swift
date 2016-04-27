//
//  SearchTableViewController.swift
//  BuzzMovie
//
//  Created by Brian Wang on 3/27/16.
//  Copyright © 2016 DK. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class SearchTableViewController: UIViewController{

    //===========================================================================
    //MARK - VARIABLES
    //===========================================================================
    @IBOutlet weak var tableView: UITableView!
    
    var searchController: UISearchController!
    
    var movies:[Movie] = []
    
    var selectedMovie:Movie!
    var selectedImage:UIImage?
    var selectedGenreString:String?
    
    //===========================================================================
    //MARK - VIEWDIDLOAD
    //===========================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.hidden = true
        
        searchController = UISearchController(searchResultsController: nil)
        
        searchController.searchBar.barStyle = .Black
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        searchController.hidesNavigationBarDuringPresentation = false
        
        self.definesPresentationContext = true
//        searchController.dimsBackgroundDuringPresentation = true
        
        navigationItem.titleView = searchController.searchBar
        
        definesPresentationContext = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //===========================================================================
    //MARK - STATUS BAR
    //===========================================================================
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    //===========================================================================
    //MARK - SEGUES
    //===========================================================================
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController as! MovieViewController
        destination.movie = self.selectedMovie
        destination.selectedImage = self.selectedImage
        destination.selectedGenreString = self.selectedGenreString
    }
    
    //===========================================================================
    //MARK - API
    //===========================================================================
    func fetchImageGenreAndSegue(movie:Movie) {
        let searchurl = "https://api.themoviedb.org/3/search/movie"
        let imagebaseurl = "http://image.tmdb.org/t/p/original"
        let parameters = [
            "api_key": TMDB_API_KEY,
            "query": movie.title
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
                        if movie.title.lowercaseString == moviejson["original_title"].string?.lowercaseString || movie.title == moviejson["title"].string?.lowercaseString {
                            //looking for poster
                            if let posterurl = moviejson["poster_path"].string {
                                let imageurl:NSURL = NSURL(string: imagebaseurl + posterurl)!
                                if let imagedata = NSData(contentsOfURL: imageurl) {
                                    let image = UIImage(data: imagedata)
                                    self.selectedImage = image
                                }
                            } else {
                                self.performSegueWithIdentifier("MovieView", sender: self)
                                return
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
                                self.selectedGenreString = genreString
                            }
                            self.performSegueWithIdentifier("MovieView", sender: self)
                            return
                        }
                        
                        self.performSegueWithIdentifier("MovieView", sender: self)
                        return
                    }
                
                }
        }
    }
}

extension SearchTableViewController: UITableViewDelegate, UITableViewDataSource {
    //===========================================================================
    //MARK - TABLEVIEW
    //===========================================================================
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        tableView.registerNib(UINib.init(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchCell")
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchCell", forIndexPath: indexPath) as! SearchTableViewCell
//        cell.dataReceived = false
//        cell.dataPending = false
//        cell.posterImageView.image = UIImage(named: "DefaultPosterImage")
        cell.movie = movies[indexPath.row]
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedMovie = (tableView.cellForRowAtIndexPath(indexPath) as! SearchTableViewCell).movie
        selectedImage = nil
        selectedGenreString = nil
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        fetchImageGenreAndSegue(selectedMovie)
    }
}

extension SearchTableViewController: UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate {
    //===========================================================================
    //MARK - SEARCH BAR DELEGATE
    //===========================================================================
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //search button clicked
        movies = []
        self.tableView.reloadData()
        let searchString = searchBar.text!
        let url = "http://api.rottentomatoes.com/api/public/v1.0/movies.json"
        let parameters = [
            "q": searchString,
            "page": "1",
            "page_limit": "30",
            "apikey": RT_API_KEY
        ]
        
        Alamofire.request(.GET, url, parameters: parameters)
            .responseJSON { response in
//                print(response.request)  // original URL request
//                print(response.response) // URL response
//                print(response.data)     // server data
//                print(response.result)   // result of response serialization
                
                if let unconvertedJSON = response.result.value {
//                    print("\(unconvertedJSON)")
                    let json:JSON = JSON(unconvertedJSON)
                    for moviejson in json["movies"].array! {
                        if let error = moviejson["error"].string {
                            print(error)
                        } else {
                            self.tableView.hidden = false

                            let movie = Movie(json: moviejson as JSON)
                            self.movies.append(movie)
                        }
                    }
                    self.tableView.reloadData()
                }
        }
        searchController.active = false
        searchController.searchBar.text = searchString

    }
    
}
