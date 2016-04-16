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

    @IBOutlet weak var tableView: UITableView!
    
    var searchController: UISearchController!
    
    var movies:[Movie] = []
    
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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        tableView.registerNib(UINib.init(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchCell")
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchCell", forIndexPath: indexPath) as! SearchTableViewCell
        cell.dataReceived = false
        cell.dataPending = false
        cell.posterImageView.image = UIImage(named: "DefaultPosterImage")
        cell.movie = movies[indexPath.row]
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
}

extension SearchTableViewController: UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate {
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
