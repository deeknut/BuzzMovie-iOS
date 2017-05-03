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
import Firebase
import FirebaseDatabase
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
    
    //firebase
    
    //tableView sources
    var newMovies:[Movie] = [] {
        didSet {
            movieDidSet(newMovies, tableView0)
        }
    }
    var rawRecommendedMovies:[Movie] = []
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
    
    func movieDidSet(_ movies:[Movie],_ tableView: UITableView) {
        reloadTable(movies, tableView)
        if movies.count == 0 {
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
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
        searchBar.isHidden = true
       
        //refresh control
        let refreshControl0 = UIRefreshControl()
        refreshControl0.addTarget(self, action: #selector(HomeTableViewController.refresh), for: .valueChanged)
        let refreshControl1 = UIRefreshControl()
        refreshControl1.addTarget(self, action: #selector(HomeTableViewController.refresh), for: .valueChanged)
        let refreshControl2 = UIRefreshControl()
        refreshControl2.addTarget(self, action: #selector(HomeTableViewController.refresh), for: .valueChanged)
        tableView0.addSubview(refreshControl0)
        tableView1.addSubview(refreshControl1)
        tableView2.addSubview(refreshControl2)
        
        //color consistency
        movieSegControl.backgroundColor = StyleConstants.defaultGrayColor
        searchBar.backgroundColor = StyleConstants.defaultGrayColor
        
        //default tableviews are hidden
        self.tableView0.isHidden = true
        self.tableView1.isHidden = true
        self.tableView2.isHidden = true
    
        
        
        //white status bar
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }

    
    //===========================================================================
    //MARK - NAV BAR
    //===========================================================================
    
    override func willMove(toParentViewController parent: UIViewController?) {
//        if let _ = parent {
//            self.navigationController?.hidesBarsOnSwipe = true
//        } else {
//            self.navigationController?.hidesBarsOnSwipe = false
//        }
    }
    
    //===========================================================================
    //MARK - SEGUES
    //===========================================================================
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! MovieViewController
        destination.movie = self.selectedMovie
        destination.selectedImage = self.selectedImage
        destination.selectedGenreString = self.selectedGenreString

//        destination.originalImage = selectedMovie.originalImage
    }
    
    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        reloadTable(newMovies, tableView0)
        reloadTable(recommendedMovies, tableView1)
        reloadTable(topdvdMovies, tableView2)
    }
    
    //===========================================================================
    //MARK - SEGCONTROL
    //===========================================================================
    
    @IBAction func segValueDidChange(_ sender: AnyObject) {
        searchBar.resignFirstResponder()
        setMovies()
    }
    
    func setMovies() {
        switch movieSegControl.selectedSegmentIndex {
        case 0:
            searchBar.isHidden = true
            checkMovies(tableView0, newMovies)
            tableView1.isHidden = true
            tableView2.isHidden = true
            break
        case 1:
            searchBar.isHidden = false
            tableView0.isHidden = true
            checkMovies(tableView1, recommendedMovies)
            tableView2.isHidden = true
            break
        case 2:
            searchBar.isHidden = true
            tableView0.isHidden = true
            tableView1.isHidden = true
            checkMovies(tableView2, topdvdMovies)
            break
        default:
            break
        }
        
    }
    
    func checkMovies(_ tableView:UITableView,_ movies:[Movie]) {
        if (movies.count != 0) {
            tableView.isHidden = false
        } else {
            tableView.isHidden = true
        }
    }
    
    //===========================================================================
    //MARK - API CALLS
    //===========================================================================
    func fetchMovies(_ url: String, segmentIndex:Int, limit:Int) {
        if segmentIndex == 1 {
            fetchRecommendations({ movies in
                self.rawRecommendedMovies = movies
                let tempMovies = movies.filter({ movie in
                    if self.searchBar.text == "" {
                        return true
                    }
                    return movie.major!.contains(self.searchBar.text!)
                })
                if !self.moviesIsEqual(tempMovies, self.recommendedMovies) {
                    self.recommendedMovies = tempMovies
                    self.setMovies()
                }
                
            })
            return
        }
        var fetchedMovies:[Movie] = []
        let parameters = [
            "apikey": RT_API_KEY,
            "limit": "\(limit)"
        ]
        Alamofire.request(url, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {response in
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
    
    func fetchImageGenreAndSegue(_ movie:Movie) {
        let searchurl = "https://api.themoviedb.org/3/search/movie"
        let imagebaseurl = "http://image.tmdb.org/t/p/original"
        let parameters = [
            "api_key": TMDB_API_KEY,
            "query": movie.title
        ]
        Alamofire.request(searchurl, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {response in
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
    
    func fetchRecommendations(_ closure:@escaping ([Movie]) -> Void) {
        var movies:[Movie] = []
        root?.child(byAppendingPath: "users").observeSingleEvent(of: .value, with: { snapshot in
            var usersCount:UInt = 0
            for s in snapshot.children {
                
                let uidSnapshot = s as! FIRDataSnapshot
                
                root?.child(byAppendingPath: "users/\(uidSnapshot.key)/recommendations").observeSingleEvent(of: .value, with: { recSnapshots in
                    if recSnapshots.childrenCount == 0 {
                        usersCount += 1
                    }
                    var recCount:UInt = 0
                    for r in recSnapshots.children {
                        let recommendation = r as! FIRDataSnapshot
                        let RTid = recommendation.key
                        let url = "http://api.rottentomatoes.com/api/public/v1.0/movies/\(RTid).json"
                        let major = recommendation.value(forKey: "major")
                        let parameters = ["apikey": RT_API_KEY]
                        Alamofire.request(url, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {response in
                                //                print(response.request)  // original URL request
                                //                print(response.response) // URL response
                                //                print(response.data)     // server data
                                //                print(response.result)   // result of response serialization
                                
                                if let unconvertedJSON = response.result.value {
//                                    print("\(unconvertedJSON)")
                                    let json:JSON = JSON(unconvertedJSON)
                                    let movie = Movie(json: json)
                                    movie.major = major as? String
                                    movie.loadAvgRating({avgRating in
                                        if let _ = avgRating {
                                            movies.append(movie)
                                        }
                                        if (recCount >= recSnapshots.childrenCount - 1 && usersCount >= snapshot.childrenCount - 1) {
                                            movies.sort(by: {movie1, movie2 in
                                                return (movie1.avgRating! - movie2.avgRating! > 0)
                                            })
                                            closure(movies)
                                        }
                                        if (recCount >= recSnapshots.childrenCount - 1) {
                                            recCount = 0
                                            usersCount += 1
                                        } else {
                                            recCount += 1
                                        }
                                    })
                                
                                }
                        }
                    }
                })
                
            }
        })
    }
    
    func moviesIsEqual(_ movies1:[Movie],_ movies2:[Movie]) -> Bool{
        return movies1.elementsEqual(movies2, by: {movie1, movie2 in return movie1.RTid == movie2.RTid })
    }
    
    //===========================================================================
    //MARK - REFRESH
    //===========================================================================
    func refresh(_ refreshControl: UIRefreshControl) {
        let index = movieSegControl.selectedSegmentIndex
        fetchMovies(apiUrls[index], segmentIndex: index, limit: currentLimits[index])
        refreshControl.endRefreshing()
    }
}


extension HomeTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    //===========================================================================
    //MARK - TABLEVIEW
    //===========================================================================
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
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
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  
//        print(indexPath.section)
        tableView.register(UINib.init(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieTableViewCell
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let movie:Movie!
        selectedMovie = (tableView.cellForRow(at: indexPath) as! MovieTableViewCell).movie
        selectedGenreString = nil
        selectedImage = nil
        tableView.deselectRow(at: indexPath, animated: true)
        fetchImageGenreAndSegue(selectedMovie)
        
//        self.performSegueWithIdentifier("MovieView", sender: self)
        
    }
    
    func reloadTable(_ movies:[Movie],_ tableView:UITableView) {
//        tableView0BottomConstraint.constant = -48 - (tableView0.estimatedRowHeight*CGFloat(newMovies.count))
//        tableView1BottomConstraint.constant = -48 - (tableView1.estimatedRowHeight*CGFloat(recommendedMovies.count))
//        tableView2BottomConstraint.constant = -48 - (tableView2.estimatedRowHeight*CGFloat(topdvdMovies.count))
        
        tableView.reloadData()
    }
    
    //===========================================================================
    //MARK - SCROLL VIEW
    //===========================================================================
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
////        self.navigationController?.setNavigationBarHidden(true, animated: true)
        if(scrollView.contentOffset.y != -64 && scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            //user has scrolled to the bottom
            let index = movieSegControl.selectedSegmentIndex
            if index == 1 {
                return
            }
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let tempMovies = rawRecommendedMovies.filter({ movie in
            if searchText == "" {
                return true
            }
            return movie.major!.contains(searchText)
        })
        if !self.moviesIsEqual(tempMovies, self.recommendedMovies) {
            self.recommendedMovies = tempMovies
            self.setMovies()
        }
    }
    
}

