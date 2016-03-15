//
//  MainTabBarViewController.swift
//  BuzzMovie
//
//  Created by Brian Wang on 3/14/16.
//  Copyright © 2016 DK. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        for item in self.tabBar.items! {
            item.title = nil
            item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
        }
    }
    
    @IBAction func unwindToTabBar(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        performSegueWithIdentifier("unwindToLogin", sender: self)
    }
}
