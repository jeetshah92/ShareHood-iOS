//
//  SignUpViewController.swift
//  VideoTest
//
//  Created by Jeet Shah on 2/5/16.
//  Copyright © 2016 Jeet Shah. All rights reserved.
//



import UIKit
import Alamofire

protocol SHSignUpViewDelegate {
    
    func shSignUpView(sender: SHSignUpView, didPressSignUpButton button: UIButton)
    func shSignUpView(sender: SHSignUpView, didPressLoginLink label: UILabel)
    func shSignUpView(sender: SHSignUpView, didSwipeRight: UISwipeGestureRecognizer)
    
}

class SHSignUpView : UIView {
    
    var welcomeLabel = UILabel()
    var loginLink = UILabel()
    var name = UITextField()
    var username = UITextField()
    var password = UITextField()
    var email = UITextField()
    var signUpButton = UIButton()
    let loadingView = UIActivityIndicatorView()
    var delegate: SHSignUpViewDelegate?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError()
        
    }
    
    override func layoutSubviews() {
        
        
        welcomeLabel.frame = CGRectMake((self.frame.width - self.frame.width * 0.8) / 2, self.frame.height * 0.1, self.frame.width * 0.8 , self.frame.height * 0.05)
        
        name.frame = CGRectMake((self.frame.width - self.frame.width * 0.8) / 2, welcomeLabel.frame.maxY + 20, self.frame.width * 0.8 , self.frame.height * 0.05)
        
        username.frame = CGRectMake((self.frame.width - self.frame.width * 0.8) / 2, name.frame.maxY + 20, self.frame.width * 0.8 , self.frame.height * 0.05)
        
        password.frame = CGRectMake((self.frame.width - self.frame.width * 0.8) / 2, username.frame.maxY + 20, self.frame.width * 0.8 , self.frame.height * 0.05)
        
        email.frame = CGRectMake((self.frame.width - self.frame.width * 0.8) / 2, password.frame.maxY + 20, self.frame.width * 0.8 , self.frame.height * 0.05)
        
        loginLink.frame = CGRectMake((self.frame.width - self.frame.width * 0.8) / 2, email.frame.maxY + 20, self.frame.width * 0.8 , self.frame.height * 0.05)
        
        signUpButton.frame = CGRectMake((self.frame.width - self.frame.width * 0.4) / 2, self.frame.maxY -   2 * self.frame.height * 0.1, self.frame.width * 0.4, self.frame.height * 0.05)
       
        loadingView.frame = self.bounds
        
    }
    
    func setupViews() {

        
        self.backgroundColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: "didSwipeRight:")
        swipeGesture.direction = .Right
        self.addGestureRecognizer(swipeGesture)
        
        welcomeLabel.text = "Welcome To ShareHood"
        welcomeLabel.textColor = UIColor.whiteColor()
        welcomeLabel.textAlignment = .Center
        welcomeLabel.adjustsFontSizeToFitWidth = true
        welcomeLabel.font = UIFont(name: "Arial-BoldMT", size: 16)
        self.addSubview(welcomeLabel)
        
        name.backgroundColor = UIColor.whiteColor()
        name.textColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)
        name.autocapitalizationType = .None
        name.layer.cornerRadius = 6.0
        name.layer.masksToBounds = true
        name.placeholder = "Enter your name"
        name.attributedPlaceholder = NSAttributedString(string:"Enter your name",
            attributes:[NSForegroundColorAttributeName: UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)])
        self.addSubview(name)
        
        username.backgroundColor = UIColor.whiteColor()
        username.textColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)
        username.autocapitalizationType = .None
        username.layer.cornerRadius = 6.0
        username.layer.masksToBounds = true
        username.attributedPlaceholder = NSAttributedString(string:"Pick an username",
            attributes:[NSForegroundColorAttributeName: UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)])
        self.addSubview(username)
        
        password.backgroundColor = UIColor.whiteColor()
        password.textColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)
        password.autocapitalizationType = .None
        password.secureTextEntry = true
        password.layer.cornerRadius = 6.0
        password.layer.masksToBounds = true
        password.attributedPlaceholder = NSAttributedString(string:"Set your password",
            attributes:[NSForegroundColorAttributeName: UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)])
        self.addSubview(password)
        
        email.backgroundColor = UIColor.whiteColor()
        email.textColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)
        email.autocapitalizationType = .None
        email.layer.cornerRadius = 6.0
        email.layer.masksToBounds = true
        email.placeholder = "Enter an e-mail Id"
        email.attributedPlaceholder = NSAttributedString(string:"Enter an e-mail Id",
            attributes:[NSForegroundColorAttributeName: UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)])
        self.addSubview(email)
        
        loginLink.text = "Already a member? Log In!"
        loginLink.font = UIFont(name: "Arial-BoldMT", size: 16)
        loginLink.textColor = UIColor.whiteColor()
        loginLink.textAlignment = .Center
        loginLink.adjustsFontSizeToFitWidth = true
        loginLink.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: "didTapLoginLink:")
        tapGesture.numberOfTapsRequired = 1
        loginLink.addGestureRecognizer(tapGesture)
        self.addSubview(loginLink)

        
        signUpButton.setTitleColor(UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1), forState: .Normal)
        signUpButton.setTitle( "Sign Up", forState: .Normal)
        signUpButton.backgroundColor = UIColor.whiteColor()
        signUpButton.layer.cornerRadius = 10
        signUpButton.layer.masksToBounds = true
        signUpButton.addTarget(self, action: "didPressSignUpButton:", forControlEvents: .TouchUpInside)
        self.addSubview(signUpButton)
        
        self.loadingView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        self.addSubview(self.loadingView)
        
    }
    
    func didPressSignUpButton(sender: UIButton) {
        
        self.delegate?.shSignUpView(self, didPressSignUpButton: sender)
    }
    
    func didTapLoginLink(sender: UILabel) {
        
        print("did tap on signup link")
        self.delegate?.shSignUpView(self, didPressLoginLink: sender)
    }
    
    func didSwipeRight(sender: UISwipeGestureRecognizer) {
        
        self.delegate?.shSignUpView(self, didSwipeRight: sender)
    }
}


class SignUpViewController: UIViewController, UITextFieldDelegate, SHSignUpViewDelegate {
    
    var signUpView = SHSignUpView()
    var currentTextfield = UITextField()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        signUpView.frame = self.view.bounds
        signUpView.delegate = self
        signUpView.name.delegate = self
        signUpView.username.delegate = self
        signUpView.password.delegate = self
        signUpView.email.delegate = self
        self.view.addSubview(signUpView)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        currentTextfield.resignFirstResponder()
    }
    
    func signUp(username: String, name: String, password: String, email: String) {
        
        if(username == "" || name == "" || password == "" || email == "") {
            
            let alertController = UIAlertController(title: "Fail!", message: "Information missing!", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default){ (_) -> Void in
                
                
                
            }
            
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: {
                
                
            })
            
            
            
        } else {
            
            
            var dict = [String : AnyObject]()
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            dict["username"] = username
            dict["name"] = name
            dict["password"] = password
            dict["email"] = email
            
            
            Alamofire.request(.POST, "http://ec2-52-34-85-44.us-west-2.compute.amazonaws.com:8080/signin",parameters: dict, encoding: .JSON).responseJSON {  response in
                
                self.signUpView.loadingView.stopAnimating()
                if response.result.isSuccess {
                    
                    let jsonDic = response.result.value as! NSDictionary
                    //print(jsonDic)
                    
                    if(jsonDic["result"]!.isKindOfClass(NSString)) {
                        
                        
                        let alertController = UIAlertController(title: "Fail!", message: "Something Went Wrong!", preferredStyle: .Alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .Default){ (_) -> Void in
                            
                            self.navigationController?.popViewControllerAnimated(true)
                            
                        }
                        
                        alertController.addAction(defaultAction)
                        self.presentViewController(alertController, animated: true, completion: {
                            
                            
                        })
                        
                        
                        
                    } else {
                        
                        print(jsonDic["result"]!["ops"])
                        let userArray = jsonDic["result"]!["ops"] as! NSArray
                        let userDefaults = NSUserDefaults.standardUserDefaults()
                        userDefaults.setValue(username, forKey: "username")
                        userDefaults.setValue(password, forKey: "password")
                        appDelegate.userData = userArray[0] as? [String : AnyObject]
                        self.navigationController?.pushViewController(HomeViewController(), animated: true)
                        
                        
                    }
                    
                    
                } else if(response.result.isFailure) {
                    
                    let alertController = UIAlertController(title: "Network Error!", message: "Not Connected to Internet", preferredStyle: .Alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .Default){ (_) -> Void in
                        
                        self.navigationController?.popViewControllerAnimated(true)
                        
                    }
                    
                    alertController.addAction(defaultAction)
                    self.presentViewController(alertController, animated: true, completion: {
                        
                        
                    })
                    
                    
                }
            }
            
            
        }
        
       
    }
    
    
    func shSignUpView(sender: SHSignUpView, didPressSignUpButton button: UIButton) {
        
        self.signUpView.loadingView.startAnimating()
        self.signUp(self.signUpView.username.text!,name: self.signUpView.name.text!,password: self.signUpView.password.text!,email: self.signUpView.email.text! )
        
    }
    
    func shSignUpView(sender: SHSignUpView, didPressLoginLink label: UILabel) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func shSignUpView(sender: SHSignUpView, didSwipeRight: UISwipeGestureRecognizer) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        currentTextfield = textField
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


