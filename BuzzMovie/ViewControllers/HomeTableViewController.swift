//
//  HomeTableViewController.swift
//  BuzzMovie
//
//  Created by Brian Wang on 2/23/16.
//  Copyright © 2016 DK. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
let RT_API_KEY = "yedukp76ffytfuy24zsqk7f5"
let TMDB_API_KEY = "a45a0f8d482aeac6e5ea456259ac1cd6"
//let OMDB_API_KEY = "a69daed3"

class HomeTableViewController: UIViewController {

    //===========================================================================
    //MARK - VARIABLES
    //===========================================================================
    //triple tableview
    @IBOutlet weak var tableView0: UITableView!
    @IBOutlet weak var tableView1: UITableView!
    @IBOutlet weak var tableView2: UITableView!
    
    //misc objects
    @IBOutlet weak var movieSegControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //constraints
    @IBOutlet weak var tableView0TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView0BottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView1TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView1BottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView2TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView2BottomConstraint: NSLayoutConstraint!
    
    //tableView sources
    var newMovies:[Movie] = [] {
        didSet {
            movieDidSet(newMovies, tableView0)
        }
    }
    var recommendedMovies:[Movie] = [] {
        didSet {
            movieDidSet(recommendedMovies, tableView1)
        }
    }
    var topdvdMovies:[Movie] = [] {
        didSet {
            movieDidSet(topdvdMovies, tableView2)
        }
    }
    
    var apiUrls = [
       "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/opening.json",
       "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/opening.json",
       "http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json"
    ]
    
    var currentLimits:[Int] = [10, 10, 10]
    
    func movieDidSet(movies:[Movie],_ tableView: UITableView) {
        reloadTable(movies, tableView)
        if movies.count == 0 {
            tableView.hidden = true
        } else {
            tableView.hidden = false
        }
    }
    
    //movie 
    var selectedMovie:Movie!
    var selectedImage:UIImage?
    var selectedGenreString:String?
    
    //===========================================================================
    //MARK - VIEWDIDLOAD/VIEWWILLAPPEAR
    //===========================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
        searchBar.hidden = true
       
        //refresh control
        let refreshControl0 = UIRefreshControl()
        refreshControl0.addTarget(self, action: #selector(HomeTableViewController.refresh), forControlEvents: .ValueChanged)
        let refreshControl1 = UIRefreshControl()
        refreshControl1.addTarget(self, action: #selector(HomeTableViewController.refresh), forControlEvents: .ValueChanged)
        let refreshControl2 = UIRefreshControl()
        refreshControl2.addTarget(self, action: #selector(HomeTableViewController.refresh), forControlEvents: .ValueChanged)
        tableView0.addSubview(refreshControl0)
        tableView1.addSubview(refreshControl1)
        tableView2.addSubview(refreshControl2)
        
        //color consistency
        movieSegControl.backgroundColor = StyleConstants.defaultGrayColor
        searchBar.backgroundColor = StyleConstants.defaultGrayColor
        
        //default tableviews are hidden
        self.tableView0.hidden = true
        self.tableView1.hidden = true
        self.tableView2.hidden = true
        
        //white status bar
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        for i in 0...2 {
            fetchMovies(apiUrls[i], segmentIndex: i, limit: currentLimits[i])
        }
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
    //MARK - NAV BAR
    //===========================================================================
    
    override func willMoveToParentViewController(parent: UIViewController?) {
//        if let _ = parent {
//            self.navigationController?.hidesBarsOnSwipe = true
//        } else {
//            self.navigationController?.hidesBarsOnSwipe = false
//        }
    }
    
    //===========================================================================
    //MARK - SEGUES
    //===========================================================================
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController as! MovieViewController
        destination.movie = self.selectedMovie
        destination.selectedImage = self.selectedImage
        destination.selectedGenreString = self.selectedGenreString

//        destination.originalImage = selectedMovie.originalImage
    }
    
    //===========================================================================
    //MARK - SEGCONTROL
    //===========================================================================
    
    @IBAction func segValueDidChange(sender: AnyObject) {
        searchBar.resignFirstResponder()
        setMovies()
    }
    
    func setMovies() {
        switch movieSegControl.selectedSegmentIndex {
        case 0:
            searchBar.hidden = true
            checkMovies(tableView0, newMovies)
            tableView1.hidden = true
            tableView2.hidden = true
            break
        case 1:
            searchBar.hidden = false
            tableView0.hidden = true
            checkMovies(tableView1, recommendedMovies)
            tableView2.hidden = true
            break
        case 2:
            searchBar.hidden = true
            tableView0.hidden = true
            tableView1.hidden = true
            checkMovies(tableView2, topdvdMovies)
            break
        default:
            break
        }
        
    }
    
    func checkMovies(tableView:UITableView,_ movies:[Movie]) {
        if (movies.count != 0) {
            tableView.hidden = false
        } else {
            tableView.hidden = true
        }
    }
    
    //===========================================================================
    //MARK - API CALLS
    //===========================================================================
    func fetchMovies(url: String, segmentIndex:Int, limit:Int) {
        if segmentIndex == 1 {
            let tempMovies = fetchRecommendations()
            if !self.moviesIsEqual(tempMovies, recommendedMovies) {
                recommendedMovies = tempMovies
                setMovies()
            }
            return
        }
        var fetchedMovies:[Movie] = []
        let parameters = [
            "apikey": RT_API_KEY,
            "limit": "\(limit)"
        ]
        Alamofire.request(.GET, url, parameters: parameters)
            .responseJSON { response in
//                    print(response.request)  // original URL request
//                    print(response.response) // URL response
//                    print(response.data)     // server data
//                    print(response.result)   // result of response serialization
                
                if let unconvertedJSON = response.result.value {
//                    print("\(unconvertedJSON)")
                    let json:JSON = JSON(unconvertedJSON)
                    if let moviejsons = json["movies"].array {
                        for moviejson in moviejsons {
                            //SPLIT
                            if let error = moviejson["error"].string {
                                print(error)
                            } else {
                                let movie = Movie(json: moviejson as JSON)
                                fetchedMovies.append(movie)
                            }
                        }
                        //movies check. If equal don't do anything
                        if segmentIndex == 0 {
                            if !self.moviesIsEqual(fetchedMovies, self.newMovies) {
                                self.newMovies = fetchedMovies
                                self.setMovies()
                            }
                        } else if segmentIndex == 2 {
                            if !self.moviesIsEqual(fetchedMovies, self.topdvdMovies) {
                                self.topdvdMovies = fetchedMovies
                                self.setMovies()
                            }
                        }
                    }
//                    print("search done")
                }
        }
    }
    
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
    
    func fetchRecommendations() -> [Movie] {
        return []
    }
    
    func moviesIsEqual(movies1:[Movie],_ movies2:[Movie]) -> Bool{
        return movies1.elementsEqual(movies2, isEquivalent: {movie1, movie2 in return movie1.RTid == movie2.RTid })
    }
    
    //===========================================================================
    //MARK - REFRESH
    //===========================================================================
    func refresh(refreshControl: UIRefreshControl) {
        let index = movieSegControl.selectedSegmentIndex
        fetchMovies(apiUrls[index], segmentIndex: index, limit: currentLimits[index])
        refreshControl.endRefreshing()
    }
}


extension HomeTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    //===========================================================================
    //MARK - TABLEVIEW
    //===========================================================================
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        switch tableView.tag {
        case 0:
            return newMovies.count
        case 1:
            return recommendedMovies.count
        case 2:
            return topdvdMovies.count
        default:
            return 0
        }
    }
    
    //spacing between section
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clearColor()
        return view
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
  
//        print(indexPath.section)
        tableView.registerNib(UINib.init(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieTableViewCell
        var tempMovie:Movie = Movie(json: JSON([]))
        switch tableView.tag {
        case 0:
            tempMovie = newMovies[indexPath.section]
            break
        case 1:
            tempMovie = recommendedMovies[indexPath.section]
            break
        case 2:
            tempMovie = topdvdMovies[indexPath.section]
            break
        default:
            break
        }
//        if (cell.movie == nil || !(cell.movie?.isEqualTo(tempMovie))!){
//            cell.setMovie(tempMovie)
//        }
        cell.movie = tempMovie
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let movie:Movie!
        selectedMovie = (tableView.cellForRowAtIndexPath(indexPath) as! MovieTableViewCell).movie
        selectedGenreString = nil
        selectedImage = nil
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        fetchImageGenreAndSegue(selectedMovie)
        
//        self.performSegueWithIdentifier("MovieView", sender: self)
        
    }
    
    func reloadTable(movies:[Movie],_ tableView:UITableView) {
//        tableView0BottomConstraint.constant = -48 - (tableView0.estimatedRowHeight*CGFloat(newMovies.count))
//        tableView1BottomConstraint.constant = -48 - (tableView1.estimatedRowHeight*CGFloat(recommendedMovies.count))
//        tableView2BottomConstraint.constant = -48 - (tableView2.estimatedRowHeight*CGFloat(topdvdMovies.count))
        
        tableView.reloadData()
    }
    
    //===========================================================================
    //MARK - SCROLL VIEW
    //===========================================================================
    func scrollViewDidScroll(scrollView: UIScrollView) {
////        self.navigationController?.setNavigationBarHidden(true, animated: true)
        if(scrollView.contentOffset.y != -64 && scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            //user has scrolled to the bottom
            let index = movieSegControl.selectedSegmentIndex
            currentLimits[index] += 20
            fetchMovies(apiUrls[index], segmentIndex: index, limit: currentLimits[index])
        }
    }
//    func scrollViewDidScrollToTop(scrollView: UIScrollView) {
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
//    }
}

extension HomeTableViewController: UISearchBarDelegate{
    //===========================================================================
    //MARK - RECOMMENDED SEARCH
    //===========================================================================
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

