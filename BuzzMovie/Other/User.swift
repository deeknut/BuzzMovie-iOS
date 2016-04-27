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
    var snapshot:FDataSnapshot!
    init(snapshot:FDataSnapshot) {
        self.snapshot = snapshot
    }
    
    var uid:String {
        return snapshot.key
    }
    
    var email:String {
        return snapshot.value["email"] as! String
    }
    
    var locked:Bool {
        return snapshot.value["locked"] as! String == "true"
    }
    
    var banned:Bool {
        return snapshot.value["banned"] as! String == "true"
    }
    
    var admin:Bool {
        return snapshot.value["admin"] as! String == "true"
    }
    
    var registerDate:String {
        return snapshot.value["registerdate"] as! String
    }
    
    var interests:String {
        return snapshot.value["interests"] as! String
    }
    
    var major:String {
        return snapshot.value["major"] as! String
    }
}
