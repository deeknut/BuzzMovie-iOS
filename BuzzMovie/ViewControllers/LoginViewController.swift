//
//  LoginViewController.swift
//  BuzzMovie
//
//  Created by Brian Wang on 2/23/16.
//  Copyright © 2016 DK. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

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
    
    
//    var root = Firebase(url: "https://deeknutssquad.firebaseio.com/")
    
    
    var registerMode: Bool = false {
        didSet {
            if registerMode {
                animateToRegisterMode()
                //loginRegisterButton = register
                loginRegisterButton.removeTarget(nil, action: #selector(LoginViewController.prepareToLogin), for: .touchUpInside)
                loginRegisterButton.addTarget(nil, action: #selector(LoginViewController.register), for: .touchUpInside)
                loginRegisterButton.setAttributedTitle(NSAttributedString(string: "Register"), for: UIControlState())
                
                //registerButton = back to login
                registerButton.removeTarget(nil, action: #selector(LoginViewController.registerModeSwitch), for: .touchUpInside)
                registerButton.addTarget(nil, action: #selector(LoginViewController.loginModeSwitch), for: .touchUpInside)
                registerButton.setAttributedTitle(NSAttributedString(string: "Back to Login"), for: UIControlState())
                
                //passwordKeyboard
                passwordField.returnKeyType = .next
            } else {
                animateToLoginMode()
                //loginRegisterButton = register
                loginRegisterButton.removeTarget(nil, action: #selector(LoginViewController.register), for: .touchUpInside)
                loginRegisterButton.addTarget(nil, action: #selector(LoginViewController.prepareToLogin), for: .touchUpInside)
                loginRegisterButton.setAttributedTitle(NSAttributedString(string: "Login"), for: UIControlState())
                
                //registerButton = back to login
                registerButton.removeTarget(nil, action: #selector(LoginViewController.loginModeSwitch), for: .touchUpInside)
                registerButton.addTarget(nil, action: #selector(LoginViewController.registerModeSwitch), for: .touchUpInside)
                registerButton.setAttributedTitle(NSAttributedString(string: "Register"), for: UIControlState())
                
                //passwordKeyboard
                passwordField.returnKeyType = .go
            }
        }
    }
    
    
    //===========================================================================
    //MARK - VIEWDIDLOAD/VIEWWILLAPPEAR
    //===========================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        
        loginRegisterButton.addTarget(nil, action: #selector(LoginViewController.prepareToLogin), for: .touchUpInside)
        registerButton.addTarget(nil, action: #selector(LoginViewController.registerModeSwitch), for: .touchUpInside)
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardDidAppear(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardDidDisappear), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        containerViewHeight.constant = 190
        self.view.layoutIfNeeded()
        
        let defaults = UserDefaults.standard
        if let username = defaults.object(forKey: "username"), let password = defaults.object(forKey: "password") {
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!.location(in: self.view)
        if !containerView.frame.contains(touch) {
            usernameField.resignFirstResponder()
            passwordField.resignFirstResponder()
        }
    }
    
    func keyboardDidAppear(_ notification: Notification) {
        if let userInfo = notification.userInfo, let frame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let height = frame.height
            let constant = 0 - (height / (is4S() ? 2.5 : 3))
            
            if constant == containerViewCenterY.constant { return }
            
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
                    self.containerViewCenterY.constant = constant
                    self.view.layoutIfNeeded()
                }, completion: nil)
        }
        
    }
    
    func keyboardDidDisappear() {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
                self.containerViewCenterY.constant = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        
    }
    
    
    @IBAction func didPressNext(_ sender: UITextField) {
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
    
    @IBAction func editingDidBegin(_ sender: UITextField) {
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
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "username")
        defaults.removeObject(forKey: "password")
        defaults.synchronize()
        
    }
    
    func setDefaultCredentials(_ username:String, password:String) {
        let defaults = UserDefaults.standard
        defaults.set(username, forKey: "username")
        defaults.set(password, forKey: "password")
        defaults.synchronize()
    }
    
    //===========================================================================
    //MARK: - SEGUES
    //===========================================================================
    
    @IBAction func unwindToLogin(_ unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        if unwindSegue.identifier != "Admin" {
            clearAllFields()
            clearDefaultCredentials()
        }
        animateToLoginMode()
        showLoginFields()
        titleLabel.text = "BuzzMovie"
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
        
        
        let usersRoot = root?.child(byAppendingPath: "users")
        usersRoot?.observeSingleEvent(of: .value, with: {snapshot in
            var found = false
            for u in snapshot.children {
                let uidsnapshot = u as! FIRDataSnapshot
                let fetchedEmail = uidsnapshot.value(forKey: "email") as! String
                if (fetchedEmail == self.usernameField.text!) {
                    found = true
                    let banned = uidsnapshot.value(forKey: "banned") as! String
                    if banned == "true" {
                       //account banned.
                        self.titleLabel.text = "Account Banned. Contact Admin"
                        self.clearDefaultCredentials()
                        self.loginFailed()
                    } else {
                        let locked = uidsnapshot.value(forKey: "locked") as! String
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
        
        FIRAuth.auth()?.signIn(withEmail: self.usernameField.text!, password: self.passwordField.text!, completion: {authData, error in
            if error != nil {
                self.loginFailed()
//                if (error.userInfo[NSLocalizedDescriptionKey]!.contains("INVALID_PASSWORD")) {
//                    //invalid password, mark for incorrect login
//                    self.markUserForIncorrectLogin(self.usernameField.text!)
//                }
            } else {
                uid = authData?.uid
                let uidRoot = root?.child(byAppendingPath: "users/\(uid)")
                uidRoot?.child(byAppendingPath: "loginattempts").setValue("0")
                if (self.staySwitch.isOn) {
                    self.setDefaultCredentials(self.usernameField.text!, password: self.passwordField.text!)
                }
                uidRoot?.observeSingleEvent(of: .value, with: { snapshot in
                    if let isAdmin = snapshot.value(forKey: "admin") as? String {
                        if isAdmin == "true" {
                            let alertController = UIAlertController(title: "Admin Privileges", message: "Choose your mode", preferredStyle: .alert)
                            let actionAdmin = UIAlertAction(title: "Admin", style: .default, handler: { action in
                                self.performSegue(withIdentifier: "AdminSegue", sender: self)
                            })
                            let actionUser = UIAlertAction(title: "User", style: .default, handler: { action in
                                self.performSegue(withIdentifier: "UserSegue", sender: self)
                            })
                            alertController.addAction(actionAdmin)
                            alertController.addAction(actionUser)
                            
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            //default
                            self.performSegue(withIdentifier: "UserSegue", sender: self)
                            
                        }
                    }
                })
            }
        })
    }
    
    func markUserForIncorrectLogin(_ email:String) {
        let usersRoot = root?.child(byAppendingPath: "users")
        usersRoot?.observeSingleEvent(of: .value, with: {snapshot in
//            print(snapshot.value)
            for u in snapshot.children {
                let uidsnapshot = u as! FIRDataSnapshot
                let fetchedEmail = uidsnapshot.value(forKey: "email") as! String
                
                if (fetchedEmail == email) {
                    let attempts:Int = uidsnapshot.value(forKey: "numattempts") as! Int
                    let uid = uidsnapshot.key
                    let uidRoot = usersRoot?.child(byAppendingPath: "\(uid)")
                    if (attempts == 2) {
                        self.titleLabel.text = "Account Locked. Contact Admin"
                        uidRoot?.child(byAppendingPath: "locked").setValue("true")
                    } else {
                        self.titleLabel.text = "Wrong Password. \(2 - attempts) Attempts Left"
                    }
                    uidRoot?.child(byAppendingPath: "loginattempts").setValue(String(attempts + 1))
                }
            }
        })
    }
    
    func isLocked(_ email:String) {
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
            usernameField.textColor = UIColor.red
            return
        }
        if (passwordField.text == ""){
            shakeCenterX()
            passwordField.textColor = UIColor.red
            return
        }
        if (passwordField.text != retypePasswordField.text) {
            shakeCenterX()
            //maybe do something about how password don't match
            passwordField.textColor = UIColor.red
            retypePasswordField.textColor = UIColor.red
            return
        }
        resignAllResponders()
        loggingInLabel.text = "Registering..."
        showRegisterLabel()
        
        let dateFormatter:DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy"
            return dateFormatter
        }()
        
        //creation
        
        
        FIRAuth.auth()?.createUser(withEmail: usernameField.text!, password: passwordField.text!, completion: {result, error in
                if error != nil {
                    self.registerFailed()
                    // There was an error creating the account
                } else {
                    uid = result?.uid
                    let initialValues = [
                        "email": self.usernameField.text!,
                        "major": self.majorField.text!,
                        "interests": self.interestsField.text!,
                        "locked": "false",
                        "admin": "false",
                        "loginattempts": "0",
                        "banned": "false",
                        "registerdate": dateFormatter.string(from: Date())
                    ]
                    let uidRoot = root?.child(byAppendingPath: "users/\(uid)")
                    uidRoot?.setValue(initialValues)
//                    self.loginModeSwitch()
                    self.registerMode = false
                    self.animateToLoginMode()
                    self.perform(#selector(LoginViewController.login), with: self, afterDelay: 1)
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
            UIView.animate(withDuration: 0.075, delay: 0.075 * Double(i), usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
                self.containerViewCenterX.constant = constant
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    func animateToRegisterMode() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
            self.retypePasswordField.alpha = 1
            self.majorField.alpha = 1
            self.interestsField.alpha = 1
            self.containerViewHeight.constant = 300
            self.view.layoutIfNeeded()
            }, completion: nil)
    }

    func animateToLoginMode() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
            self.retypePasswordField.alpha = 0
            self.majorField.alpha = 0
            self.interestsField.alpha = 0
            self.containerViewHeight.constant = 190
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func showLoginFields() {
        UIView.animate(withDuration: 0.5, animations: {
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
        UIView.animate(withDuration: 0.5, animations: {
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
        UIView.animate(withDuration: 0.5, animations: {
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
        UIView.animate(withDuration: 0.5, animations: {
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
