//
//  ViewController.swift
//  VideoTest
//
//  Created by Jeet Shah on 2/5/16.
//  Copyright © 2016 Jeet Shah. All rights reserved.
//

import UIKit
import Alamofire

protocol SHLoginViewDelegate {
    
    func shLoginView(sender: SHLoginView, didPressLoginButton button: UIButton)
    func shLoginView(sender: SHLoginView, didPressSignUpLink label: UILabel)
    func shLoginView(sender: SHLoginView, didSwipeLeft recognizer: UISwipeGestureRecognizer)
    
}

class SHLoginView : UIView {
    
    var welcomeLabel = UILabel()
    var signUpLink = UILabel()
    var username = UITextField()
    var password = UITextField()
    var loginButton = UIButton()
    let loadingView = UIActivityIndicatorView()
    var delegate: SHLoginViewDelegate?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError()
        
    }
    
    override func layoutSubviews() {
        
        loadingView.frame = self.bounds
        
        welcomeLabel.frame = CGRectMake((self.frame.width - self.frame.width * 0.8) / 2, self.frame.height * 0.1, self.frame.width * 0.8 , self.frame.height * 0.05)
        
        username.frame = CGRectMake((self.frame.width - self.frame.width * 0.8) / 2, welcomeLabel.frame.maxY + 20, self.frame.width * 0.8 , self.frame.height * 0.05)
        
        password.frame = CGRectMake((self.frame.width - self.frame.width * 0.8) / 2, username.frame.maxY + 20, self.frame.width * 0.8 , self.frame.height * 0.05)
        
        signUpLink.frame = CGRectMake((self.frame.width - self.frame.width * 0.8) / 2, password.frame.maxY + 20, self.frame.width * 0.8 , self.frame.height * 0.05)
        
        loginButton.frame = CGRectMake((self.frame.width - self.frame.width * 0.4) / 2, self.frame.maxY -   2 * self.frame.height * 0.1, self.frame.width * 0.4, self.frame.height * 0.05)
        
    }
    
    func setupViews() {
        
        
        self.backgroundColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: "didSwipeLeft:")
        swipeGesture.direction = .Left
        self.addGestureRecognizer(swipeGesture)
        
        welcomeLabel.text = "Welcome To ShareHood"
        welcomeLabel.font = UIFont(name: "Arial-BoldMT", size: 16)
        welcomeLabel.textColor = UIColor.whiteColor()
        welcomeLabel.textAlignment = .Center
        welcomeLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(welcomeLabel)
        
        username.backgroundColor = UIColor.whiteColor()
        username.textColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)
        username.autocapitalizationType = .None
        username.layer.cornerRadius = 6.0
        username.layer.masksToBounds = true
        //username.placeholder = "Enter your username"
        username.attributedPlaceholder = NSAttributedString(string:"Enter your username",
            attributes:[NSForegroundColorAttributeName: UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)])
        self.addSubview(username)
        
        password.backgroundColor = UIColor.whiteColor()
        password.secureTextEntry = true
        password.textColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)
        password.autocapitalizationType = .None
        password.layer.cornerRadius = 6.0
        password.layer.masksToBounds = true
        password.attributedPlaceholder = NSAttributedString(string:"Enter your password",
            attributes:[NSForegroundColorAttributeName: UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)])
        //password.placeholder = "Enter your password"
        self.addSubview(password)
        
        signUpLink.text = "Not a member? Sign Up!"
        signUpLink.font = UIFont(name: "Arial-BoldMT", size: 16)
        signUpLink.textColor = UIColor.whiteColor()
        signUpLink.textAlignment = .Center
        signUpLink.adjustsFontSizeToFitWidth = true
        signUpLink.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: "didTapSignUpLink:")
        tapGesture.numberOfTapsRequired = 1
        signUpLink.addGestureRecognizer(tapGesture)
        self.addSubview(signUpLink)
        
        loginButton.setTitleColor(UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1), forState: .Normal)
        loginButton.setTitle( "Log In", forState: .Normal)
        loginButton.backgroundColor = UIColor.whiteColor()
        loginButton.layer.cornerRadius = 10
        loginButton.layer.masksToBounds = true
        loginButton.addTarget(self, action: "didPressLoginButton:", forControlEvents: .TouchUpInside)
        self.addSubview(loginButton)
        
        self.loadingView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        self.addSubview(self.loadingView)
    
    }
    
    func scaleImage(image: UIImage, scale: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContext(scale)
        image.drawInRect(CGRect(x: 0, y: 0, width: scale.width, height: scale.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    func didPressLoginButton(sender: UIButton) {
        
        self.delegate?.shLoginView(self, didPressLoginButton: sender)
    }
    
    func didTapSignUpLink(sender: UILabel) {
        
        print("did tap on signup link")
        self.delegate?.shLoginView(self, didPressSignUpLink: sender)
    }
    
    func didSwipeLeft(sender: UISwipeGestureRecognizer) {
        
        self.delegate?.shLoginView(self, didSwipeLeft: sender)
    }

}


class ViewController: UIViewController, UITextFieldDelegate, SHLoginViewDelegate {

    var loginView = SHLoginView()
    var currentTextfield = UITextField()
    let homeViewController = HomeViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let username = userDefaults.valueForKey("username") as? String
        let password = userDefaults.valueForKey("password") as? String
        
        if(username != nil && password != nil) {
            
            self.logIn(username!,password: password!)
        }
       
        
        self.navigationController?.navigationBarHidden = true
        loginView.frame = self.view.bounds
        loginView.delegate = self
        loginView.username.delegate = self
        loginView.password.delegate = self
        self.view.addSubview(loginView)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        print(currentTextfield)
        currentTextfield.resignFirstResponder()
        
    }
    
    func logIn(username: String, password: String) {
        
        var dict = [String : AnyObject]()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        dict["username"] = username
        dict["password"] = password
       
        Alamofire.request(.POST, "http://ec2-52-34-85-44.us-west-2.compute.amazonaws.com:8080/login",parameters: dict, encoding: .JSON).responseJSON {  response in
            
            self.loginView.loadingView.stopAnimating()
            
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
                    
                    
                    if(jsonDic["result"] != nil) {
                        
                        let userDefaults = NSUserDefaults.standardUserDefaults()
                        userDefaults.setValue(username, forKey: "username")
                        userDefaults.setValue(password, forKey: "password")
                        appDelegate.userData = jsonDic["result"] as? [String : AnyObject]
                        self.navigationController?.pushViewController(self.homeViewController, animated: true)
                        
                    }
                   
                }
                
                
            } else if(response.result.isFailure) {
                
                
                print("failure")
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
    
    func shLoginView(sender: SHLoginView, didPressLoginButton button: UIButton) {
        
        self.loginView.loadingView.startAnimating()
        self.logIn(self.loginView.username.text!,password: self.loginView.password.text!)
    }

    func shLoginView(sender: SHLoginView, didPressSignUpLink label: UILabel) {
        
        print("will present sign up controller")
        self.navigationController?.pushViewController(SignUpViewController(), animated: true)
    }
    
    func shLoginView(sender: SHLoginView, didSwipeLeft recognizer: UISwipeGestureRecognizer) {
        
        print("will present sign up controller")
        self.navigationController?.pushViewController(SignUpViewController(), animated: true)
        
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

