//
//  NewGroupViewController.swift
//  VideoTest
//
//  Created by Jeet Shah on 1/30/16.
//  Copyright © 2016 Jeet Shah. All rights reserved.
//

import UIKit
import Alamofire

struct newGroupViewConstants {
    
    
    
}

protocol newGroupViewDelegate {
    
    func newGroupView(sender: NewGroupView, didPressjoinButton button: UIButton)
}

class NewGroupView : UIView {
    
    var groupId = UITextField()
    var joinButton = UIButton()
    var delegate: newGroupViewDelegate?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        //layoutSubviews()
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError()
        
    }
    
    override func layoutSubviews() {
        
        groupId.frame = CGRectMake((self.frame.width - self.frame.width * 0.8) / 2, self.frame.height * 0.1, self.frame.width * 0.8 , self.frame.height * 0.1)
        joinButton.frame = CGRectMake((self.frame.width - self.frame.width * 0.4) / 2, self.groupId.frame.maxY + 20, self.frame.width * 0.4, self.frame.height * 0.1)
        
    }
    
    func setupViews() {
        
        self.backgroundColor = UIColor.blackColor()
        
        self.groupId.backgroundColor = UIColor.grayColor()
        self.addSubview(self.groupId)
        
        self.joinButton.addTarget(self, action: "didPressJoinButton:", forControlEvents: .TouchUpInside)
        self.joinButton.setTitle("Join Group", forState: .Normal)
        self.joinButton.backgroundColor = UIColor.grayColor()
        self.addSubview(self.joinButton)
    }
    
    func didPressJoinButton(sender: UIButton) {
        
        self.delegate?.newGroupView(self, didPressjoinButton: sender)
        
    }
    
}


class NewGroupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
