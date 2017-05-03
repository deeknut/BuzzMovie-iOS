//
//  Extra.swift
//  BuzzMovie
//
//  Created by Brian Wang on 2/24/16.
//  Copyright © 2016 DK. All rights reserved.
//

import UIKit

///returns trus if the current device is an iPad
func iPad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
}

///returns trus if the current device is an iPhone 4S
func is4S() -> Bool {
    return UIScreen.main.bounds.height == 480.0
}

extension UIColor {
    static func colorFromHex(_ hex: Int) -> UIColor {
        return UIColor.init(red: CGFloat(Double((hex & 0xFF0000) >> 16)/255.0), green: CGFloat(Double((hex & 0x00FF00) >> 8)/255.0), blue: CGFloat(Double((hex & 0x0000FF) >> 0)/255.0), alpha: 1.0)
    }
}

extension UINavigationController {
    
    open override var childViewControllerForStatusBarHidden : UIViewController? {
        return self.topViewController
    }
    
    open override var childViewControllerForStatusBarStyle : UIViewController? {
        return self.topViewController
    }
}

extension Int {
    var runtimeString:String {
        let hours = self/60
        let minutes = self%60
        let runTimeString = "\(hours) hr. \(minutes) min."
        return runTimeString
    }
}
