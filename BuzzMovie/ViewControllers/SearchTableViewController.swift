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
    
    @IBOutlet weak var magnifyingGlassImage: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
        tableView.isHidden = true
        
        searchController = UISearchController(searchResultsController: nil)
        
        searchController.searchBar.barStyle = .black
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
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    //===========================================================================
    //MARK - SEGUES
    //===========================================================================
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! MovieViewController
        destination.movie = self.selectedMovie
        destination.selectedImage = self.selectedImage
        destination.selectedGenreString = self.selectedGenreString
    }
    
    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        tableView.reloadData()
    }
    //===========================================================================
    //MARK - API
    //===========================================================================
    func fetchImageGenreAndSegue(_ movie:Movie) {
        let searchurl = "https://api.themoviedb.org/3/search/movie"
        let imagebaseurl = "http://image.tmdb.org/t/p/original"
        let parameters = [
            "api_key": TMDB_API_KEY,
            "query": movie.title
        ]
        Alamofire.request(searchurl, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
                //                print(response.request)  // original URL request
                //                print(response.response) // URL response
                //                print(response.data)     // server data
                //                print(response.result)   // result of response serialization
                
                if let unconvertedJSON = response.result.value {
//                    print("\(unconvertedJSON)")
                    let json:JSON = JSON(unconvertedJSON)
                    for moviejson in json["results"].array! {
                        if movie.title.lowercased() == moviejson["original_title"].string?.lowercased() || movie.title == moviejson["title"].string?.lowercased() {
                            //looking for poster
                            if let posterurl = moviejson["poster_path"].string {
                                let imageurl:NSURL = NSURL(string: imagebaseurl + posterurl)!
                                if let imagedata = NSData(contentsOf: imageurl as URL) {
                                    let image = UIImage(data: imagedata as Data)
                                    self.selectedImage = image
                                }
                            } else {
                                self.performSegue(withIdentifier: "MovieView", sender: self)
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
                            self.performSegue(withIdentifier: "MovieView", sender: self)
                            return
                        }
                        
                        self.performSegue(withIdentifier: "MovieView", sender: self)
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
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib.init(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchTableViewCell
//        cell.dataReceived = false
//        cell.dataPending = false
//        cell.posterImageView.image = UIImage(named: "DefaultPosterImage")
        cell.movie = movies[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMovie = (tableView.cellForRow(at: indexPath) as! SearchTableViewCell).movie
        selectedImage = nil
        selectedGenreString = nil
        tableView.deselectRow(at: indexPath, animated: true)
        fetchImageGenreAndSegue(selectedMovie)
    }
}

extension SearchTableViewController: UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate {
    //===========================================================================
    //MARK - SEARCH BAR DELEGATE
    //===========================================================================
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //search button clicked
        activityIndicator.startAnimating()
        magnifyingGlassImage.isHidden = true
        infoLabel.isHidden = true
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
        Alamofire.request(url, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
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
                            self.tableView.isHidden = false

                            let movie = Movie(json: moviejson as JSON)
                            self.movies.append(movie)
                        }
                    }
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
        }
        searchController.isActive = false
        searchController.searchBar.text = searchString

    }
    
}
