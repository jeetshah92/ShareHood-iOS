//
//  HomeViewController.swift
//  VideoTest
//
//  Created by Jeet Shah on 12/2/15.
//  Copyright © 2015 Jeet Shah. All rights reserved.
//

import UIKit
import Alamofire
import MessageUI
import AddressBook

class GroupSummaryView: UITableViewCell {
    
    let summaryLabel = UILabel()
    
    required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError()
    }
    
    override func layoutSubviews() {
        
        summaryLabel.frame = self.bounds
    }
    
    func setupViews() {
        
        self.backgroundColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)
        self.selectionStyle = .None
        
        summaryLabel.font = UIFont(name: "Arial-BoldMT", size: 16)
        summaryLabel.textColor = UIColor.whiteColor()
        summaryLabel.textAlignment = .Center
        self.addSubview(summaryLabel)
    }

    
}

class GroupDetailView: UITableViewCell {
    
    let grpLabel = UILabel()
    let memberLabel = UILabel()
    let mediaLabel = UILabel()
    
    required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError()
    }
   
    override func layoutSubviews() {
        
         grpLabel.frame = self.bounds
        
         memberLabel.frame = CGRect(x: 0,
            y: (self.frame.height - self.frame.height * 0.90) / 2,
            width: self.frame.width * 0.2,
            height: self.frame.height * 0.90)
        
        mediaLabel.frame = CGRect(x: (self.frame.maxX - self.frame.width * 0.1 * 1.5),
            y: (self.frame.height - self.frame.height * 0.90) / 2,
            width: self.frame.width * 0.2,
            height: self.frame.height * 0.90)
        
    }
    
    func setupViews() {
        
        self.selectionStyle  = .None
        
        grpLabel.font = UIFont(name: "Arial-BoldMT", size: 16)
        grpLabel.textColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)
        grpLabel.textAlignment = .Center
        self.addSubview(grpLabel)
        
        memberLabel.font = UIFont(name: "Arial-BoldMT", size: 16)
        memberLabel.textColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)
        memberLabel.adjustsFontSizeToFitWidth = true
        memberLabel.textAlignment = .Center
        memberLabel.layer.cornerRadius = self.frame.height * 0.90 / 2
        memberLabel.layer.masksToBounds = true
        self.addSubview(memberLabel)
        
        mediaLabel.font = UIFont(name: "Arial-BoldMT", size: 20)
        mediaLabel.textColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)
        mediaLabel.adjustsFontSizeToFitWidth = true
        mediaLabel.textAlignment = .Center
        mediaLabel.text = ">"
        mediaLabel.layer.cornerRadius = self.frame.height * 0.90 / 2
        mediaLabel.layer.masksToBounds = true
        self.addSubview(mediaLabel)

        
    }
    
    
}

protocol joinGroupViewDelegate {
    
    func joinGroupView(sender: JoinGroupView, didPressjoinButton button: UIButton)

}

class JoinGroupView : UIView {
    
    var message = UILabel()
    var isNew = Bool()
    var groupId = UITextField()
    var joinButton = UIButton()
    var delegate: joinGroupViewDelegate?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError()
        
    }
    
    override func layoutSubviews() {
        
        message.frame = CGRectMake((self.frame.width - self.frame.width * 0.8) / 2, self.frame.height * 0.1, self.frame.width * 0.8 , self.frame.height * 0.1)
        groupId.frame = CGRectMake((self.frame.width - self.frame.width * 0.8) / 2, message.frame.maxY + 30, self.frame.width * 0.8 , self.frame.height * 0.15)
        joinButton.frame = CGRectMake((self.frame.width - self.frame.width * 0.5) / 2, self.groupId.frame.maxY + 30, self.frame.width * 0.5, self.frame.height * 0.2)
        
    }
    
    func setupViews() {
    
        
        self.backgroundColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)

        message.text = "Be a part of a Group!"
        message.font = UIFont(name: "Arial-BoldMT", size: 16)
        message.textColor = UIColor.whiteColor()
        message.textAlignment = .Center
        message.adjustsFontSizeToFitWidth = true
        self.addSubview(message)
        
        self.groupId.backgroundColor = UIColor.whiteColor()
        self.groupId.textColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)
        groupId.attributedPlaceholder = NSAttributedString(string:"Enter group Id",
            attributes:[NSForegroundColorAttributeName: UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)])
        groupId.layer.cornerRadius = 6
        groupId.layer.masksToBounds = true
        self.addSubview(self.groupId)
        
        joinButton.setTitleColor(UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1), forState: .Normal)
        joinButton.setTitle( "Join Group", forState: .Normal)
        joinButton.backgroundColor = UIColor.whiteColor()
        joinButton.layer.cornerRadius = 10
        joinButton.layer.masksToBounds = true
        joinButton.addTarget(self, action: "didPressJoinButton:", forControlEvents: .TouchUpInside)
        self.addSubview(joinButton)
    }

    
    func didPressJoinButton(sender: UIButton) {
        
        self.delegate?.joinGroupView(self, didPressjoinButton: sender)
        
    }
    
}


protocol SHHomeViewDelegate {
    
    func shHomeView(sender: SHHomeView, didPressJoinGroupLabel joinGroupLabel: UITabBarItem)
    func shHomeView(sender: SHHomeView, didPressAddGroupButton addGroupButton: UIButton)
    func shHomeView(sender: SHHomeView, didPressLogoutButton logoutButton: UIGestureRecognizer)
    func shHomeView(sender: SHHomeView, didTapBlockOut recognizer: UIGestureRecognizer)
    func shHomeView(sender: SHHomeView, didPressSMSLabel: UITabBarItem)
    func shHomeView(sender: SHHomeView, didPressWhatsappLabel: UITabBarItem)
    
}

class SHHomeView: UIView, UITabBarDelegate{
    
    var profilePictureImageView = UIImageView()
    var addNewGroupButton = UIButton()
    var name = UILabel()
    var profilePicture = UIImage()
    var tabs = UITabBar()
    var joinedGroupTableView = UITableView(frame: CGRectZero, style: .Grouped)
    var groupSummary = UITableView(frame: CGRectZero, style: .Grouped)
    var joinedGroupsLabel = UITabBarItem()
    var shareOnWhatsAppLabel = UITabBarItem()
    var joinGroupLabel = UITabBarItem()
    var logoutView = UIButton()
    var didTouch = Bool()
    var blockView = UIView()
    let headerView = UIView()
    let label = UILabel()
    let loadingView = UIActivityIndicatorView()
    var delegate: SHHomeViewDelegate?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError()
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    override func layoutSubviews() {
        
        blockView.frame = self.bounds
        loadingView.frame = self.bounds
        
        name.frame = CGRectMake(0, 20, self.frame.width, self.frame.height * 0.10)
        
        logoutView.frame = CGRect(x: self.frame.maxX - self.frame.width * 0.15, y: name.frame.origin.y + ((name.frame.height - self.frame.width * 0.10) / 2), width: self.frame.width * 0.10, height: self.frame.width * 0.10)
        
        tabs.frame = CGRectMake(0, name.frame.maxY, self.frame.width, self.frame.height * 0.10)
        
        joinedGroupTableView.frame = CGRectMake(0, tabs.frame.maxY, self.frame.width, self.frame.height * 0.80)
        
        addNewGroupButton.frame = CGRect(x: self.frame.maxX - 2 * self.frame.width * 0.15, y: self.frame.maxY - 2 * self.frame.width * 0.15, width: self.frame.width * 0.2, height: self.frame.width * 0.2)
        
        groupSummary.frame = CGRect(x: (self.frame.width - self.frame.width * 0.8) / 2, y: (self.frame.height - self.frame.width * 0.8) / 2, width: self.frame.width * 0.8, height: self.frame.width * 0.8)
        
        headerView.frame = CGRect(x: 0, y:0, width: frame.width, height: frame.height * 0.1)
        label.frame = headerView.bounds
    }
    
    
    func setupViews() {
        
        
        
        self.backgroundColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)
        
        name.backgroundColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)
        name.textColor = UIColor.whiteColor()
        name.font = UIFont(name: " Helvetica", size: 25)
        name.textAlignment = .Center
        name.adjustsFontSizeToFitWidth = true
        self.addSubview(name)
        
        
        logoutView.setImage(scaleImage(UIImage(named: "settingsIcon")!, scale: CGSize(width: 30, height: 30)), forState: .Normal)
        logoutView.setTitleColor(UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1), forState: .Normal)
        let tapGesture = UITapGestureRecognizer(target: self, action: "didPressLogoutLink:")
        tapGesture.numberOfTapsRequired = 1
        logoutView.addGestureRecognizer(tapGesture)
        logoutView.layer.cornerRadius = 5
        logoutView.layer.masksToBounds = true
        self.addSubview(logoutView)
        
        tabs.backgroundColor = UIColor.whiteColor()
        shareOnWhatsAppLabel.title = "share on Whatsapp"
        shareOnWhatsAppLabel.image =  scaleImage(UIImage(named: "whatsappIcon")!, scale: CGSize(width: 30, height: 30))
        joinedGroupsLabel.title = "SMS"
        joinedGroupsLabel.image =  scaleImage(UIImage(named: "SMSIcon")!, scale: CGSize(width: 30, height: 30))
        joinGroupLabel.image = scaleImage(UIImage(named: "joinGroup")!, scale: CGSize(width: 30, height: 30))

        joinGroupLabel.title = "Join Group"
        tabs.items = [joinedGroupsLabel, shareOnWhatsAppLabel, joinGroupLabel]
        tabs.delegate = self
        self.addSubview(tabs)
        
        headerView.backgroundColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)
        
        
        label.backgroundColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)
        label.font = UIFont(name: "Arial-BoldMT", size: 16)
        label.adjustsFontSizeToFitWidth = true
        label.text = "Groups"
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        headerView.addSubview(label)

        joinedGroupTableView.scrollEnabled = true
        joinedGroupTableView.bounces = true
        joinedGroupTableView.separatorStyle = .None
        joinedGroupTableView.separatorColor = UIColor.clearColor()
        self.addSubview(joinedGroupTableView)
        
        groupSummary.scrollEnabled = true
        groupSummary.separatorColor = UIColor.clearColor()
        groupSummary.tableHeaderView?.frame = CGRectZero
        groupSummary.hidden = true
        groupSummary.separatorStyle = .None
        groupSummary.layer.cornerRadius = 10
        groupSummary.layer.masksToBounds = true
        groupSummary.backgroundColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)
        self.addSubview(groupSummary)
        
        addNewGroupButton.backgroundColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)
        addNewGroupButton.setTitle("+", forState: .Normal)
        addNewGroupButton.layer.cornerRadius = 5
        addNewGroupButton.layer.masksToBounds = true
        addNewGroupButton.layer.shadowOffset = CGSize(width: 5,height: 5)
        addNewGroupButton.layer.shadowColor = UIColor.grayColor().CGColor
        addNewGroupButton.layer.shadowRadius = 5
        addNewGroupButton.layer.shadowOpacity = 0.8
        addNewGroupButton.addTarget(self, action: "didPressAddGroupButton:", forControlEvents: .TouchUpInside)
        self.addSubview(addNewGroupButton)
        
        self.blockView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        self.addSubview(self.blockView)
        let tapOnblockViewGesture = UITapGestureRecognizer(target: self, action: "didTapOnBlockoutview:")
        tapOnblockViewGesture.numberOfTapsRequired = 1
        blockView.addGestureRecognizer(tapOnblockViewGesture)
        blockView.hidden = true
        
        self.loadingView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        self.addSubview(self.loadingView)
        
    }
    
    func didTapOnBlockoutview(recognizer: UITapGestureRecognizer) {
        
        self.delegate?.shHomeView(self, didTapBlockOut: recognizer)
    }
    
    func didPressLogoutLink(recognizer: UIGestureRecognizer) {
        
        self.delegate?.shHomeView(self, didPressLogoutButton: recognizer)
        
    }

    
    func scaleImage(image: UIImage, scale: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContext(scale)
        image.drawInRect(CGRect(x: 0, y: 0, width: scale.width, height: scale.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        scaledImage.imageWithRenderingMode(.AlwaysOriginal)
        return scaledImage
    }
    
    func didPressAddGroupButton(sender: UIButton) {
        
        self.delegate?.shHomeView(self, didPressAddGroupButton: sender)
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        
        if(item == joinGroupLabel) {
            
            print("pressed joined group label")
            self.delegate?.shHomeView(self, didPressJoinGroupLabel: item)
            
        } else if(item == joinedGroupsLabel) {
            
            print("pressed sms group label")
            self.delegate?.shHomeView(self, didPressSMSLabel: item)
            
        } else if(item == shareOnWhatsAppLabel) {
            
            print("pressed whats app group label")
            self.delegate?.shHomeView(self, didPressWhatsappLabel: item)

            
        }
            

    }
    
    
}


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SHHomeViewDelegate, joinGroupViewDelegate, MFMessageComposeViewControllerDelegate{

    
    var homeView = SHHomeView()
    var joinGroupView = JoinGroupView()
    var userData = [String: AnyObject]()
    var result =  NSArray()
    var joinedGroups =   Dictionary<String,NSDictionary>()
    var groupSummary = [String]()
    var currentTextfield = UITextField()
    var groupDetailViewController = GroupDetailsViewController()
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var refreshTimer = NSTimer()
    var smsController: MFMessageComposeViewController?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAddressBookNames()
        registerNotification()
        
        homeView.frame = self.view.bounds
        homeView.joinedGroupTableView.delegate = self
        homeView.joinedGroupTableView.dataSource = self
        homeView.joinedGroupTableView.tableHeaderView?.hidden = true
        homeView.joinedGroupTableView.registerClass(GroupDetailView .self, forCellReuseIdentifier: "GroupName")
        homeView.groupSummary.registerClass(GroupSummaryView.self, forCellReuseIdentifier: "GroupSummary")
        homeView.groupSummary.delegate = self
        homeView.groupSummary.dataSource = self
        
        homeView.delegate = self
        homeView.addNewGroupButton.layer.cornerRadius = self.view.frame.width * 0.2 / 2
        self.view.addSubview(homeView)
        
        homeView.name.font = UIFont(name: "Arial-BoldMT", size: 16)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        homeView.name.text = appDelegate.userData!["name"] as? String
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if(self.appDelegate.userData!["joinedGroups"] != nil) {
         
             result = self.appDelegate.userData!["joinedGroups"] as! NSArray
        }
        
       refreshTimer = NSTimer(timeInterval: 5, target: self, selector: "refreshGroupDetails", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(refreshTimer, forMode: NSRunLoopCommonModes)
        self.fetchGroupNames() {
            
            
            
        }
        
        refreshTimer.fire()

        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        refreshTimer.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        currentTextfield.resignFirstResponder()
    
    }
    
    func registerNotification() {
        
        print("will register notifications")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshTableView:", name: "refreshTableView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshJoinedGroups:", name: "refreshJoinedGroups", object: nil)
        
    }
    func refreshGroupDetails() {
        
        print("fetching current info")
        
       self.fetchGroupNames { () -> () in
        
          // self.homeView.joinedGroupTableView.reloadData()
    
        }
        
    }
    
    func refreshTableView(notification: NSNotification) {
        

        print(notification.object)
        self.appDelegate.userData = notification.object as? [String : AnyObject]
        self.result = self.appDelegate.userData!["joinedGroups"] as! NSArray
       
        self.fetchGroupNames { () -> () in
            
           self.homeView.joinedGroupTableView.reloadData()
            
        }
    
    }
    
    func getAddressBookNames() {
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        if (authorizationStatus == ABAuthorizationStatus.NotDetermined)
        {
            NSLog("requesting access...")
            var emptyDictionary: CFDictionaryRef?
            var addressBook = (ABAddressBookCreateWithOptions(emptyDictionary, nil) == nil)
            ABAddressBookRequestAccessWithCompletion(addressBook,{success, error in
                if success {
                    self.getContactNames();
                }
                else {
                    NSLog("unable to request access")
                }
            })
        }
        else if (authorizationStatus == ABAuthorizationStatus.Denied || authorizationStatus == ABAuthorizationStatus.Restricted) {
            NSLog("access denied")
        }
        else if (authorizationStatus == ABAuthorizationStatus.Authorized) {
            NSLog("access granted")
            getContactNames()
        }
    }
    
    func getContactNames()
    {
        var errorRef: Unmanaged<CFError>?
        let addressBook: ABAddressBookRef? = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
        
        let contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
        print("number of contacts: \(contactList.count)")
        
        for record:ABRecordRef in contactList {
        
            let contactName = ABRecordCopyCompositeName(record)
            if(contactName != nil) {
            
                print("contactName: \(contactName.takeRetainedValue())")
            }
            
            if let phoneNumbers: ABMultiValueRef = ABRecordCopyValue(record, kABPersonPhoneProperty)?.takeRetainedValue() {
                for index in 0 ..< ABMultiValueGetCount(phoneNumbers) {
                    let number = ABMultiValueCopyValueAtIndex(phoneNumbers, index)?.takeRetainedValue() as? String
                    
                    print(number)
                    let label  = ABMultiValueCopyLabelAtIndex(phoneNumbers, index)?.takeRetainedValue()
                    
                    
                }
            }

            
        }
        
        
    }
    
    func extractABAddressBookRef(abRef: Unmanaged<ABAddressBookRef>!) -> ABAddressBookRef? {
        if let ab = abRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }

    
    func refreshJoinedGroups(notification: NSNotification) {
        
        self.joinedGroups = self.appDelegate.joinedGroups
    }
    
    func fetchGroupNames(completion: () -> ()) {
        
        joinedGroups.removeAll()
        
        
        for i in result {
            
            var dict = [String : AnyObject]()
            
            dict["id"] = i
            
            Alamofire.request(.POST, "http://ec2-52-34-85-44.us-west-2.compute.amazonaws.com:8080/getGroupMedia",parameters: dict, encoding: .JSON).responseJSON {  response in
                
    
                if response.result.isSuccess {
                    
                    if(response.result.value != nil) {
                        
                        let jsonDic = response.result.value as! NSDictionary
                        
                        if(jsonDic["group"]![0]["id"] != nil) {
                            
                             self.joinedGroups[jsonDic["group"]![0]["id"] as! String] = jsonDic
                        }
                       
                        if(self.joinedGroups.count == self.result.count) {
                            
                            print("will reload tableView")
                            self.homeView.joinedGroupTableView.reloadData()
                            self.appDelegate.joinedGroups = self.joinedGroups
                        }
                    }
                    
                    
                }
            }
            
        }
        
    }
    
    func didLongPressCell(recognizer: UILongPressGestureRecognizer) {
        
        
        if(recognizer.state == .Began) {
            
            homeView.groupSummary.alpha = 0.0
            homeView.blockView.alpha = 0.0
            
            self.homeView.groupSummary.hidden = false
            self.homeView.blockView.hidden = false
            
            self.homeView.bringSubviewToFront(self.homeView.groupSummary)
            
            let cell = recognizer.view as! UITableViewCell
            var index = Int(0)
            
            
            if(self.homeView.joinedGroupTableView.indexPathForCell(cell) != nil) {
                
                index = self.homeView.joinedGroupTableView.indexPathForCell(cell)!.row
            }
            
            
            if(self.result[index] as? String != nil) {
                
                let group = self.joinedGroups[self.result[index] as! String]
                
                if(group!.objectForKey("group")![0]["name"] as? String != nil) {
                    
                    self.groupSummary.append("name : \(group!.objectForKey("group")![0]["name"] as! String)")
                }
                
                if(group!.objectForKey("group")![0]["id"] as? String != nil) {
                    
                     self.groupSummary.append("id : \(group!.objectForKey("group")![0]["id"] as! String)")
                }
                
                if(group!.objectForKey("group")![0]["media"] as? NSArray != nil) {
                    
                    let media = group!.objectForKey("group")![0]["media"] as! NSArray
                    self.groupSummary.append("media : \(media.count)")
                    
                }
                
                if(group!.objectForKey("group")![0]["members"] as? NSArray != nil) {
                    
                    let members = group!.objectForKey("group")![0]["members"] as! NSArray
                    self.groupSummary.append("members : \(members.count + 1)")
                }
               
                
                UIPasteboard.generalPasteboard().string = group!.objectForKey("group")![0]["id"] as? String
                
                print(self.groupSummary.count)
                self.homeView.groupSummary.reloadData()
                UIView.animateWithDuration(1.33, animations: { () -> Void in
                    
                    self.homeView.groupSummary.alpha = 1.0
                    self.homeView.blockView.alpha = 1.0
                    
                    
                    
                    }, completion: { (Bool) -> Void in
                        
                        
                        
                })
                
                
            }
                
        } else if(recognizer.state == .Ended) {
            print("ended long press")
            
            UIView.animateWithDuration(1.33, animations: { () -> Void in
                
                self.homeView.groupSummary.alpha = 0.0
                self.homeView.blockView.alpha = 0.0
                
                }, completion: { (Bool) -> Void in
                    
                    self.groupSummary.removeAll()
                    self.homeView.groupSummary.reloadData()
                    self.homeView.groupSummary.hidden = true
                    self.homeView.blockView.hidden = true
                    self.homeView.blockView.alpha = 1
                    self.homeView.bringSubviewToFront(self.homeView.blockView)
            })
            
            
        }
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        print("reload tableview \(joinedGroups.count)")
        if(tableView == homeView.joinedGroupTableView) {
            
            var tableViewFrame = tableView.frame
            tableViewFrame.size.height = CGFloat(joinedGroups.count) * self.view.frame.width * 0.15
            tableView.frame = tableViewFrame
            
            return joinedGroups.count
            
        } else if(tableView == homeView.groupSummary) {
            
            var tableViewFrame = tableView.frame
            tableViewFrame.size.height = CGFloat(joinedGroups.count) * self.view.frame.width * 0.1
            tableView.frame = tableViewFrame
            return groupSummary.count
        }
        
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(tableView == homeView.joinedGroupTableView) {
            
            let groupCell = tableView.dequeueReusableCellWithIdentifier("GroupName") as? GroupDetailView
            
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: "didLongPressCell:")
            longPressGesture.minimumPressDuration = 0.33
            groupCell!.addGestureRecognizer(longPressGesture)
            
            if(result[indexPath.row] as? String != nil) {
                
                let group = joinedGroups[result[indexPath.row] as! String]
                
                if(group != nil) {
                    
                    if(group!.objectForKey("group")![0]["media"] as? NSArray != nil) {
                        
                        let media = group!.objectForKey("group")![0]["media"] as! NSArray
                        
                        
                        groupCell!.memberLabel.text = "\(media.count)"
                        
                        
                        groupCell!.mediaLabel.text = ">"
                        
                        groupCell!.grpLabel.text = group!.objectForKey("group")![0]["name"] as? String
                        groupCell!.grpLabel.textAlignment = .Center
                        
                    }
                }
                
            }
            
            
            return groupCell!
            
        } else {
            
            let groupSummaryCell = tableView.dequeueReusableCellWithIdentifier("GroupSummary") as! GroupSummaryView
            
            
            let group = groupSummary[indexPath.row]
            groupSummaryCell.summaryLabel.text = group
            groupSummaryCell.summaryLabel.frame = groupSummaryCell.bounds
            
            return groupSummaryCell

        }
        
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if(tableView == self.homeView.joinedGroupTableView) {
            
            
            return self.homeView.headerView
        }
       
        return nil
    }
    

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.homeView.loadingView.startAnimating()
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.backgroundColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 0.4)
        UIView.transitionWithView(cell!, duration: 1.33, options: .BeginFromCurrentState, animations: { () -> Void in
            
            }) { (Bool) -> Void in
                
                cell!.backgroundColor = UIColor.whiteColor()
                
                if(self.result[indexPath.row] as? String != nil) {
                    
                    self.groupDetailViewController.index = self.result[indexPath.row] as! String
                    self.navigationController?.pushViewController(self.groupDetailViewController, animated: true)
                    self.homeView.loadingView.stopAnimating()
                }
               
        }

    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {

        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.backgroundColor = UIColor.whiteColor()
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if(tableView == self.homeView.joinedGroupTableView) {
            
            return self.view.frame.height * 0.1
            
        } else {
            
            return 0
        }
    }
    
    func shHomeView(sender: SHHomeView, didPressJoinGroupLabel joinGroupLabel: UITabBarItem) {
        
        homeView.blockView.hidden = false
        joinGroupView.isNew = false
        joinGroupView.frame = CGRect(x: (self.view.frame.width - self.view.frame.width * 0.8) / 2, y: 0 - self.view.frame.width * 0.8 , width: self.view.frame.width * 0.8, height: self.view.frame.width * 0.8)
        joinGroupView.groupId.attributedPlaceholder = NSAttributedString(string:"Enter group Id",attributes:[NSForegroundColorAttributeName: UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)])
        joinGroupView.message.text = "Be a part of a group"
        joinGroupView.groupId.text = ""
        joinGroupView.joinButton.setTitle("Join Group", forState: .Normal)
        joinGroupView.delegate = self
        joinGroupView.layer.cornerRadius = 10
        joinGroupView.groupId.delegate = self
        joinGroupView.layer.masksToBounds = true
        self.view.addSubview(joinGroupView)

        
        UIView.animateWithDuration(0.33, animations: {
            
            self.joinGroupView.frame = CGRect(x: (self.view.frame.width - self.view.frame.width * 0.8) / 2, y: (self.view.frame.height - self.view.frame.width * 0.8) / 2, width: self.view.frame.width * 0.8, height: self.view.frame.width * 0.8)
            
            
        })
        
        
    }
    

    
    func shHomeView(sender: SHHomeView, didPressAddGroupButton addGroupButton: UIButton) {
        
        homeView.blockView.hidden = false
        print("presenting the add group controller")
        joinGroupView.isNew = true
        joinGroupView.frame = CGRect(x: (self.view.frame.width - self.view.frame.width * 0.8) / 2, y: sender.frame.maxY + self.view.frame.width * 0.8 , width: self.view.frame.width * 0.8, height: self.view.frame.width * 0.8)
        joinGroupView.groupId.attributedPlaceholder = NSAttributedString(string:"Enter group Name",attributes:[NSForegroundColorAttributeName: UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)])
        joinGroupView.message.text = "Create a new Group"
        joinGroupView.groupId.text = ""
        joinGroupView.joinButton.setTitle("Create Group", forState: .Normal)
        joinGroupView.delegate = self
        joinGroupView.layer.cornerRadius = 10
        joinGroupView.groupId.delegate = self
        joinGroupView.layer.masksToBounds = true
        self.view.addSubview(joinGroupView)
        
        
        UIView.animateWithDuration(0.33, animations: {
            
            self.joinGroupView.frame = CGRect(x: (self.view.frame.width - self.view.frame.width * 0.8) / 2, y: (self.view.frame.height - self.view.frame.width * 0.8) / 2, width: self.view.frame.width * 0.8, height: self.view.frame.width * 0.8)
            
            
        })
    }
    
    func shHomeView(sender: SHHomeView, didPressLogoutButton logoutButton: UIGestureRecognizer) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(nil, forKey: "username")
        userDefaults.setValue(nil, forKey: "password")
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    

    func removeJoinGroupview() {
        
        print("touches begin")
        joinGroupView.delegate = nil
        
        UIView.animateWithDuration(0.33, animations: {
            
            if(!self.joinGroupView.isNew) {
                
                self.joinGroupView.frame = CGRect(x: (self.view.frame.width - self.view.frame.width * 0.8) / 2, y: self.joinGroupView.frame.maxY + self.view.frame.width * 0.8 , width: self.view.frame.width * 0.8, height: self.view.frame.width * 0.8)
                
                
            } else {
                
                self.joinGroupView.frame = CGRect(x: (self.view.frame.width - self.view.frame.width * 0.8) / 2, y: 0 - self.view.frame.width * 0.8 , width: self.view.frame.width * 0.8, height: self.view.frame.width * 0.8)
                
            }
            
            }) { (bool) -> Void in
                
                self.joinGroupView.removeFromSuperview()
                self.homeView.blockView.hidden = true
                
        }

    }
    
    func shHomeView(sender: SHHomeView, didTapBlockOut recognizer: UIGestureRecognizer) {
        
        self.removeJoinGroupview()
        
    }
    
    func shHomeView(sender: SHHomeView, didPressSMSLabel: UITabBarItem) {
        
        smsController = MFMessageComposeViewController()
        smsController!.messageComposeDelegate = self
        
        self.presentViewController(smsController!, animated: true) { () -> Void in
            
            
        }
    }
    
    func shHomeView(sender: SHHomeView, didPressWhatsappLabel: UITabBarItem) {
        
        print("pressed whats app group label")
        
        let id = UIPasteboard.generalPasteboard().string
        print(id)
        let whatsAppURL = NSURL(string: "whatsapp://send?text=Enter%20Group%20Id")
        UIApplication.sharedApplication().openURL(whatsAppURL!)
        
    }
    

    func joinGroupView(sender: JoinGroupView, didPressjoinButton button: UIButton) {
        
        
        
        if(!sender.isNew) {
            
            print("will join group now..")
            
            var dict = [String : AnyObject]()
            if(appDelegate.userData != nil) {
                
                dict["username"] = appDelegate.userData!["username"]
                let id = sender.groupId.text
                dict["groupId"] = id
                
                
                Alamofire.request(.POST, "http://ec2-52-34-85-44.us-west-2.compute.amazonaws.com:8080/joinGroup",parameters: dict, encoding: .JSON).responseJSON {  response in
                    
                    if response.result.isSuccess {
                        
                        if(response.result.value as? NSDictionary != nil) {
                            
                            let jsonDic = response.result.value as! NSDictionary
                            
                            if(jsonDic["result"] != nil) {
                                
                                if(jsonDic["result"]!.isKindOfClass(NSString)) {
                                    
                                    
                                    let alertController = UIAlertController(title: "Fail!", message: "You have already joined a group or that Group doesn't exist", preferredStyle: .Alert)
                                    
                                    let defaultAction = UIAlertAction(title: "OK", style: .Default){ (_) -> Void in
                                        
                                        self.removeJoinGroupview()
                                    }
                                    
                                    alertController.addAction(defaultAction)
                                    self.presentViewController(alertController, animated: true, completion: {
                                        
                                        
                                    })
                                    
                                    
                                    
                                } else {
                                    
                                    NSNotificationCenter.defaultCenter().postNotificationName("refreshTableView", object: jsonDic["result"])
                                        self.removeJoinGroupview()
                                }
                                
                                
                                
                            }

                                
                                
                        }
                            
                            
                        
                    }
                }

            }
            
            
            
        } else {
            
            print("will create group now..")
            
            if(sender.groupId.text == "") {
                
                let alertController = UIAlertController(title: "Fail!", message: "Enter a group name", preferredStyle: .Alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .Default){ (_) -> Void in
                    
                    
                }
                
                alertController.addAction(defaultAction)
                self.presentViewController(alertController, animated: true, completion: {
                    
                    
                })

                
                
            } else {
                
                var dict = [String : AnyObject]()
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                
                if(appDelegate.userData != nil) {
                    
                    dict["username"] = appDelegate.userData!["username"]
                    let name = sender.groupId.text
                    dict["groupName"] = name
                    
                    
                    Alamofire.request(.POST, "http://ec2-52-34-85-44.us-west-2.compute.amazonaws.com:8080/createGroup",parameters: dict, encoding: .JSON).responseJSON {  response in
                        
                        if response.result.isSuccess {
                            
                            if(response.result.value != nil) {
                                
                                let jsonDic = response.result.value as! NSDictionary
                                print(jsonDic)
                                
                                if(jsonDic["result"]!.isKindOfClass(NSString)) {
                                    
                                    
                                    let alertController = UIAlertController(title: "Fail!", message: "Something Went Wrong!", preferredStyle: .Alert)
                                    
                                    let defaultAction = UIAlertAction(title: "OK", style: .Default){ (_) -> Void in
                                        
                                        self.removeJoinGroupview()
                                        
                                        
                                    }
                                    
                                    alertController.addAction(defaultAction)
                                    self.presentViewController(alertController, animated: true, completion: {
                                        
                                        
                                    })
                                    
                                    
                                    
                                } else {
                                    
                                    NSNotificationCenter.defaultCenter().postNotificationName("refreshTableView", object: jsonDic["result"])
                                    self.removeJoinGroupview()
                                    
                                }

                                
                            }
                            
                            
                            
                        }
                    }

                    
                }
                
            }
            
            
        }
        
    
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        
        controller.dismissViewControllerAnimated(true) { () -> Void in
            
            self.smsController = nil
        }
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
