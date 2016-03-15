//
//  HomeTableViewController.swift
//  BuzzMovie
//
//  Created by Brian Wang on 2/23/16.
//  Copyright © 2016 DK. All rights reserved.
//

import UIKit

class HomeTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
//    let API_KEY
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

}


extension HomeTableViewController {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
    //spacing between section
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 7
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clearColor()
        return view
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
  
        tableView.registerNib(UINib.init(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell") as! MovieTableViewCell
            
        // Configure the cell...

        return cell
    }
}
