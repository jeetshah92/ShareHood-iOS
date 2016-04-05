//
//  GroupDetailsViewController.swift
//  VideoTest
//
//  Created by Jeet Shah on 12/28/15.
//  Copyright © 2015 Jeet Shah. All rights reserved.
//

import UIKit

import Alamofire


class SHGroupDetailView: UIView {
    
    let groupNameLabel = UILabel()
    let groupCreationTimeLabel = UILabel()
    let groupMediaCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: SHGroupDetailView.defaultLayout(CGSize(width: 0, height: 0)))
    
    class func defaultLayout(headerSize: CGSize) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsZero
        layout.headerReferenceSize = headerSize
        layout.scrollDirection = UICollectionViewScrollDirection.Vertical
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        return layout
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        //layoutSubviews()
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError()
        
    }
    
    
    override func layoutSubviews() {
        
        groupNameLabel.frame = CGRectMake(0, 0, self.frame.width, self.frame.height * 0.10)
        groupCreationTimeLabel.frame = CGRectMake(0, groupNameLabel.frame.maxY, self.frame.width, self.frame.height * 0.10)
        groupMediaCollectionView.frame = CGRectMake(0, groupCreationTimeLabel.frame.maxY, self.frame.width, self.frame.height * 0.80)
    }
    
    
    func setupViews() {
        
        self.backgroundColor = UIColor.grayColor()
        
        groupNameLabel.textColor = UIColor.orangeColor()
        groupNameLabel.backgroundColor = UIColor.blackColor()
        groupNameLabel.textAlignment = .Center
        self.addSubview(groupNameLabel)
        
        groupCreationTimeLabel.textColor = UIColor.greenColor()
        groupCreationTimeLabel.backgroundColor = UIColor.blackColor()
        groupCreationTimeLabel.textAlignment = .Center
        
        groupMediaCollectionView.backgroundColor = UIColor.redColor()
        self.addSubview(groupMediaCollectionView)

        self.addSubview(groupCreationTimeLabel)
        
    }
    
    
    
}


class GroupDetailsViewController: UIViewController {

    var groupDetail = [String: AnyObject]()
    var groupDetailView = SHGroupDetailView()
    var groupMedia = [NSData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchGroupMedia()
        groupDetailView.frame = self.view.bounds
        self.view.addSubview(groupDetailView)
        self.refreshData()
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchGroupMedia() {
        
        Alamofire.request(.GET, "http://ec2-52-34-85-44.us-west-2.compute.amazonaws.com:8080/image1.png").response { response in
            
            
            print(response)
            
            
        }
        
        
    }
    
    
    func refreshData() {
        
        let groupName = groupDetail["group"]![0]["name"]
        print("groupname is \(groupName)")
        self.groupDetailView.groupNameLabel.text = groupName as? String
        
        let groupCreationTime = groupDetail["group"]![0]["timeStamp"] as? String
        print("groupname is \(groupCreationTime)")
        let timeComponents = groupCreationTime!.componentsSeparatedByString("T")
        self.groupDetailView.groupCreationTimeLabel.text = timeComponents[0] + "  " + timeComponents[1]
        
        
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
