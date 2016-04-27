//
//  LoginViewController.swift
//  BuzzMovie
//
//  Created by Brian Wang on 2/23/16.
//  Copyright © 2016 DK. All rights reserved.
//

import UIKit
import Firebase

var uid: String!

class LoginViewController: UIViewController {
    
    //General Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var staySwitch: UISwitch!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var stayLabel: UILabel!
    @IBOutlet weak var loginRegisterButton: UIButton!
    @IBOutlet weak var loggingInLabel: UILabel!
    
    //Register Specific Outlets
    @IBOutlet weak var retypePasswordField: UITextField!
    @IBOutlet weak var majorField: UITextField!
    @IBOutlet weak var interestsField: UITextField!
    
    //AutoLayoutConstraint References
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
                loginRegisterButton.removeTarget(nil, action: #selector(LoginViewController.prepareToLogin), forControlEvents: .TouchUpInside)
                loginRegisterButton.addTarget(nil, action: #selector(LoginViewController.register), forControlEvents: .TouchUpInside)
                loginRegisterButton.setAttributedTitle(NSAttributedString(string: "Register"), forState: .Normal)
                
                //registerButton = back to login
                registerButton.removeTarget(nil, action: #selector(LoginViewController.registerModeSwitch), forControlEvents: .TouchUpInside)
                registerButton.addTarget(nil, action: #selector(LoginViewController.loginModeSwitch), forControlEvents: .TouchUpInside)
                registerButton.setAttributedTitle(NSAttributedString(string: "Back to Login"), forState: .Normal)
                
                //passwordKeyboard
                passwordField.returnKeyType = .Next
            } else {
                animateToLoginMode()
                //loginRegisterButton = register
                loginRegisterButton.removeTarget(nil, action: #selector(LoginViewController.register), forControlEvents: .TouchUpInside)
                loginRegisterButton.addTarget(nil, action: #selector(LoginViewController.prepareToLogin), forControlEvents: .TouchUpInside)
                loginRegisterButton.setAttributedTitle(NSAttributedString(string: "Login"), forState: .Normal)
                
                //registerButton = back to login
                registerButton.removeTarget(nil, action: #selector(LoginViewController.loginModeSwitch), forControlEvents: .TouchUpInside)
                registerButton.addTarget(nil, action: #selector(LoginViewController.registerModeSwitch), forControlEvents: .TouchUpInside)
                registerButton.setAttributedTitle(NSAttributedString(string: "Register"), forState: .Normal)
                
                //passwordKeyboard
                passwordField.returnKeyType = .Go
            }
        }
    }
    
    
    //===========================================================================
    //MARK - VIEWDIDLOAD/VIEWWILLAPPEAR
    //===========================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        
        loginRegisterButton.addTarget(nil, action: #selector(LoginViewController.prepareToLogin), forControlEvents: .TouchUpInside)
        registerButton.addTarget(nil, action: #selector(LoginViewController.registerModeSwitch), forControlEvents: .TouchUpInside)
        self.navigationController?.navigationBarHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardDidAppear(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardDidDisappear), name: UIKeyboardWillHideNotification, object: nil)
        containerViewHeight.constant = 190
        self.view.layoutIfNeeded()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let username = defaults.objectForKey("username"), password = defaults.objectForKey("password") {
            usernameField.text = username as? String
            passwordField.text = password as? String
            prepareToLogin()
        }
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
    
    
    @IBAction func didPressNext(sender: UITextField) {
        let fieldName = sender.placeholder!
        switch fieldName {
            case "Username":
                passwordField.becomeFirstResponder()
                break;
            case "Password":
                if (!registerMode) {
                    prepareToLogin()
                } else {
                    retypePasswordField.becomeFirstResponder()
                }
                break;
            case "Retype Password":
                majorField.becomeFirstResponder()
                break;
            case "Major":
                interestsField.becomeFirstResponder()
                break;
            case "Interests":
                if (registerMode) {
                    register()
                }
                break;
            default:
                break;
        }
    }
    
    @IBAction func editingDidBegin(sender: UITextField) {
        sender.textColor = StyleConstants.defaultBlueColor
    }
    
    func resignAllResponders() {
        self.usernameField.resignFirstResponder()
        self.passwordField.resignFirstResponder()
        self.retypePasswordField.resignFirstResponder()
        self.majorField.resignFirstResponder()
        self.interestsField.resignFirstResponder()
    }
    
    func clearAllFields() {
        usernameField.text = ""
        passwordField.text = ""
        retypePasswordField.text = ""
        majorField.text = ""
        interestsField.text = ""
    }
    //===========================================================================
    //MARK: - NSUSERDEFAULTS
    //===========================================================================
    func clearDefaultCredentials() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("username")
        defaults.removeObjectForKey("password")
        defaults.synchronize()
        
    }
    
    func setDefaultCredentials(username:String, password:String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(username, forKey: "username")
        defaults.setObject(password, forKey: "password")
        defaults.synchronize()
    }
    
    //===========================================================================
    //MARK: - SEGUES
    //===========================================================================
    
    @IBAction func unwindToLogin(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        if unwindSegue.identifier != "Admin" {
            clearAllFields()
            clearDefaultCredentials()
        }
        animateToLoginMode()
        showLoginFields()
        titleLabel.text = "BuzzMovie"
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    
    
    //===========================================================================
    //MARK: - LOGIN
    //===========================================================================
    
    func prepareToLogin() {
//        self.titleLabel.text = "BuzzMovie"
        if (usernameField.text == "" || passwordField.text == "") {
            shakeCenterX()
            return
        }
        
        let usersRoot = root.childByAppendingPath("users")
        usersRoot.observeSingleEventOfType(.Value, withBlock: {snapshot in
            var found = false
            for uidsnapshot in snapshot.children {
                let fetchedEmail = uidsnapshot.value["email"] as! String
                if (fetchedEmail == self.usernameField.text!) {
                    found = true
                    let banned = uidsnapshot.value["banned"] as! String
                    if banned == "true" {
                       //account banned.
                        self.titleLabel.text = "Account Banned. Contact Admin"
                        self.clearDefaultCredentials()
                        self.loginFailed()
                    } else {
                        let locked = uidsnapshot.value["locked"] as! String
                        if locked == "true" {
                            //account locked.
                            self.titleLabel.text = "Account Locked. Contact Admin"
                            self.clearDefaultCredentials()
                            self.loginFailed()
                        } else {
                            //account isn't locked, continue with authenticating
                            self.login()
                        }
                    }
                }
            }
            if !found {
                self.titleLabel.text = "User Not Found. Register?"
                self.clearDefaultCredentials()
                self.loginFailed()
            }
        })
        
    }
    
    func login() {
        resignAllResponders()
        loggingInLabel.text = "Logging in..."
        showLoginLabel()
        self.root.authUser(self.usernameField.text, password: self.passwordField.text, withCompletionBlock: {error, authData in
            if error != nil {
                self.loginFailed()
                if (error.userInfo[NSLocalizedDescriptionKey]!.containsString("INVALID_PASSWORD")) {
                    //invalid password, mark for incorrect login
                    self.markUserForIncorrectLogin(self.usernameField.text!)
                }
            } else {
                uid = authData.uid
                let uidRoot = self.root.childByAppendingPath("users/\(uid)")
                uidRoot.childByAppendingPath("loginattempts").setValue("0")
                if (self.staySwitch.on) {
                    self.setDefaultCredentials(self.usernameField.text!, password: self.passwordField.text!)
                }
                uidRoot.observeSingleEventOfType(.Value, withBlock: { snapshot in
                    if let isAdmin = snapshot.value["admin"] as! String? {
                        if isAdmin == "true" {
                            let alertController = UIAlertController(title: "Admin Privileges", message: "Choose your mode", preferredStyle: .Alert)
                            let actionAdmin = UIAlertAction(title: "Admin", style: .Default, handler: { action in
                                self.performSegueWithIdentifier("AdminSegue", sender: self)
                            })
                            let actionUser = UIAlertAction(title: "User", style: .Default, handler: { action in
                                self.performSegueWithIdentifier("UserSegue", sender: self)
                            })
                            alertController.addAction(actionAdmin)
                            alertController.addAction(actionUser)
                            
                            self.presentViewController(alertController, animated: true, completion: nil)
                        } else {
                            //default
                            self.performSegueWithIdentifier("UserSegue", sender: self)
                            
                        }
                    }
                })
            }
        })
    }
    
    func markUserForIncorrectLogin(email:String) {
        let usersRoot = root.childByAppendingPath("users")
        usersRoot.observeSingleEventOfType(.Value, withBlock: {snapshot in
//            print(snapshot.value)
            for uidsnapshot in snapshot.children {
                let fetchedEmail = uidsnapshot.value["email"] as! String
                
                if (fetchedEmail == email) {
                    let attempts:Int = Int(uidsnapshot.value["loginattempts"] as! String)!
                    let uid = uidsnapshot.key
                    let uidRoot = usersRoot.childByAppendingPath("\(uid)")
                    if (attempts == 2) {
                        self.titleLabel.text = "Account Locked. Contact Admin"
                        uidRoot.childByAppendingPath("locked").setValue("true")
                    } else {
                        self.titleLabel.text = "Wrong Password. \(2 - attempts) Attempts Left"
                    }
                    uidRoot.childByAppendingPath("loginattempts").setValue(String(attempts + 1))
                }
            }
        })
    }
    
    func isLocked(email:String) {
    }
    
    func loginFailed() {
        showLoginFields()
        shakeCenterX()
        
    }
    //===========================================================================
    //MARK: - REGISTER
    //===========================================================================
    func registerModeSwitch() {
        registerMode = true
    }
    
    func register() {
        if (usernameField.text == "") {
            shakeCenterX()
            usernameField.textColor = UIColor.redColor()
            return
        }
        if (passwordField.text == ""){
            shakeCenterX()
            passwordField.textColor = UIColor.redColor()
            return
        }
        if (passwordField.text != retypePasswordField.text) {
            shakeCenterX()
            //maybe do something about how password don't match
            passwordField.textColor = UIColor.redColor()
            retypePasswordField.textColor = UIColor.redColor()
            return
        }
        resignAllResponders()
        loggingInLabel.text = "Registering..."
        showRegisterLabel()
        
        var dateFormatter:NSDateFormatter = {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy"
            return dateFormatter
        }()
        
        //creation
        root.createUser(usernameField.text, password: passwordField.text,
            withValueCompletionBlock: { error, result in
                if error != nil {
                    self.registerFailed()
                    // There was an error creating the account
                } else {
                    uid = result["uid"] as! String
                    let initialValues = [
                        "email": self.usernameField.text!,
                        "major": self.majorField.text!,
                        "interests": self.interestsField.text!,
                        "locked": "false",
                        "admin": "false",
                        "loginattempts": "0",
                        "banned": "false",
                        "registerdate": dateFormatter.stringFromDate(NSDate())
                    ]
                    let uidRoot = self.root.childByAppendingPath("users/\(uid)")
                    uidRoot.setValue(initialValues)
//                    self.loginModeSwitch()
                    self.registerMode = false
                    self.animateToLoginMode()
                    self.performSelector(#selector(LoginViewController.login), withObject: self, afterDelay: 1)
                    print("Successfully created user account with uid: \(uid)")
                }
        })
    }
    func registerFailed() {
        shakeCenterX()
        showRegisterFields()
    }
    
    func loginModeSwitch() {
        registerMode = false
        showLoginFields()
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
    
    func animateToRegisterMode() {
        UIView.animateWithDuration(0.5, delay: 0, options: [], animations: {
            self.retypePasswordField.alpha = 1
            self.majorField.alpha = 1
            self.interestsField.alpha = 1
            self.containerViewHeight.constant = 300
            self.view.layoutIfNeeded()
            }, completion: nil)
    }

    func animateToLoginMode() {
        UIView.animateWithDuration(0.5, delay: 0, options: [], animations: {
            self.retypePasswordField.alpha = 0
            self.majorField.alpha = 0
            self.interestsField.alpha = 0
            self.containerViewHeight.constant = 190
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func showLoginFields() {
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
    
    func showRegisterFields() {
        UIView.animateWithDuration(0.5, animations: {
            self.titleLabel.alpha = 1
            self.usernameField.alpha = 1
            self.passwordField.alpha = 1
            self.staySwitch.alpha = 1
            self.registerButton.alpha = 1
            self.stayLabel.alpha = 1
            self.loginRegisterButton.alpha = 1
            self.retypePasswordField.alpha = 1
            self.majorField.alpha = 1
            self.interestsField.alpha = 1
            self.loggingInLabel.alpha = 0
        })
    }
    
    func showLoginLabel() {
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
    
    func showRegisterLabel() {
        UIView.animateWithDuration(0.5, animations: {
            self.titleLabel.alpha = 0
            self.usernameField.alpha = 0
            self.passwordField.alpha = 0
            self.staySwitch.alpha = 0
            self.registerButton.alpha = 0
            self.stayLabel.alpha = 0
            self.loginRegisterButton.alpha = 0
            self.retypePasswordField.alpha = 0
            self.majorField.alpha = 0
            self.interestsField.alpha = 0
            self.loggingInLabel.alpha = 1
        })
    }
}
