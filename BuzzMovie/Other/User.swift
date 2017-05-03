//
//  User.swift
//  BuzzMovie
//
//  Created by Brian Wang on 4/25/16.
//  Copyright © 2016 DK. All rights reserved.
//

import UIKit
import Firebase

class User: AnyObject {
    var snapshot:FIRDataSnapshot!
    init(snapshot:FIRDataSnapshot) {
        self.snapshot = snapshot
    }
    
    var uid:String {
        return snapshot.key
    }
    
    var email:String {
        return snapshot.value(forKey: "email") as! String
    }
    
    var locked:Bool {
        return snapshot.value(forKey: "locked") as! String == "true"
    }
    
    var banned:Bool {
        return snapshot.value(forKey: "banned") as! String == "true"
    }
    
    var admin:Bool {
        return snapshot.value(forKey: "admin") as! String == "true"
    }
    
    var registerDate:String {
        return snapshot.value(forKey: "registerdate") as! String
    }
    
    var interests:String {
        return snapshot.value(forKey: "interests") as! String
    }
    
    var major:String {
        return snapshot.value(forKey: "major") as! String
    }
}
