//
//  PTImagePickerController.swift
//  PTImagePickerController
//
//  Created by iffytheperfect on 11/22/14.
//  Copyright (c) 2014 PingTank. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import AssetsLibrary
import MediaPlayer
import Photos

protocol MediaPreviewDelegate {
    
    func mediaPreview(sender: MediaPreview, cancelPost withButton: UIButton)
    func mediaPreview(sender: MediaPreview, postMedia withButton: UIButton)
}

class MediaPreview : MediaItemView {
    
    let closeButton = UIButton()
    let postButton = UIButton()
    var mediaPreviewDelegate: MediaPreviewDelegate?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        //layoutSubviews()
        setupViews()
        
    }
    
    required init(coder aDecoder: NSCoder) {
        
        fatalError()
        
    }
    
    
    override func layoutSubviews() {
        
        //super.layoutSubviews()
        
       // self.groupNameLabel.frame = CGRectZero
        
        preview.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        
        imagePreview.frame = preview.bounds
        
        videoPreviewLayer.frame = preview.bounds
        
        closeButton.frame = CGRect(x: self.frame.maxX - self.frame.width * 0.15 , y: self.frame.width * 0.05 , width: self.frame.width * 0.1, height: self.frame.width * 0.1)
        
        postButton.frame = CGRect(x: self.frame.width * 0.05, y: self.frame.width * 0.05, width: self.frame.width * 0.1, height: self.frame.width * 0.1)

        
    }
    
    
    override func setupViews() {
        
        super.setupViews()
        
        closeButton.setImage(UIImage(named: "closeIcon"), forState: .Normal)
        closeButton.addTarget(self, action: "cancelPreview:", forControlEvents: .TouchUpInside)
        self.addSubview(closeButton)
        
        postButton.setImage(UIImage(named: "postIcon"), forState: .Normal)
        postButton.addTarget(self, action: "postMedia:", forControlEvents: .TouchUpInside)
        self.addSubview(postButton)
        
    }
    
    
    func cancelPreview(sender: UIButton) {
        
        self.mediaPreviewDelegate?.mediaPreview(self, cancelPost: sender)
    }
    
    func postMedia(sender: UIButton) {
        
        self.mediaPreviewDelegate?.mediaPreview(self, postMedia: sender)
    }
    
}

class Encoder {
    
    var writer: AVAssetWriter?
    var videoInput: AVAssetWriterInput?
    var audioInput: AVAssetWriterInput?
    var path: String?
    
    init(path: String, cy: Int, cx: Int, channels: UInt32, rate: Float64) {
        
        self.path = path
        
        do {
            
            try NSFileManager.defaultManager().removeItemAtPath(path)
            
        } catch {
            
            print("cant delete file")
        }
        
        do {
            
            print("\(path)---\(cy)---\(cx)----\(channels)---\(rate)")
            
            try writer = AVAssetWriter(URL: NSURL(fileURLWithPath: path), fileType: AVFileTypeMPEG4)
            
            var settings = Dictionary<String, AnyObject>()
            settings[AVVideoCodecKey] = AVVideoCodecH264
            settings[AVVideoWidthKey] = NSNumber(integer: cx)
            settings[AVVideoHeightKey] = NSNumber(integer: cy)
            settings[AVVideoScalingModeKey] = AVVideoScalingModeResizeAspectFill
            
            videoInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings:settings)
            videoInput?.expectsMediaDataInRealTime = true
            
            writer?.addInput(videoInput!)
            
            var audiosettings = Dictionary<String, AnyObject>()
            
        
            audiosettings[AVFormatIDKey] =  NSNumber(unsignedInt: kAudioFormatMPEG4AAC)
            audiosettings[AVNumberOfChannelsKey] =  NSNumber(unsignedInt: channels)
            audiosettings[AVSampleRateKey] = NSNumber(floatLiteral: rate)
            audiosettings[AVEncoderBitRateKey] = NSNumber(floatLiteral: 64000)
            
            print(audiosettings.count)
            
            audioInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: audiosettings)
            audioInput?.expectsMediaDataInRealTime = true
            
            writer?.addInput(audioInput!)

            
        } catch {
            
            print("failed to initialize writer")
        }
        
           }
    
    func finishWithCompletionHandler(handler: (()-> Void)) {
        writer?.finishWritingWithCompletionHandler(handler)
    }
    
    func encodeFrame(sampleBuffer: CMSampleBufferRef, bVideo: Bool) -> Bool{
        if(CMSampleBufferDataIsReady(sampleBuffer) == true) {
            if(writer?.status == AVAssetWriterStatus.Unknown) {
                let startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                writer?.startWriting()
                writer?.startSessionAtSourceTime(startTime)
            }
        }
        
        if (writer?.status == AVAssetWriterStatus.Failed)
        {
            print("writer error nil")
            return false
        }
        
        if(bVideo) {
            
            print("writing in video")
            if(videoInput?.readyForMoreMediaData == true) {
               _ = videoInput?.appendSampleBuffer(sampleBuffer)
                return true
            }
        } else {
            print("writing in audio")
            if(audioInput?.readyForMoreMediaData == true) {
                _ = audioInput?.appendSampleBuffer(sampleBuffer)
                return true
            }
        }
        return false
    }
}



public struct SHmagePickerViewConstants {
    static let ButtonSize = CGSize(width: 80, height: 68)
    static let RecordButtonSize = CGSize(width: 70, height: 70)
    static let CameraRollButtonSize = CGSize(width: 50, height: 50)
    static let LightGrayColor = UIColor(red: 38/255.0, green: 38/255.0, blue: 38/255.0, alpha: 1.0)
    static let ToolBarHeight = CGFloat(44)
    static let Padding = CGFloat(8)
    static let minimumVideoDurationBeforeShowingNextButton = 0.01
}

// MARK: - PTImagePickerViewDelegate
protocol SHImagePickerViewDelegate {
    
    func imagePikerView(sender: SHImagePickerView, takePicture withButton: UIButton)
    func imagePikerView(sender: SHImagePickerView, rotateCamera withButton: UIButton)
    func imagePikerView(sender: SHImagePickerView, toggleFlash withButton: UIButton)
    func imagePickerView(sender: SHImagePickerView, didSwipeDown withRecognizer: UISwipeGestureRecognizer)
}

// MARK: - PTImagePickerView
class SHImagePickerView: UIView {
    
    let coverView = UIView()
    let recordingButton = UIButton()
    let flashButton = UIButton()
    let cameraRoateButton = UIButton()
    let deleteItem = UIButton()
    let saveItem = UIButton()
    let progressBar = UIView()
    var delegate: SHImagePickerViewDelegate?
    
    override init(frame: CGRect) {
        // call super's init
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
       progressBar.frame = CGRect(x: 0, y: 0, width: 0, height: self.frame.width * 0.2)
       coverView.frame = self.bounds
       recordingButton.frame = CGRect(x: (self.frame.width - self.frame.width * 0.2) / 2, y: self.frame.maxY - 1.5 * self.frame.width * 0.2 , width: self.frame.width * 0.2, height: self.frame.width * 0.2)
       flashButton.frame = CGRect(x: self.frame.width * 0.05, y: self.frame.width * 0.05, width: self.frame.width * 0.1, height: self.frame.width * 0.1)
        cameraRoateButton.frame = CGRect(x: self.frame.maxX - self.frame.width * 0.15, y: self.frame.width * 0.05, width: self.frame.width * 0.1, height: self.frame.width * 0.1)
        
        
    }
    
    func setupViews() {
        
        self.addSubview(coverView)
        
        progressBar.backgroundColor = UIColor(red: 56/255, green: 104/255, blue: 168/255, alpha: 0.5)
        self.coverView.addSubview(progressBar)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: "didSwipeRight:")
        swipeGesture.direction = .Right
        self.addGestureRecognizer(swipeGesture)
        
        recordingButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        recordingButton.layer.cornerRadius = (UIScreen.mainScreen().bounds.width * 0.2 ) / 2
        recordingButton.addTarget(self, action: "takePicture:", forControlEvents: .TouchUpInside)
        self.addSubview(recordingButton)
        
        flashButton.setImage(UIImage(named: "flashIcon"), forState: .Normal)
        flashButton.addTarget(self, action: "toggleFlash:", forControlEvents: .TouchUpInside)
        self.addSubview(flashButton)
        
        cameraRoateButton.setImage(UIImage(named: "rotateCameraIcon"), forState: .Normal)
        cameraRoateButton.addTarget(self, action: "rotateCamera:", forControlEvents: .TouchUpInside)
        self.addSubview(cameraRoateButton)
        
    }
    
    func takePicture(sender: UIButton) {
        
        print("take picture")
        self.delegate?.imagePikerView(self, takePicture: sender)
    }
    
    func rotateCamera(sender: UIButton) {
        
        print("rotate camera")
        self.delegate?.imagePikerView(self, rotateCamera: sender)
    }
    
    func toggleFlash(sender: UIButton) {
        
        print("toggle flash")
        self.delegate?.imagePikerView(self, toggleFlash: sender)
    }
    
    func didSwipeRight(recognizer: UISwipeGestureRecognizer) {
        
        print("did swipe right")
        self.delegate?.imagePickerView(self, didSwipeDown: recognizer)
    }

    
}

enum PTImagePickerControllerCameraPermissionItems: Int {
    
    case CameraAccess = 0
    case PhotosAccess = 1
    
    var permissionTitle: String {
        switch self {
        case .CameraAccess:
            return "Camera Access is Turned Off"
        case .PhotosAccess:
            return "Photo Access is Turned Off"
        }
    }
    
    var permissionMessage: String {
        switch self {
        case .CameraAccess:
            return "Turn on Camera Access in Settings to use your Camera to Create Posts"
        case .PhotosAccess:
            return "Turn on Photo Access in Settings to use your Photos to Create Posts"
        }
    }
    
    // implicitly synthesized
    init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .CameraAccess
        case 1: self = .PhotosAccess
        default: return nil
        }
    }
    
}




// MARK: - PTImagePickerController
class PTImagePickerController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, SHImagePickerViewDelegate, UIAlertViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, UIGestureRecognizerDelegate, MediaPreviewDelegate {
    
    
    
    var imagePickerView = SHImagePickerView()
    var mediaItemView = MediaPreview()
    var usingFrontCamera = false
    var tookPicture = false
    var usingFlash = false
    var usingGrid = false
    var gridImage = UIImage(named: "PTImagePickerControllerGrid")
    var mergedVideoURL: NSURL?
    
    //variables for AVFoundation
    var captureSession: AVCaptureSession?
    var videoCaptureDevice: AVCaptureDevice?
    var audioCaptureDevice: AVCaptureDevice?
    var videoInputDevice: AVCaptureDeviceInput?
    var audioInputDevice: AVCaptureDeviceInput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureQueue: dispatch_queue_t?
    var videoDataOutput: AVCaptureVideoDataOutput?
    var audioDataOutput: AVCaptureAudioDataOutput?
    var videoConnection: AVCaptureConnection?
    var audioConnection: AVCaptureConnection?
    var stillImageVideoConnection: AVCaptureConnection?
    var outputPath = NSTemporaryDirectory() as String
    var totalSeconds: Float64 = 10.00
    var framesPerSecond:Int32 = 30
    var maxDuration: CMTime?
    var progressThumb = UIView()
    var cameraView: UIView = UIView()
    var stopRecording: Bool = false
    var cx: Int = 0
    var cy: Int = 0
    var channels: UInt32? = 0
    var sampleRate: Float64? = 0
    var encoder: Encoder?
    var isCapturing = false
    var isPaused = false
    var discont = false
    var timeOffset = CMTimeMake(0, 0)
    var lastVideo: CMTime?
    var lastAudio: CMTime?
    var isFirstVideo: Bool = true
    var totalDuration: CMTime = kCMTimeZero
    var skipBufferFlag = false
    var stillImage: AVCaptureStillImageOutput?
    var didInitiallySetUpMediaCapture = false
    var didInitiallySetUpAudioCapture = false
    var isVideo = false
    var takenImageView =  UIImageView()
    var videoURL: NSURL?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureSessionDidStartRunningNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        self.imagePickerView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.bounds.width,
            height: self.view.bounds.height
        )
        imagePickerView.delegate = self
        mediaItemView.frame = self.view.bounds
        mediaItemView.mediaPreviewDelegate = self
        self.view.addSubview(imagePickerView)
        self.setupMediaCapture()
       
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.mediaItemView.removeFromSuperview()
        
        self.cameraView.alpha = 0.0
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            print("Will Start Capture Session from setupMediaCapture")
            
            self.captureSession?.startRunning()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                UIView.animateWithDuration(0.33, animations: { () -> Void in
                    self.cameraView.alpha = 1.0
                })
            })
        })
        
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.captureSession?.stopRunning()
        self.mediaItemView.removeFromSuperview()
        self.imagePickerView.progressBar.frame = CGRect(x: 0, y: 0, width: 0, height: self.imagePickerView.progressBar.frame.height)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // Setup AVFoundation
    func startCapture() {
        
        if(!isCapturing) {
            
            print("will start capturing")
            encoder = nil
            self.isPaused = false
            discont = false
            self.isCapturing = true
        }
    }
    
    func stopCapture() {
        
        print("will stop capturing")
        self.isCapturing = false
        self.save()
    }
    
    
    func addVideoInputs() {
        videoCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        if let videoDevice = videoCaptureDevice {
            
            do {
                
                try videoInputDevice =  AVCaptureDeviceInput(device: videoDevice)
                captureSession?.addInput(videoInputDevice)
                setVideoOutput()
                
            } catch {
                
            }
            
        } else {
            print("video Device not found!")
        }
    }
    
    func setVideoOutput() {
        
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput?.setSampleBufferDelegate(self, queue: captureQueue!)
        captureSession?.addOutput(videoDataOutput)
        videoConnection = videoDataOutput?.connectionWithMediaType(AVMediaTypeVideo)
        print("videoConnection is \(videoConnection)")
        videoConnection?.videoOrientation = AVCaptureVideoOrientation.Portrait
        var settings = Dictionary<String,AnyObject>()
        settings[kCVPixelBufferPixelFormatTypeKey as String] =  NSNumber(unsignedInt: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
       
        videoDataOutput?.videoSettings = settings
        var actual = (videoDataOutput?.videoSettings as [NSObject : AnyObject]?)!
        print("actual is \(actual.count)")
        cy = (actual["Height"]?.integerValue  as Int?)!
        cx = (actual["Width"]?.integerValue as Int?)!
        print("cx and cy are ---- \(cx) and \(cy)")
        
    }
    
    func addAudioInputs() {
        
        audioCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        do {
            
           try  audioInputDevice =  AVCaptureDeviceInput(device: audioCaptureDevice)
           captureSession?.addInput(audioInputDevice)
           setAudioOutput()
            
        } catch {
            
            print("failed to add audio Inputs")
        }
        
    }
    
    func setAudioOutput() {
        
        audioDataOutput = AVCaptureAudioDataOutput()
        audioDataOutput?.setSampleBufferDelegate(self, queue: captureQueue!)
        captureSession?.addOutput(audioDataOutput)
        audioConnection = audioDataOutput?.connectionWithMediaType(AVMediaTypeAudio)
        print("audioConnection is \(audioConnection)")

    }
    
    func setStillImageOutput() {
        
        stillImage = AVCaptureStillImageOutput()
        captureSession?.addOutput(stillImage)
        var settings = Dictionary<String,AnyObject>()
        settings[AVVideoCodecKey] = AVVideoCodecJPEG
        
//        var settings = NSDictionary(objectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey)
        stillImage!.outputSettings = settings
        
        if stillImage?.connections == nil {
            return
        }
        
        for connection in stillImage!.connections {
            let ports  = connection.inputPorts as! [AVCaptureInputPort]
            for port in ports {
                if(port.mediaType == AVMediaTypeVideo) {
                    self.stillImageVideoConnection = connection as? AVCaptureConnection
                }
            }
        }
    }
    
    func addPreviewLayer() {
        
        // add preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: view.bounds.height
        )
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        print("preview connection is --- \(previewLayer?.connection)")
        
        // add long press gesture
        let recognizer = UILongPressGestureRecognizer(target: self, action:Selector("holdAction:"))
        recognizer.minimumPressDuration = 0.5
        recognizer.delegate = self
        imagePickerView.recordingButton.addGestureRecognizer(recognizer)
        
//        imagePickerView.recordVideoButton.addGestureRecognizer(recognizer)
        cameraView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.bounds.width,
            height: self.view.bounds.width
        )
        cameraView.layer.addSublayer(previewLayer!)
        imagePickerView.coverView.addSubview(cameraView)
        imagePickerView.coverView.bringSubviewToFront(imagePickerView.progressBar)
        
    }
    
    func save() {
        
        if(CMTimeGetSeconds(totalDuration) > 0 ) {
            
            print("will save movie")
            let fileName: String = NSTemporaryDirectory() as String + "capture.mp4"
            //let outputURL = NSURL(fileURLWithPath: fileName)
            let data = NSData(contentsOfFile: fileName)
            print(data?.length)
            
            dispatch_async(captureQueue!, {
                
                self.encoder?.finishWithCompletionHandler({
                    
                  dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    print("will present preview")
                    
                    self.imagePickerView.progressBar.frame = CGRect(x: 0, y: 0, width: 0, height: self.imagePickerView.progressBar.frame.height)
                    let outputURL = NSURL(fileURLWithPath: fileName)
                    self.mediaItemView.removeFromSuperview()
                    self.mediaItemView.imagePreview.removeFromSuperview()
                    self.mediaItemView.videoPreviewLayer.removeFromSuperlayer()
                    
                    self.mediaItemView.videoPlayer = AVPlayer(playerItem: AVPlayerItem(URL: outputURL))
                    self.mediaItemView.videoPreviewLayer.player = self.mediaItemView.videoPlayer
                    self.mediaItemView.preview.layer.addSublayer(self.mediaItemView.videoPreviewLayer)
                    self.view.addSubview(self.mediaItemView)
                    self.mediaItemView.videoPlayer.play()
                    
                    self.mediaItemView.videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.None
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.mediaItemView.videoPlayer.currentItem)
                    
                    self.isVideo = true
                    self.videoURL = outputURL
                    
                    
                    })
                    
                    
                })
            })
            
        } else {
            
            print("Can't save movie, total duration is <= 0")

        }
    }
    
    func playerDidReachEnd(notification: NSNotification) {
        
        self.mediaItemView.videoPlayer.seekToTime(kCMTimeZero)
        
    }
    
    
    func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice {
        
        var rv: AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in devices {
            
            if(device.position == position) {
                
                rv = device as! AVCaptureDevice
            }
            
        }
        return rv
    }
    
    func toggleCamera() {
        
        if videoInputDevice == nil {
            return
        }
        
        var newInputDevice: AVCaptureDeviceInput = videoInputDevice!
        let position: AVCaptureDevicePosition? = videoInputDevice?.device.position
        var newDevice: AVCaptureDevice?
        if(position == AVCaptureDevicePosition.Back) {
            newDevice = cameraWithPosition(AVCaptureDevicePosition.Front)
            self.usingFrontCamera = true
            
            do {
                
                try newInputDevice = AVCaptureDeviceInput(device: newDevice)
                
            } catch {
                
            }
            
            
        } else if(position == AVCaptureDevicePosition.Front) {
            newDevice = cameraWithPosition(AVCaptureDevicePosition.Back)
            self.usingFrontCamera = false
           
            
            do  {
                
                try newInputDevice = AVCaptureDeviceInput(device: newDevice)
                
            } catch {
                
            }
        }
        
        captureSession?.stopRunning()
        captureSession?.beginConfiguration()
        
        captureSession?.removeInput(videoInputDevice)
        captureSession?.removeOutput(videoDataOutput)
        videoInputDevice = newInputDevice
        captureSession?.addInput(videoInputDevice)
        captureSession?.removeOutput(stillImage)
        setStillImageOutput()
        setVideoOutput()
        
        captureSession?.commitConfiguration()
        captureSession?.startRunning()
        UIView.transitionWithView(self.imagePickerView.coverView, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: {}, completion: nil)
        
    }
    
    func setAudioFormat(fmt: CMFormatDescriptionRef) {
        
        let asbd: UnsafePointer<AudioStreamBasicDescription>? = CMAudioFormatDescriptionGetStreamBasicDescription(fmt)
        sampleRate = asbd?.memory.mSampleRate
        channels = asbd?.memory.mChannelsPerFrame
    }
    
    
    func convertCfTypeToSampleBufferRef(cfValue: Unmanaged<CMSampleBufferRef>) -> CMSampleBufferRef{
        
        /* Coded by Vandad Nahavandipoor */
        
        let value = Unmanaged.fromOpaque(
            cfValue.toOpaque()).takeRetainedValue() as CMSampleBufferRef
        return value
    }
    
    func adjustTime(sample: CMSampleBufferRef, offset: CMTime) -> CMSampleBufferRef{
        
        let count =  UnsafeMutablePointer<CMItemCount>.alloc(sizeof(CMItemCount) * 1)
        CMSampleBufferGetSampleTimingInfoArray(sample, 0, nil, count)
        
        let pInfo = UnsafeMutablePointer<CMSampleTimingInfo>.alloc(sizeof(CMSampleTimingInfo) * count.memory)
        CMSampleBufferGetSampleTimingInfoArray(sample, count.memory, pInfo, count)
        for (var i: CMItemCount = 0; i < count.memory; i++)
        {
            pInfo[i].decodeTimeStamp = CMTimeSubtract(pInfo[i].decodeTimeStamp, offset);
            pInfo[i].presentationTimeStamp = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset);
        }
        let sout = UnsafeMutablePointer<CMSampleBufferRef?>.alloc(sizeof(CMSampleBufferRef) * 1)
        CMSampleBufferCreateCopyWithNewTiming(nil, sample, count.memory, pInfo, sout)
        return sout.memory!
    }
    
    func updateProgressBar(inc: Float64) {
        
        self.imagePickerView.progressBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width * CGFloat(inc / 10.00 ), height: self.imagePickerView.progressBar.frame.height)
        
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
        //print(connection)
        if (CMSampleBufferDataIsReady(sampleBuffer) == false) {
            
            print("data not ready")
            return
        }
        var bVideo: Bool? = true
        
        
        var newSampleBuffer = sampleBuffer
        
        if(!self.isCapturing || self.isPaused) {
            
            //print("returning")
            return
        }
        
        if(connection != videoConnection) {
            
            print("audio connection")
            bVideo = false
            
        } else {
            
            print("video connection")
        }
        
        if(encoder == nil && !bVideo!) {
            
            // setup the Encoder
            
            print("setting up encoder")
            
            let fmt = CMSampleBufferGetFormatDescription(sampleBuffer)
            self.setAudioFormat(fmt!)
            let filePath = NSTemporaryDirectory() as String + "capture.mp4"
            encoder = Encoder(path: filePath, cy: cy, cx: cx, channels: channels!, rate: sampleRate!)
            print(encoder)

            skipBufferFlag = true
        }
        
        
        if(skipBufferFlag == true && bVideo == true) {
            
            skipBufferFlag = false
            
        }
        
        if(skipBufferFlag) {
            
            //skipping the initial audio buffers
            print("returning and skipping audio buffers")
            return
        }
        
        if(discont) {
            
            if bVideo != nil {
                if bVideo! {
                    return
                }
            }
            
            discont = false
            
            //calculate the time elapsed between the previous video segment and the new one being recorded
            
            var pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            let last = bVideo! ? lastVideo : lastAudio
            // print("last and LastAudio  is \(CMTimeGetSeconds(last!))---- \(CMTimeGetSeconds(lastAudio!))")
            if(timeOffset.value != 0) {
                
                pts = CMTimeSubtract(pts, timeOffset)
            }
            
            if last == nil {
                return
            }
            
            let offset = CMTimeSubtract(pts, last!)
            
            if(timeOffset.value == 0) {
                
                timeOffset = offset
                
            } else {
                
                timeOffset = CMTimeAdd(timeOffset, offset)
            }
            
            print("offset is \(CMTimeGetSeconds(offset))")
            print("timeOffset is \(CMTimeGetSeconds(timeOffset))")
            
        }
        
        if(timeOffset.value > 0) {
            
            // adjust the time info of buffers by sybtracting timeOffset
            newSampleBuffer = self.adjustTime(newSampleBuffer, offset: self.timeOffset)
        }
        
        var pts = CMSampleBufferGetPresentationTimeStamp(newSampleBuffer)
        let dur = CMSampleBufferGetDuration(newSampleBuffer)
        
        if(dur.value > 0) {
            
            pts = CMTimeAdd(pts, dur)
            totalDuration = CMTimeAdd(totalDuration, dur)
            
        }
        
        if(bVideo!) {
            
            lastVideo = pts
            
        } else {
            
            lastAudio = pts
        }
        
        if(CMTimeGetSeconds(totalDuration) <= 10) {
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.updateProgressBar(CMTimeGetSeconds(self.totalDuration))
            })
            
            encoder?.encodeFrame(newSampleBuffer, bVideo: bVideo!)
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.isCapturing = false
                //self.save()
                
            })
            
        }
        
    }
    
    func setupMediaCapture() {
        
        self.cameraView.alpha = 0.0
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSessionPresetiFrame1280x720
        captureQueue = dispatch_queue_create("captureQueue", DISPATCH_QUEUE_SERIAL)
        
        //Add Video Input
        addVideoInputs()
        setStillImageOutput()
        
        //add Audio Input
        addAudioInputs()
        
        //Add Capture Preview Layer
        addPreviewLayer()
        stopRecording = true
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            print("Will Start Capture Session from setupMediaCapture")
            
                self.captureSession?.startRunning()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    UIView.animateWithDuration(0.33, animations: { () -> Void in
                        self.cameraView.alpha = 1.0
                    })
                })
            })
    }
    
    func holdAction(recognizer: UILongPressGestureRecognizer) {
        
        if recognizer.state == UIGestureRecognizerState.Began {
            
            startCapture()
            
       } else if recognizer.state == UIGestureRecognizerState.Ended {

            stopCapture()
            
        }
    }
    
    func presentCameraWithLimitedOptions(photoAuthorized: Bool = true, cameraAuthorized: Bool = true, microphoneAuthorized: Bool = true) {
        var needsToShowImagePickerViewWithAuthorizationInstructions = true
        var authorizationInstructionTitle = ""
        var authorizationInstructionSubTitle = ""
        var authorizationInstruction = ""
        
        if !photoAuthorized && !cameraAuthorized && !microphoneAuthorized {
            // Photo, Camera, and Mic not authorized
            authorizationInstructionTitle = "Take and Save Pictures/Videos"
            authorizationInstructionSubTitle = "Please allow access to Camera/Photos/Mic"
            authorizationInstruction = "1. Open your device Settings\n2. Go to Privacy\n3. Go to Camera\n4. Turn PingTank ON\n5. Go to Photos\n6. Turn PingTank ON\n7. Go to Microphone\n8. Turn PingTank ON"
        } else if !photoAuthorized && !cameraAuthorized {
            // Photo and Camera not authorized
            authorizationInstructionTitle = "Take and Save Pictures/Videos"
            authorizationInstructionSubTitle = "Please allow access to Camera/Photos"
            authorizationInstruction = "1. Open your device Settings\n2. Go to Privacy\n3. Go to Camera\n4. Turn PingTank ON\n5. Go to Photos\n6. Turn PingTank ON"
        } else if !microphoneAuthorized && !cameraAuthorized {
            // Mic and camera not authorized
            authorizationInstructionTitle = "Take and Save Pictures/Videos"
            authorizationInstructionSubTitle = "Please allow access to Camera/Mic"
            authorizationInstruction = "1. Open your device Settings\n2. Go to Privacy\n3. Go to Camera\n4. Turn PingTank ON\n5. Go to Microphone\n6. Turn PingTank ON"
        } else if !microphoneAuthorized && !photoAuthorized {
            // Mic and photo not authorized
            authorizationInstructionTitle = "Take and Save Pictures/Videos"
            authorizationInstructionSubTitle = "Please allow access to Photos/Mic"
            authorizationInstruction = "1. Open your device Settings\n2. Go to Privacy\n3. Go to Photos\n4. Turn PingTank ON\n5. Go to Microphone\n6. Turn PingTank ON"
        } else if !photoAuthorized {
            // Photo not authorized
            authorizationInstructionTitle = "Save Pictures/Videos"
            authorizationInstructionSubTitle = "Please allow access to Photos"
            authorizationInstruction = "1. Open your device Settings\n2. Go to Privacy\n3. Go to Photos\n4. Turn PingTank ON"
        } else if !cameraAuthorized {
            // Camera not authorized
            authorizationInstructionTitle = "Take Pictures/Videos"
            authorizationInstructionSubTitle = "Please allow access to Camera"
            authorizationInstruction = "1. Open your device Settings\n2. Go to Privacy\n3. Go to Camera\n4. Turn PingTank ON"
        } else if !microphoneAuthorized {
            // Camera not authorized
            authorizationInstructionTitle = "Record Videos"
            authorizationInstructionSubTitle = "Please allow access to Microphone"
            authorizationInstruction = "1. Open your device Settings\n2. Go to Privacy\n3. Go to Microphone\n4. Turn PingTank ON"
        } else {
            // Camera, Photo, and Mic are authorized
            needsToShowImagePickerViewWithAuthorizationInstructions = false
        }
        
        self.imagePickerView.delegate = self
//        self.disableButtons()
        
        if needsToShowImagePickerViewWithAuthorizationInstructions {
            let imageNotAvailableView = PTImagePickerNotAvailableView()
            imageNotAvailableView.title = authorizationInstructionTitle
            imageNotAvailableView.subTitle = authorizationInstructionSubTitle
            imageNotAvailableView.instruction = authorizationInstruction
            imageNotAvailableView.frame = CGRect(
                x: 0,
                y: 44,
                width: self.view.bounds.width,
                height: self.view.bounds.height
            )
//            self.imagePickerView.toolBarBackButton.enabled = true
            print("Need one of the permissions to be authorized..")
            self.view.addSubview(imageNotAvailableView)
        } else {
//            self.enableButtons()
        }
    }
    
    
    
    
    // pragma mark - choose from camera roll
    
   
    
    func takePicturePressed() {
        
        if(self.stillImageVideoConnection != nil && stillImage != nil) {
            self.stillImage!.captureStillImageAsynchronouslyFromConnection(stillImageVideoConnection!, completionHandler: { (sampleBuffer, error) -> Void in
                
                
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                var capturedImage: UIImage? = UIImage(data: imageData)
                print(capturedImage!)
                
                if(self.usingFrontCamera) {
                    
                    capturedImage = UIImage(CGImage: capturedImage!.CGImage!, scale: 1, orientation: UIImageOrientation.LeftMirrored)
                    let rotatedImage = self.rotateAndOrientate(capturedImage!, orientation: capturedImage!.imageOrientation)
                    
                    self.mediaItemView.imagePreview.removeFromSuperview()
                    self.mediaItemView.removeFromSuperview()
                    self.mediaItemView.imagePreview.image = rotatedImage
                    self.mediaItemView.preview.addSubview(self.mediaItemView.imagePreview)
                    self.view.addSubview(self.mediaItemView)
                    self.isVideo = false
                    self.takenImageView.image = rotatedImage
                    
                    
                } else {
                    
                    capturedImage = UIImage(CGImage: capturedImage!.CGImage!, scale: 1, orientation: capturedImage!.imageOrientation)
                    
                    self.mediaItemView.imagePreview.removeFromSuperview()
                    self.mediaItemView.removeFromSuperview()
                    self.mediaItemView.imagePreview.image = capturedImage
                    self.mediaItemView.preview.addSubview(self.mediaItemView.imagePreview)
                    self.view.addSubview(self.mediaItemView)
                    self.isVideo = false
                    self.takenImageView.image = capturedImage

                
                }
                
                
            })
            
        }
    }
    
    // MARK: Rotate Image in case of front camera
    func rotateAndOrientate(image: UIImage, orientation: UIImageOrientation) -> UIImage {
        
        UIGraphicsBeginImageContext(image.size)
        let context = UIGraphicsGetCurrentContext()
        
        if orientation == UIImageOrientation.Right {
            CGContextRotateCTM(context, CGFloat(90/180 * M_PI))
        } else if orientation == UIImageOrientation.Left {
            CGContextRotateCTM(context, CGFloat(-90/180 * M_PI))
        } else if orientation == UIImageOrientation.Down {
            print("Down Orientation")
        } else if orientation == UIImageOrientation.Up {
            CGContextRotateCTM(context, CGFloat(90/180 * M_PI))
        } else {
            print("Other Orientation")
        }
        image.drawAtPoint(CGPointZero)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    func toggleFlash() {
        if (self.usingFlash == false) {
            self.flashOn()
        }
        else {
            self.flashOff()
        }
    }
    
    func flashOn() {
        print("flash on")
        
        if(videoCaptureDevice != nil) {
            
            if(self.usingFrontCamera == false) {
                
                do {
                    
                    try videoCaptureDevice!.lockForConfiguration()
                    videoCaptureDevice!.flashMode = AVCaptureFlashMode.On
                    videoCaptureDevice!.torchMode = AVCaptureTorchMode.On
                    videoCaptureDevice!.unlockForConfiguration()
                    self.usingFlash = true
                    
                } catch {
                    
                    
                }
                
            }
        }
    }
    
    func flashOff() {
        
        print("flash off")
        //self.cameraUI.cameraFlashMode = UIImagePickerControllerCameraFlashMode.Off
        if(videoCaptureDevice != nil) {
            
            if(self.usingFrontCamera == false) {
                
                do {
                    
                   try videoCaptureDevice!.lockForConfiguration()
                    videoCaptureDevice!.flashMode = AVCaptureFlashMode.Off
                    videoCaptureDevice!.torchMode = AVCaptureTorchMode.Off
                    videoCaptureDevice!.unlockForConfiguration()
                    self.usingFlash = false
                    
                } catch {
                    
                    
                }
                
                
            }
        }
    }

    
    
    func imagePikerView(sender: SHImagePickerView, takePicture withButton: UIButton) {
        
        self.takePicturePressed()
        
    }
    
    func imagePikerView(sender: SHImagePickerView, rotateCamera withButton: UIButton) {
        
        self.toggleCamera()
    }
    
    func imagePikerView(sender: SHImagePickerView, toggleFlash withButton: UIButton) {
        
        self.toggleFlash()
    }
    
    func imagePickerView(sender: SHImagePickerView, didSwipeDown withRecognizer: UISwipeGestureRecognizer) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func mediaPreview(sender: MediaPreview, cancelPost withButton: UIButton) {
        
        self.mediaItemView.removeFromSuperview()
        self.mediaItemView.imagePreview.removeFromSuperview()
        self.mediaItemView.videoPreviewLayer.removeFromSuperlayer()
        self.mediaItemView.videoPlayer.pause()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: self.mediaItemView.videoPlayer.currentItem)
        self.mediaItemView.imagePreview.image = nil
        
        self.imagePickerView.progressBar.frame = CGRect(x: 0, y: 0, width: 0, height: self.imagePickerView.progressBar.frame.height)
        self.totalDuration = kCMTimeZero
        
    }
    
    func mediaPreview(sender: MediaPreview, postMedia withButton: UIButton) {
        
        self.mediaItemView.removeFromSuperview()
        self.mediaItemView.imagePreview.removeFromSuperview()
        self.mediaItemView.videoPreviewLayer.removeFromSuperlayer()
        self.mediaItemView.videoPlayer.pause()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: self.mediaItemView.videoPlayer.currentItem)
        self.mediaItemView.imagePreview.image = nil
        self.captureSession?.stopRunning()
        self.totalDuration = kCMTimeZero
        
        if(self.isVideo) {
            
            print("will upload video")
            NSNotificationCenter.defaultCenter().postNotificationName("caturedVideo", object: self.videoURL!)
            
        } else {
            
            print("will upload image")
            NSNotificationCenter.defaultCenter().postNotificationName("capturedImage", object: takenImageView.image)
            takenImageView.image = nil
            
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
}


class PTImagePickerNotAvailableView: UIView {
    
    // Accessors
    
    var title: String? {
        set(val) {
            self.titleLabel.text = val
        }
        get {
            return self.titleLabel.text
        }
    }
    
    var subTitle: String? {
        set(val) {
            self.subTitleLabel.text = val
        }
        get {
            return self.subTitleLabel.text
        }
    }
    
    var instruction: String? {
        set(val) {
            self.instructionLabel.text = val
        }
        get {
            return self.instructionLabel.text
        }
    }
    
    var titleLabel = UILabel()
    var subTitleLabel = UILabel()
    var instructionLabel = UILabel()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        self.alpha = 0.87
        
        self.titleLabel.textColor = UIColor.whiteColor()
        self.titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        self.titleLabel.textAlignment = .Center
        self.titleLabel.numberOfLines = 0
        self.titleLabel.text = "Take Pictures with PingTank"
        
        self.subTitleLabel.textColor = UIColor.whiteColor()
        self.subTitleLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        self.subTitleLabel.textAlignment = .Center
        self.subTitleLabel.numberOfLines = 0
        self.subTitleLabel.text = "Please allow access to your camera, and start creating posts with PingTank"
        
        self.instructionLabel.textColor = UIColor.whiteColor()
        self.instructionLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 13)
        self.instructionLabel.textAlignment = .Left
        self.instructionLabel.numberOfLines = 0
        self.instructionLabel.text = "1. Open your device Settings\n2. Go to Privacy\n3. Go to Camera\n4. Turn PingTank ON"
        
        self.addSubview(self.titleLabel)
        self.addSubview(self.subTitleLabel)
        self.addSubview(self.instructionLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        print("Laying out subviews for PTImagePickerNotAvailableView")
        
        self.titleLabel.sizeToFit()
        self.titleLabel.frame = CGRect(
            x: 0,
            y: 100,
            width: self.bounds.width,
            height: self.titleLabel.frame.height
        )
        
        self.subTitleLabel.sizeToFit()
        self.subTitleLabel.frame = CGRect(
            x: 5,
            y: self.titleLabel.frame.origin.y + self.titleLabel.frame.height + 20,
            width: self.bounds.width - 10,
            height: self.subTitleLabel.frame.height
        )
        
        self.instructionLabel.sizeToFit()
        self.instructionLabel.frame = CGRect(
            x: 5,
            y: self.subTitleLabel.frame.origin.y + self.subTitleLabel.frame.height + 20,
            width: self.bounds.width - 10,
            height: self.instructionLabel.frame.height
        )
        
    }
}

