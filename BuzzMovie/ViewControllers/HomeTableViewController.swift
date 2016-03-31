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
let OMDB_API_KEY = "a69daed3"

class HomeTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //===========================================================================
    //MARK - VARIABLES
    //===========================================================================
    @IBOutlet weak var tableView: UITableView!

    var movies:[Movie] = [] {
        didSet {
            tableView.reloadData()
            if movies.count == 0 {
                tableView.hidden = true
            } else {
                tableView.hidden = false
            }
        }
    }
    
    //===========================================================================
    //MARK - VIEWDIDLOAD/VIEWWILLAPPEAR
    //===========================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.hidden = true
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(HomeTableViewController.refresh), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
//        self.navigationController?.navigationBarHidden = false
//        self.tabBarController?.navigationController?.navigationBarHidden = false
//        self.navigationItem.title = "BuzzMovie"
//        self.navigationController?.navigationBar.
        
//        self.view.backgroundColor = UIColor.clearColor()
//        self.tableView.backgroundColor = UIColor.clearColor()
//        self.navigationController?.view.backgroundColor = UIColor.clearColor()
//        self.navigationController?.tabBarController?.view.backgroundColor = UIColor.clearColor()
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(animated: Bool) {
        fetchMovies()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //===========================================================================
    //MARK - SEGUES
    //===========================================================================
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    //===========================================================================
    //MARK - API CALLS
    //===========================================================================
    func fetchMovies() {
        var fetchedMovies:[Movie] = []
        let url = "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/opening.json"
        let parameters = [
            "apikey": RT_API_KEY,
            "limit":"20"
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
                        //SPLIT
                        if let error = moviejson["error"].string {
                            print(error)
                        } else {
                            let movie = Movie(json: moviejson as JSON)
                            fetchedMovies.append(movie)
                        }
                    }
                    self.checkMovies(fetchedMovies)
                }
        }
    }
    
    func checkMovies(fetchedMovies:[Movie]) {
        if !fetchedMovies.elementsEqual(movies, isEquivalent: {movie1, movie2 in
            return movie1.RTid == movie2.RTid
        }) {
            movies = fetchedMovies
        }
    }
    
    //===========================================================================
    //MARK - REFRESH
    //===========================================================================
    func refresh(refreshControl: UIRefreshControl) {
        fetchMovies()
        refreshControl.endRefreshing()
    }
}


extension HomeTableViewController {
    
    //===========================================================================
    //MARK - TABLEVIEW
    //===========================================================================
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return movies.count
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
  
        tableView.registerNib(UINib.init(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell") as! MovieTableViewCell
        cell.dataReceived = false
        cell.dataPending = false
        cell.posterImageView.image = UIImage(named: "DefaultPosterImage")
        cell.backgroundImageView.image = nil
        cell.movie = movies[indexPath.section]
        return cell
    }
}
