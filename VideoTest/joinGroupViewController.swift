//
//  joinGroupViewController.swift
//  VideoTest
//
//  Created by Jeet Shah on 1/30/16.
//  Copyright © 2016 Jeet Shah. All rights reserved.
//

import UIKit
import Alamofire

struct joinGroupViewConstants {
    

    
}




class joinGroupViewController: UIViewController, joinGroupViewDelegate{

    
    var joinGroupView = JoinGroupView()
    var isNew = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(isNew)
        if(isNew) {
            
            joinGroupView.joinButton.setTitle("Create Group", forState: .Normal)
        }
        joinGroupView.frame = self.view.bounds
        joinGroupView.delegate = self
        self.view.addSubview(joinGroupView)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func joinGroupView(sender: JoinGroupView, didPressjoinButton button: UIButton) {
        
//        if(!isNew) {
//            
//            print("will join group now..")
//            var dict = [String : AnyObject]()
//            
//            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//            dict["username"] = appDelegate.userData!["username"]
//            let id = sender.groupId.text
//            dict["groupId"] = id
//            
//            
//            Alamofire.request(.POST, "http://ec2-52-34-85-44.us-west-2.compute.amazonaws.com:8080/joinGroup",parameters: dict, encoding: .JSON).responseJSON {  response in
//                
//                if response.result.isSuccess {
//                    
//                    let jsonDic = response.result.value as! NSDictionary
//                    
//                    print(jsonDic)
//                    if(jsonDic["result"]!.isKindOfClass(NSString)) {
//                        
//                        
//                        let alertController = UIAlertController(title: "Fail!", message: "You have already joined a group", preferredStyle: .Alert)
//                        
//                        let defaultAction = UIAlertAction(title: "OK", style: .Default){ (_) -> Void in
//                            
//                            
//                            self.navigationController?.popViewControllerAnimated(true)
//                            
//                        }
//                        
//                        alertController.addAction(defaultAction)
//                        self.presentViewController(alertController, animated: true, completion: {
//                            
//                            
//                        })
//                        
//                        
//                        
//                    } else {
//                        
//                        print(jsonDic["result"]!)
//                        NSNotificationCenter.defaultCenter().postNotificationName("refreshTableView", object: jsonDic["result"])
//                        self.navigationController?.popViewControllerAnimated(true)
//                        
//                    }
//                    
//                    
//                }
//            }
//
//            
//        } else {
//            
            print("will join group now..")
            var dict = [String : AnyObject]()
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            dict["username"] = appDelegate.userData!["username"]
            let name = sender.groupId.text
            dict["groupName"] = name
            
            
            Alamofire.request(.POST, "http://ec2-52-34-85-44.us-west-2.compute.amazonaws.com:8080/createGroup",parameters: dict, encoding: .JSON).responseJSON {  response in
                
                if response.result.isSuccess {
                    
                    let jsonDic = response.result.value as! NSDictionary
                    print(jsonDic)
                    
                    if(jsonDic["result"]!.isKindOfClass(NSString)) {
                        
                        
                        let alertController = UIAlertController(title: "Fail!", message: "Something Went Wrong!", preferredStyle: .Alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .Default){ (_) -> Void in
                            
                            self.navigationController?.popViewControllerAnimated(true)
                            
                        }
                        
                        alertController.addAction(defaultAction)
                        self.presentViewController(alertController, animated: true, completion: {
                            
                            
                        })
                        
                        
                        
                    } else {
                        
                        print(jsonDic["result"]!)
                        NSNotificationCenter.defaultCenter().postNotificationName("refreshTableView", object: jsonDic["result"])
                        self.navigationController?.popViewControllerAnimated(true)
                        
                    }
                    
                    
                }
            }

//
//            
//        }
//        
//        
        
    }
    
    func joinGroupView(sender: JoinGroupView, didSwipeRight withRecognizer: UISwipeGestureRecognizer) {
        
        //self.navigationController?.popViewControllerAnimated(true)
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
