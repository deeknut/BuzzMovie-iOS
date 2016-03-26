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


class HomeTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    let API_KEY = "yedukp76ffytfuy24zsqk7f5"
    var movies:[Movie] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    func fetchMovies() {
        movies.removeAll()
        let url = "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/opening.json"
        let parameters = [
            "apikey": API_KEY,
            "limit":"5"
        ]
        Alamofire.request(.GET, url, parameters: parameters)
            .responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization
                
                if let unconvertedJSON = response.result.value {
                    print("\(unconvertedJSON)")
                    let json:JSON = JSON(unconvertedJSON)
                    for moviejson in json["movies"].array! {
                        //only purpose of this is to get the full movie data. Secondary .GET gets all the information.
                        let secondaryurl:String = moviejson["links"]["self"].string!
                        Alamofire.request(.GET, secondaryurl, parameters: ["apikey": self.API_KEY])
                            .responseJSON { response in
                                if let unconvertedJSON2 = response.result.value {
                                    let json2:JSON = JSON(unconvertedJSON2)
                                    if let error = json2["error"].string {
                                        print(error)
                                    } else {
                                        let movie = Movie(json: json2 as JSON)
                                        self.movies.append(movie)
                                    }
                                }
                        }

                    }
                }
        }
    }
}


extension HomeTableViewController {
    
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
            
        cell.movie = movies[indexPath.section]
        return cell
    }
}
