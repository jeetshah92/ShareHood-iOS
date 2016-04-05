//
//  GroupDetailsViewController.swift
//  VideoTest
//
//  Created by Jeet Shah on 12/28/15.
//  Copyright © 2015 Jeet Shah. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import MediaPlayer
import AssetsLibrary

func scaleImage( image: UIImage, scale: CGSize) -> UIImage {
    
    UIGraphicsBeginImageContext(scale)
    image.drawInRect(CGRect(x: 0, y: 0, width: scale.width, height: scale.height))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return scaledImage
}


class CircularLoaderView: UIView {
    
    let circlePathLayer = CAShapeLayer()
    let circleRadius: CGFloat = 40.0
    var progress: CGFloat {
        get {
            return circlePathLayer.strokeEnd
        }
        set {
            if (newValue > 1) {
                circlePathLayer.strokeEnd = 1
            } else if (newValue < 0) {
                circlePathLayer.strokeEnd = 0
            } else {
                
                CATransaction.setDisableActions(true)
                circlePathLayer.strokeEnd = newValue
                CATransaction.setDisableActions(false)
                
            }
        }
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        configure()
    }
    
    func configure() {
        progress = 0
        circlePathLayer.frame = bounds
        circlePathLayer.lineWidth = 10
        circlePathLayer.fillColor = UIColor.clearColor().CGColor
        circlePathLayer.strokeColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1).CGColor
        layer.addSublayer(circlePathLayer)
        backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
    }
    
    func circleFrame() -> CGRect {
        var circleFrame = CGRect(x: 0, y: 0, width: 2*circleRadius, height: 2*circleRadius)
        circleFrame.origin.x = CGRectGetMidX(circlePathLayer.bounds) - CGRectGetMidX(circleFrame)
        circleFrame.origin.y = CGRectGetMidY(circlePathLayer.bounds) - CGRectGetMidY(circleFrame)
        return circleFrame
    }
    
    func circlePath() -> UIBezierPath {
        return UIBezierPath(ovalInRect: circleFrame())
    }
    
    func reveal() {
        
        // 1
        backgroundColor = UIColor.clearColor()
        progress = 1
        // 2
        circlePathLayer.removeAnimationForKey("strokeEnd")
        // 3
        circlePathLayer.removeFromSuperlayer()
        superview?.layer.mask = circlePathLayer
        let center = CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetMidY(bounds))
        let finalRadius = sqrt((center.x*center.x) + (center.y*center.y))
        let radiusInset = finalRadius - circleRadius
        let outerRect = CGRectInset(circleFrame(), -radiusInset, -radiusInset)
        let toPath = UIBezierPath(ovalInRect: outerRect).CGPath
        
        // 2
        let fromPath = circlePathLayer.path
        let fromLineWidth = circlePathLayer.lineWidth
        
        // 3
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        circlePathLayer.lineWidth = 2*finalRadius
        circlePathLayer.path = toPath
        CATransaction.commit()
        
        // 4
        let lineWidthAnimation = CABasicAnimation(keyPath: "lineWidth")
        lineWidthAnimation.fromValue = fromLineWidth
        lineWidthAnimation.toValue = 2*finalRadius
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = fromPath
        pathAnimation.toValue = toPath
        
        // 5
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = 1
        groupAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        groupAnimation.animations = [pathAnimation, lineWidthAnimation]
        groupAnimation.delegate = self
        circlePathLayer.addAnimation(groupAnimation, forKey: "strokeWidth")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circlePathLayer.frame = bounds
        circlePathLayer.path = circlePath().CGPath
    }
    
}



class groupMediaCell: UICollectionViewCell {
    
    var imageView = UIImageView()
    var typeLabel = UIImageView()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        //layoutSubviews()
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError()
        
    }
    
    
    override func layoutSubviews() {
        
        imageView.frame = self.bounds
        typeLabel.frame = CGRect(x: self.frame.width - 1.5 * self.frame.width * 0.2, y: self.frame.width * 0.1, width: self.frame.width * 0.2, height: self.frame.width * 0.2)
        //self.layer.cornerRadius = self.frame.width / 2
        //self.layer.masksToBounds = true
        
    }
    
    func setupViews() {
        
        imageView.backgroundColor = UIColor.whiteColor()
        self.addSubview(imageView)
        
        typeLabel.image = UIImage(named: "videoIcon")
        self.addSubview(typeLabel)
    }
    
}

protocol MediaItemViewDelegate {
    
    
    func mediaItemView(sender: MediaItemView, didSwipeDown withRecognizer: UISwipeGestureRecognizer)
}

class MediaItemView: UIView {
    
   // let groupNameLabel = UILabel()
    let preview = UIView()
    let videoPreviewLayer = AVPlayerLayer()
    var videoPlayer = AVPlayer()
    let imagePreview = UIImageView()
    var delegate: MediaItemViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        
        fatalError()
    }
    
    override func layoutSubviews() {
        
       // groupNameLabel.frame = CGRectMake(0, 0, self.frame.width, self.frame.height * 0.10)
        preview.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        imagePreview.frame = preview.bounds
        videoPreviewLayer.frame = preview.bounds
        
    }
    
    func setupViews() {
        
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: "didSwipeDown:")
        swipeGesture.direction = .Up
        self.addGestureRecognizer(swipeGesture)
    
        self.addSubview(preview)
        
        videoPreviewLayer.player = videoPlayer
        videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        
    }
    
    
    func didSwipeDown(recognizer: UISwipeGestureRecognizer) {
        
        self.delegate?.mediaItemView(self, didSwipeDown: recognizer)
    }
    
    
}

    
protocol SHGroupDetailViewDelegate {
    
    func groupDetailView(view: SHGroupDetailView, didSwipeRight withRecognizer: UISwipeGestureRecognizer)
    func groupDetailView(view: SHGroupDetailView, didClickMediaButton button: UIButton)
    func groupDetailView(view: SHGroupDetailView, didSwipeDown withRecognizer: UISwipeGestureRecognizer)
    func groupDetailView(view: SHGroupDetailView, didPressRefresh withButton: UIButton)
    func groupDetailView(view: SHGroupDetailView, didPressSaveButton withButton: UITabBarItem)
    
}

class SHGroupDetailView: UIView, UITabBarDelegate {
    
    let groupNameLabel = UILabel()
    let refreshButton = UIButton()
    let progressIndicatorView = CircularLoaderView(frame: CGRectZero)
    let loadingView = UIActivityIndicatorView()
    let groupCreationTimeLabel = UILabel()
    let groupMediaCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: SHGroupDetailView.defaultLayout(CGSize(width: 0, height: 0)))
    let cameraButton = UIButton()
    var tabs = UITabBar()
    var membersLabel = UITabBarItem()
    var saveGroupLabel = UITabBarItem()
    var mediaLabel = UITabBarItem()
    
    var delegate: SHGroupDetailViewDelegate?
    
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
        
        progressIndicatorView.frame = bounds
        groupNameLabel.frame = CGRectMake(0, 0, self.frame.width, self.frame.height * 0.10)
       
        tabs.frame = CGRectMake(0, groupNameLabel.frame.maxY, self.frame.width, self.frame.height * 0.10)
        
        groupMediaCollectionView.frame = CGRectMake(0, tabs.frame.maxY, self.frame.width, self.frame.height * 0.80)
        refreshButton.frame = CGRectMake((self.frame.width - self.frame.width * 0.2) / 2 , groupMediaCollectionView.frame.origin.y + 20, self.frame.width * 0.2, self.frame.width * 0.2)

        cameraButton.frame = CGRectMake(self.frame.maxX - 70, self.frame.maxY - 1.5 * 70 , 70,70)
        loadingView.frame = self.bounds
        
    }
    
    
    func setupViews() {
        
        self.backgroundColor = UIColor.whiteColor()
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: "didSwipeRight:")
        swipeGesture.direction = .Right
        self.addGestureRecognizer(swipeGesture)
        
    
        
        groupNameLabel.textColor = UIColor.whiteColor()
        groupNameLabel.font = UIFont(name: "Arial-BoldMT", size: 16)
        groupNameLabel.backgroundColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)
        groupNameLabel.textAlignment = .Center
        self.addSubview(groupNameLabel)
            
        tabs.backgroundColor = UIColor.whiteColor()
        membersLabel.title = "0"
        membersLabel.image = scaleImage(UIImage(named: "membersIcon")!, scale: CGSize(width: 30,height: 30))
        mediaLabel.title = "0"
        mediaLabel.image = scaleImage(UIImage(named: "mediaIcon")!, scale: CGSize(width: 30,height: 30))
        saveGroupLabel.title = "Save"
        saveGroupLabel.image = scaleImage(UIImage(named: "saveGroupIcon")!, scale: CGSize(width: 30,height: 30))
        tabs.items = [membersLabel,saveGroupLabel,mediaLabel]
        tabs.delegate = self
        self.addSubview(tabs)
        
        groupMediaCollectionView.backgroundColor = UIColor.whiteColor()
        groupMediaCollectionView.showsVerticalScrollIndicator = false
        //groupMediaCollectionView.bounces = false
        self.addSubview(groupMediaCollectionView)
        
        cameraButton.layer.cornerRadius = 35
        cameraButton.layer.masksToBounds = true
        cameraButton.backgroundColor = UIColor.whiteColor()
        cameraButton.setImage(UIImage(named: "cameraButton"), forState: .Normal)
        cameraButton.addTarget(self, action: "didPressCameraButton:", forControlEvents: .TouchUpInside)
        let panGesture = UIPanGestureRecognizer(target: self, action: "didPanCameraButton:")
        self.cameraButton.addGestureRecognizer(panGesture)
        self.addSubview(cameraButton)
        
        self.loadingView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        self.addSubview(self.loadingView)
        
        refreshButton.layer.cornerRadius = (self.frame.width * 0.2) / 2
        refreshButton.layer.masksToBounds = true
        refreshButton.backgroundColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 1)
        //refreshButton.setImage(UIImage(named: "refreshIcon"), forState: .Normal)
        refreshButton.addTarget(self, action: "didPressRefresh:", forControlEvents: .TouchUpInside)
        //self.addSubview(refreshButton)
        
        progressIndicatorView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
    }
    
    func didPressRefresh(sender: UIButton) {
        
        print("did press refresh button")
        self.delegate?.groupDetailView(self, didPressRefresh: sender)
        sender.removeFromSuperview()
        
    }
    
    
    func didSwipeRight(recognizer: UISwipeGestureRecognizer) {
        
        self.delegate?.groupDetailView(self, didSwipeRight: recognizer)
        
    }
    
    func didSwipeDown(recognizer: UISwipeGestureRecognizer) {
        
        print("did swipe down")
        self.delegate?.groupDetailView(self, didSwipeDown: recognizer)
    }
    
    func didPressCameraButton(button: UIButton) {
        
        print("pressed camera button")
        self.delegate?.groupDetailView(self, didClickMediaButton: button)
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        
        if(item == saveGroupLabel) {
            
            //self.didTouch = true
            print("pressed save group label")
            self.delegate?.groupDetailView(self, didPressSaveButton: item)
        }
        
        
    }
    func didPanCameraButton(recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translationInView(self.cameraButton)
    
        if(recognizer.view!.center.y + translation.y >= 35 && recognizer.view!.center.y + translation.y <= self.frame.maxY - 35 && recognizer.view!.center.x + translation.x >= 35 && recognizer.view!.center.x + translation.x <= self.frame.maxX - 35) {
            
            recognizer.view!.center = CGPointMake(recognizer.view!.center.x + translation.x,
                recognizer.view!.center.y + translation.y)
            recognizer.setTranslation(CGPointZero, inView: self.cameraButton)
            
        }
        
        
        if(recognizer.state == .Ended) {
            
            UIView.animateWithDuration(0.33, animations: {
                
                if(self.cameraButton.center.x >= self.bounds.width / 2) {
                    
                    self.cameraButton.frame = CGRectMake(self.frame.maxX - 70, self.cameraButton.frame.origin.y, 70,70)
                    
                } else {
                    
                    self.cameraButton.frame = CGRectMake(0, self.cameraButton.frame.origin.y, 70,70)
                }
                
                
            })
            
            
        }
        
    }
    
}


class GroupDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SHGroupDetailViewDelegate, MediaItemViewDelegate {

    var index =  String()
    var groupDetailView = SHGroupDetailView()
    var pendingRequests = [Request]()
    var groupMedia = [UIImage?]()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var refreshTimer =  NSTimer()
    var previousCount = Int(0)
    var media =  NSArray()
    let mediaItemView = MediaItemView()
    let cameraController = PTImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        groupDetailView.frame = self.view.bounds
        groupDetailView.delegate = self
        groupDetailView.refreshButton.removeFromSuperview()
        groupDetailView.groupMediaCollectionView.delegate = self
        groupDetailView.groupMediaCollectionView.dataSource = self
        groupDetailView.groupMediaCollectionView.registerClass(groupMediaCell.self, forCellWithReuseIdentifier: "groupMedia")
        
        self.view.addSubview(groupDetailView)
        
        mediaItemView.delegate = self
        mediaItemView.frame  = CGRect(x: 0, y: 0 - self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
        
        self.registerNotifications()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        fetchGroupMedia()
        self.refreshData()
        self.groupDetailView.refreshButton.layer.cornerRadius = (self.view.frame.width * 0.2) / 2
        refreshTimer = NSTimer(timeInterval: 5, target: self, selector: "refreshGroupDetails", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(refreshTimer, forMode: NSRunLoopCommonModes)
        refreshTimer.fire()
        media = appDelegate.joinedGroups[index]!["group"]![0]!["media"] as! NSArray
        previousCount = media.count
        self.view.addSubview(self.mediaItemView)
        

        
    }

    override func viewWillDisappear(animated: Bool) {
        
        refreshTimer.invalidate()
        self.previousCount = 0
        self.groupDetailView.refreshButton.removeFromSuperview()
        //self.removeNotifications()
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
       
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "postImage:", name: "capturedImage", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "postVideo:", name: "caturedVideo", object: nil)
        
    }
    
    func removeNotifications() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "caturedImage", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "caturedVideo", object: nil)
        
    }
    
    func cropImage(image: UIImage) -> UIImage {
        
        let cgImg = image.CGImage
        let width = CGFloat(CGImageGetWidth(cgImg))
        let height = CGFloat(CGImageGetHeight(cgImg))
        print("widtn and height  is \(width) -------- \(height)")
        var cropRect = CGRectZero
        
        if(width < height) {
            
            cropRect = CGRect(x: 0, y: 0, width: width, height: width)
            
        } else if(width > height) {
            
            cropRect = CGRect(x: 0, y: 0, width: height, height: height)
            
        }
        
        print("crop rect is \(cropRect)")
        let croppedImage = CGImageCreateWithImageInRect(cgImg, cropRect)
        let thumbnail = UIImage(CGImage: croppedImage!, scale: 1.0, orientation: image.imageOrientation)

        return thumbnail
    }
    
    func postImage(notification: NSNotification) {
        
        print("will post image")
        let imageView = UIImageView()
        imageView.image = notification.object as! UIImage
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            
            
            var dict = [String : AnyObject]()
            
            dict["owner"] = self.appDelegate.userData!["username"]
            dict["id"] = self.appDelegate.joinedGroups[self.index]!["group"]![0]!["id"]
    
            let tbImageData =  UIImagePNGRepresentation(self.scaleImage(imageView.image!, scale: CGSize(width: 150, height: 150)))
            
            let realImageData = UIImagePNGRepresentation(imageView.image!)
            
            dict["thumbnail"]  = tbImageData?.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            dict["image"] = realImageData?.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            dict["orientation"] = imageView.image!.imageOrientation.rawValue
            
            Alamofire.request(.POST, "http://ec2-52-34-85-44.us-west-2.compute.amazonaws.com:8080/uploadImage",parameters: dict, encoding: .JSON).responseJSON {  response in
                
                if response.result.isSuccess {
                    
                    dict["thumbnail"] = nil
                    dict["image"] = nil
                    dict["owner"] = nil
                    dict["id"] = nil
                    let jsonDic = response.result.value as! NSDictionary
                    
                    //print(jsonDic)
                    if(jsonDic["result"]!.isKindOfClass(NSString)) {
                        
                        print("user not found")
                        
                    } else {
                        
                        
                        self.updateGroup({ () -> () in
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                
                                self.refreshData()
                                imageView.image = nil
                                dict.removeAll()
                                
                                
                            })
                            
                        })
                        
                        
                    }
                    
                    
                }
            }
            
        }

        
    }
    
    func videoSnapshot(vidURL: NSURL) -> UIImage? {
        
        //let vidURL = NSURL(fileURLWithPath:filePathLocal as String)
        let asset = AVURLAsset(URL: vidURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        
        do {
            let imageRef = try generator.copyCGImageAtTime(timestamp, actualTime: nil)
            return UIImage(CGImage: imageRef)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
    
    func postVideo(notification: NSNotification) {
        
        print("will post video")
        let videoURL = notification.object as! NSURL
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            
            var dict = [String : AnyObject]()
            let tbImageData =  UIImagePNGRepresentation(self.videoSnapshot(videoURL)!)
            dict["owner"] = self.appDelegate.userData!["username"]
            
            dict["id"] = self.appDelegate.joinedGroups[self.index]!["group"]![0]!["id"]
            dict["thumbnail"] = tbImageData?.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            
            let videoData = NSData(contentsOfURL: videoURL)
            let encodedVideo = videoData?.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            
            dict["video"] = encodedVideo
            
            
            Alamofire.request(.POST, "http://ec2-52-34-85-44.us-west-2.compute.amazonaws.com:8080/uploadVideo",parameters: dict, encoding: .JSON).responseJSON {  response in
                
                if response.result.isSuccess {
                    
                    let jsonDic = response.result.value as! NSDictionary
                    
                    //print(jsonDic)
                    if(jsonDic["result"]!.isKindOfClass(NSString)) {
                        
                        print("user not found")
                        
                    } else {
                        
                        print(jsonDic["result"])
                        self.appDelegate.userData = jsonDic["result"] as? [String : AnyObject]
                        self.refreshData()
                        
                        do {
                            
                             try NSFileManager.defaultManager().removeItemAtPath(videoURL.absoluteString)
                             dict.removeAll() 
                            
                        } catch {
                            
                            
                        }
//
                        
                        
                    }
                    
                    
                }
            }
            
        }

        
    }
    
    
    func refreshGroupDetails() {
        
       // print("fetching current info")
        self.updateGroup { () -> () in
            
            self.refreshData()
            
        }
        
    }
    
    func updateGroup(completion: () -> ()) {
        
        var dict = [String : AnyObject]()
        
        
        dict["id"] = appDelegate.joinedGroups[index]!["group"]![0]!["id"]
        
        Alamofire.request(.POST, "http://ec2-52-34-85-44.us-west-2.compute.amazonaws.com:8080/getGroupMedia",parameters: dict, encoding: .JSON).responseJSON {  response in
            
            //print(response)
            if response.result.isSuccess {
                
                let jsonDic = response.result.value as! NSDictionary
                self.appDelegate.joinedGroups[jsonDic["group"]![0]["id"] as! String] = jsonDic
                
                let newMedia = self.appDelegate.joinedGroups[self.index]!["group"]![0]!["media"] as! NSArray
                let afterCount = newMedia.count
                
                if(afterCount - self.previousCount > 0) {
                    
                    print("will add refresh button")
                    self.groupDetailView.refreshButton.removeFromSuperview()
                    self.groupDetailView.refreshButton.setTitle("\(afterCount - self.previousCount)", forState: .Normal)
                    self.groupDetailView.addSubview(self.groupDetailView.refreshButton)
                }

                completion()
                
            }
        }
        
    
    }

    func fetchGroupMedia() {
        
        
        var orderedCollection = Dictionary<String, AnyObject>()
        
       
        self.groupMedia.removeAll()
        self.groupDetailView.loadingView.startAnimating()
       
        let media =  self.appDelegate.joinedGroups[self.index]!["group"]![0]!["media"] as! NSArray
        print("will download \(media.count) images")
        
        for i in media {
            
            let item = i as! Dictionary<String,AnyObject>
            let path = item["thumbnail"] as! String
            let key = "/\(path)"
            //print(key)
            orderedCollection[key] = CGFloat(1)
            
        }
        
        
        if(media.count == 0) {
            self.groupDetailView.loadingView.stopAnimating()
        }
        
        for i in media {
            
            let item = i as! Dictionary<String,AnyObject>
            
            if(item["path"] != nil && item.keys.contains("type")) {
                
                let path = item["thumbnail"] as! String
                
                   print("http://ec2-52-34-85-44.us-west-2.compute.amazonaws.com:8080/\(path)")
                    
                  
                    let req = Alamofire.request(.GET, "http://ec2-52-34-85-44.us-west-2.compute.amazonaws.com:8080/\(path)").response { response in
                        
                    let image = UIImage(data: response.2!)
                    
                    if(image != nil) {
                        
                        let URL = response.0!.URL?.path
                        orderedCollection[URL!] = image
                        self.groupMedia.append(image!)
                        if(self.groupMedia.count == media.count) {
                            
                            self.groupMedia.removeAll()
                            print("all image downloaded")
                            for i in media {
                                
                                let item = i as! Dictionary<String,AnyObject>
                                let path = item["thumbnail"] as! String
                                let key = "/\(path)"
                                self.groupMedia.append(orderedCollection[key]! as! UIImage)
                                
                            }
                            
                            //self.groupMedia.reverse()
                            
                            self.groupDetailView.groupMediaCollectionView.reloadData()
                            self.groupDetailView.loadingView.stopAnimating()
                            orderedCollection.removeAll()
                            
                            
                        }
                        
                        
                    }
                    
                    
                    
                }
                
                self.pendingRequests.append(req)
                    
            
            }
            
        }
        
    }
    
    func scaleImage(image: UIImage, scale: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContext(scale)
        image.drawInRect(CGRect(x: 0, y: 0, width: scale.width, height: scale.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }

    
    func refreshData() {
        
        let groupName = appDelegate.joinedGroups[index]!["group"]![0]!["name"]
        //print("groupname is \(groupName)")
        self.groupDetailView.groupNameLabel.text = groupName as? String
        
        let groupCreationTime = appDelegate.joinedGroups[index]!["group"]![0]!["timeStamp"] as? String
        //print("groupname is \(groupCreationTime)")
        let timeComponents = groupCreationTime!.componentsSeparatedByString("T")
        self.groupDetailView.groupCreationTimeLabel.text = timeComponents[0] + "  " + timeComponents[1]
        
        
        let media =  self.appDelegate.joinedGroups[self.index]!["group"]![0]!["media"] as! NSArray
        groupDetailView.mediaLabel.title = "\(media.count)"
        
        let members = self.appDelegate.joinedGroups[self.index]!["group"]![0]!["members"] as! NSArray
        groupDetailView.membersLabel.title = "\(members.count + 1)"
        
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.groupMedia.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        let collectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("groupMedia", forIndexPath: indexPath) as! groupMediaCell
        collectionViewCell.typeLabel.alpha = 1.0
        
        let media =  self.appDelegate.joinedGroups[self.index]!["group"]![0]!["media"] as! NSArray
        let item = media[(media.count-1) - indexPath.row] as! Dictionary<String,AnyObject>
        
        
        let type = item["type"] as! String
        
        if(type == "image"){
            
            collectionViewCell.typeLabel.alpha = 0
        
        } else {
            
//            UIView.animateKeyframesWithDuration(1.33, delay: 0, options: [UIViewKeyframeAnimationOptions.Repeat , UIViewKeyframeAnimationOptions.Autoreverse], animations: { () -> Void in
//                
//                    collectionViewCell.typeLabel.alpha = 0
//                
//                
//                }, completion: { (Bool) -> Void in
//                    
//                    
//                    
//            })
            
        }
        
        collectionViewCell.imageView.image = groupMedia[(self.groupMedia.count-1) - indexPath.row]
        return collectionViewCell
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let cellWidth = (collectionView.frame.width - 2 * 1) / 3
        return CGSizeMake(cellWidth, cellWidth)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        self.groupDetailView.addSubview(self.groupDetailView.progressIndicatorView)
        
        let media =  self.appDelegate.joinedGroups[self.index]!["group"]![0]!["media"] as! NSArray
        let item = media[(media.count-1) - indexPath.row] as! Dictionary<String,AnyObject>
        
        let path = item["path"] as! String
        let type = item["type"] as! String
        let name = item["owner"] as! String
        
        
        if(type == "image") {
            
            let orientation = item["orientation"] as! Int
            
            Alamofire.request(.GET, "http://ec2-52-34-85-44.us-west-2.compute.amazonaws.com:8080/\(path)").response { response in
            
                    //self.mediaItemView.groupNameLabel.text = name
                    let image = UIImage(data: response.2!)
                    let orientation = UIImageOrientation(rawValue: orientation)
                    self.mediaItemView.imagePreview.image = UIImage(CGImage: image!.CGImage!, scale: 1.0,orientation: orientation!)
                    //self.mediaItemView.imagePreview.contentMode = UIViewContentMode.ScaleToFil
                    self.mediaItemView.videoPreviewLayer.removeFromSuperlayer()
                    self.mediaItemView.preview.addSubview(self.mediaItemView.imagePreview)
                
                    self.mediaItemView.frame = CGRect(x: 0, y: 0 - self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
                
                
                    UIView.animateWithDuration(0.33, animations: { () -> Void in
                        
                        self.mediaItemView.frame = self.view.bounds
                    })
                

                    
                }.progress({ (_, bytesRead, bytesToRead) -> Void in
                    
                    
                    if(bytesRead == bytesToRead) {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.groupDetailView.progressIndicatorView.progress = 0.0
                            self.groupDetailView.progressIndicatorView.removeFromSuperview()
                            
                            
                        })
                        
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.groupDetailView.progressIndicatorView.progress =  CGFloat(bytesRead) / CGFloat(bytesToRead)
                        
                    })
                    
                    
                    
                })
            
        } else {
            
            print(path)
            Alamofire.request(.GET, "http://ec2-52-34-85-44.us-west-2.compute.amazonaws.com:8080/\(path)").response { response in
                
            
                let url = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
                let path = url.stringByAppendingString("/\(path)")
                print(path)
                response.2?.writeToFile(path, atomically: true)
                print(response.2?.length)
                //self.mediaItemView.groupNameLabel.text = name
                self.mediaItemView.preview.layer.addSublayer(self.mediaItemView.videoPreviewLayer)
                self.mediaItemView.videoPlayer = AVPlayer(playerItem: AVPlayerItem(URL: NSURL(fileURLWithPath: path)))
                self.mediaItemView.videoPreviewLayer.player = self.mediaItemView.videoPlayer
                self.mediaItemView.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                self.mediaItemView.videoPlayer.actionAtItemEnd = .None
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.mediaItemView.videoPlayer.currentItem)

                
                self.mediaItemView.frame = CGRect(x: 0, y: 0 - self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
                
                UIView.animateWithDuration(0.33, animations: { () -> Void in
                    
                    self.mediaItemView.frame = self.view.bounds
                    
                    }, completion: { (bFlag) -> Void in
                        
                    self.mediaItemView.videoPlayer.play()
                })
                
                
                }.progress({ (_, bytesRead, bytesToRead) -> Void in
                    
                    
                    if(bytesRead == bytesToRead) {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                           self.groupDetailView.progressIndicatorView.progress = 0
                           self.groupDetailView.progressIndicatorView.removeFromSuperview()
                            
                            
                        })
                        
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        print(Float(bytesRead) / Float(bytesToRead))
                       
                        self.groupDetailView.progressIndicatorView.progress =  CGFloat(bytesRead) / CGFloat(bytesToRead)
                        
                        
                    })
                    
                    
                    
                })

            
            
        }
        
        
    }
    
    
    func playerDidReachEnd(notification: NSNotification) {
        
        self.mediaItemView.videoPlayer.seekToTime(kCMTimeZero)
        
    }

    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
    func groupDetailView(view: SHGroupDetailView, didSwipeRight withRecognizer: UISwipeGestureRecognizer) {
       
        groupMedia.removeAll()
        
        for request in self.pendingRequests {
            
            request.cancel()
            
        }
        
        self.pendingRequests.removeAll()
        
        self.groupDetailView.groupMediaCollectionView.reloadData()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func groupDetailView(view: SHGroupDetailView, didSwipeDown withRecognizer: UISwipeGestureRecognizer) {
        
       
    }
    
    func groupDetailView(view: SHGroupDetailView, didPressRefresh withButton: UIButton) {
        
        let media = appDelegate.joinedGroups[index]!["group"]![0]!["media"] as! NSArray
        

        self.previousCount = media.count
        self.fetchGroupMedia()
        
    }
    
    
    func groupDetailView(view: SHGroupDetailView, didClickMediaButton button: UIButton) {
        
        
        self.navigationController?.pushViewController(cameraController, animated: true)
        
        
    }
    
    func groupDetailView(view: SHGroupDetailView, didPressSaveButton withButton: UITabBarItem) {
        
        //save group
        let media =  self.appDelegate.joinedGroups[self.index]!["group"]![0]!["media"] as! NSArray
        print("will download \(media.count) images")
        
        
        for i in media {
            
            let item = i as! Dictionary<String,AnyObject>
            
            if(item["path"] != nil) {
                
                let path = item["path"] as! String
                
                if(item["type"] as! String == "image") {
                    
                    
                    print("http://ec2-52-34-85-44.us-west-2.compute.amazonaws.com:8080/\(path)")
                    
                    
                    Alamofire.request(.GET, "http://ec2-52-34-85-44.us-west-2.compute.amazonaws.com:8080/\(path)").response { response in
                        
                        var imageView = UIImageView()
                        imageView.image = UIImage(data: response.2!)
                        imageView.image = UIImage(CGImage: imageView.image!.CGImage!, scale: 1.0, orientation: UIImageOrientation(rawValue: item["orientation"] as! Int)!)
                        UIImageWriteToSavedPhotosAlbum(imageView.image!, nil, nil, nil)
                        imageView.image = nil
                        
                        
                    
                    }
                
                } else if(item["type"] as! String == "video") {
                    
                     Alamofire.request(.GET, "http://ec2-52-34-85-44.us-west-2.compute.amazonaws.com:8080/\(path)").response { response in
                        
                        
                        let url = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
                        let videoPath = url.stringByAppendingString("/\(path)")
                        print(videoPath)
                        response.2?.writeToFile(videoPath, atomically: true)
                        print(response.2?.length)
                        let library = ALAssetsLibrary()
                        library.writeVideoAtPathToSavedPhotosAlbum(NSURL(fileURLWithPath: videoPath), completionBlock: { (url, err) -> Void in
                            
                            print("video saved")
                            do {
                                
                               try NSFileManager.defaultManager().removeItemAtPath(videoPath)
                                
                            }catch {
                                
                                
                            }
                            
                        })
                        
                        
                    }
                    
                    
                }
            
            }
        }
    }
    
    func mediaItemView(sender: MediaItemView, didSwipeDown withRecognizer: UISwipeGestureRecognizer) {
        
        
        self.mediaItemView.videoPlayer.pause()
        
        UIView.animateWithDuration(0.33, animations: { () -> Void in
            
             self.mediaItemView.frame = CGRect(x: 0, y: 0 - self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
            
            }) { (didFinish) -> Void in
                
                
            self.mediaItemView.imagePreview.image = nil
        }
        
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
