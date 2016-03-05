//
//  LoginViewController.swift
//  BuzzMovie
//
//  Created by Brian Wang on 2/23/16.
//  Copyright © 2016 DK. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    //
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var staySwitch: UISwitch!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var stayLabel: UILabel!
    @IBOutlet weak var loginRegisterButton: UIButton!
    @IBOutlet weak var loggingInLabel: UILabel!
    
    
    //Register Specific
    @IBOutlet weak var retypePasswordField: UITextField!
    @IBOutlet weak var majorField: UITextField!
    @IBOutlet weak var interestsField: UITextField!
    
    @IBOutlet weak var containerViewCenterX: NSLayoutConstraint!
    @IBOutlet weak var containerViewCenterY: NSLayoutConstraint!
    @IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    
    var root = Firebase(url: "https://deeknutssquad.firebaseio.com/")
    
    
    var registerMode: Bool = false {
        didSet {
            if registerMode {
                animateToRegisterMode()
                //loginRegisterButton = register
                loginRegisterButton.addTarget(nil, action: Selector("register"), forControlEvents: .TouchUpInside)
                loginRegisterButton.setAttributedTitle(NSAttributedString(string: "Register"), forState: .Normal)
                
                //registerButton = back to login
                registerButton.addTarget(nil, action: Selector("loginModeSwitch"), forControlEvents: .TouchUpInside)
                registerButton.setAttributedTitle(NSAttributedString(string: "Back to Login"), forState: .Normal)
            } else {
                animateToLoginMode()
                //loginRegisterButton = register
                loginRegisterButton.addTarget(nil, action: Selector("login"), forControlEvents: .TouchUpInside)
                loginRegisterButton.setAttributedTitle(NSAttributedString(string: "Login"), forState: .Normal)
                
                //registerButton = back to login
                registerButton.addTarget(nil, action: Selector("registerModeSwitch"), forControlEvents: .TouchUpInside)
                registerButton.setAttributedTitle(NSAttributedString(string: "Register"), forState: .Normal)
                
            }
        }
    }
    
    
    //===========================================================================
    //MARK - VIEWDIDLOAD/VIEWWILLAPPEAR
    //===========================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginRegisterButton.addTarget(nil, action: Selector("login"), forControlEvents: .TouchUpInside)
        registerButton.addTarget(nil, action: Selector("registerModeSwitch"), forControlEvents: .TouchUpInside)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidAppear:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidDisappear", name: UIKeyboardWillHideNotification, object: nil)
        
        containerViewHeight.constant = 190
        self.view.layoutIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //===========================================================================
    //MARK: - KEYBOARD
    //===========================================================================
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!.locationInView(self.view)
        if !CGRectContainsPoint(containerView.frame, touch) {
            usernameField.resignFirstResponder()
            passwordField.resignFirstResponder()
        }
    }
    
    func keyboardDidAppear(notification: NSNotification) {
        if let userInfo = notification.userInfo, frame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue {
            let height = frame().height
            let constant = 0 - (height / (is4S() ? 2.5 : 3))
            
            if constant == containerViewCenterY.constant { return }
            
            UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
                    self.containerViewCenterY.constant = constant
                    self.view.layoutIfNeeded()
                }, completion: nil)
        }
        
    }
    
    func keyboardDidDisappear() {
        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
                self.containerViewCenterY.constant = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        
    }
    
    
    @IBAction func didPressNext(sender: AnyObject) {
        passwordField.becomeFirstResponder()
    }
    
    @IBAction func didPressGo(sender: AnyObject) {
        passwordField.resignFirstResponder()
        login()
    }
    
    //===========================================================================
    //MARK: - SEGUES
    //===========================================================================
    
    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    func segueToUser() {
//        self.performSegueWithIdentifier("UserSegue", sender: self)
        loginFailed()
    }
    
    
    //===========================================================================
    //MARK: - LOGIN
    //===========================================================================
    
    func login() {
        if (usernameField.text == "" || passwordField.text == "") {
            shakeCenterX()
            return
        }
        performSelector(Selector("segueToUser"), withObject: self, afterDelay: 1)
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        UIView.animateWithDuration(0.5, animations: {
            self.titleLabel.alpha = 0
            self.usernameField.alpha = 0
            self.passwordField.alpha = 0
            self.staySwitch.alpha = 0
            self.registerButton.alpha = 0
            self.stayLabel.alpha = 0
            self.loginRegisterButton.alpha = 0
            self.loggingInLabel.alpha = 1
        })
        
    }
    
    func loginFailed() {
        
        shakeCenterX()
        UIView.animateWithDuration(0.5, animations: {
            self.titleLabel.alpha = 1
            self.usernameField.alpha = 1
            self.passwordField.alpha = 1
            self.staySwitch.alpha = 1
            self.registerButton.alpha = 1
            self.stayLabel.alpha = 1
            self.loginRegisterButton.alpha = 1
            self.loggingInLabel.alpha = 0
        })
        
    }
    //===========================================================================
    //MARK: - REGISTER
    //===========================================================================
    func registerModeSwitch() {
        registerMode = true
    }
    
    func register() {
        
    }
    
    func loginModeSwitch() {
        registerMode = false
    }
    
    //===========================================================================
    //MARK: - ANIMATIONS
    //===========================================================================
    
    func shakeCenterX() {
        let animations:[CGFloat] = [20.0, -20.0, 10.0, -10.0, 3.0, -3.0, 0.0]
        
        for i in 0..<animations.count {
            let constant = animations[i]
            UIView.animateWithDuration(0.075, delay: 0.075 * Double(i), usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
                self.containerViewCenterX.constant = constant
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    func animateViewToCenter() {
        
    }
    
    func showLoginAnimation() {
        
    }
    
    func animateToRegisterMode() {
        UIView.animateWithDuration(1.5, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: [], animations: {
            self.retypePasswordField.alpha = 1
            self.majorField.alpha = 1
            self.interestsField.alpha = 1
            self.containerViewHeight.constant = 300
            self.view.layoutIfNeeded()
            }, completion: nil)
    }

    func animateToLoginMode() {
        UIView.animateWithDuration(1.5, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: [], animations: {
            self.retypePasswordField.alpha = 0
            self.majorField.alpha = 0
            self.interestsField.alpha = 0
            self.containerViewHeight.constant = 190
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
}
