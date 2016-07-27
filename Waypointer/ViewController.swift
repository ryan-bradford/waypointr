//
//  ViewController.swift
//  Sidus
//
//  Created by Ryan on 4/20/15.
//  Copyright (c) 2015 Ryan. All rights reserved.
//

import UIKit
import SceneKit
import CoreText
import AVFoundation
import CoreMotion
import CoreLocation //Longitude is X, Latitude is Y

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var startFromNorth = -1.0 //The heading of the person
    var cannotRun = CannotRunScreen() //The screen that is displayed if the app cannot run
    var locationManager : MyLocationManager?
    internal var motionManager : MyMotionManager?
    var activeLine = CenterLine() //The line that moves in initStage1
    var centerLine = CenterLine() //The line that stays in initStage1
    var tint = GreyTintScreen() //The grey tint that is displayed in initStage1
    var isAbleToRun = true //Set to false if the phone is too old or does not allocate the proper permissions
    var cameraAngleX = (1.0) //The FOV of the camera
    var cameraAngleY = (1.0) //The FOV of the camera
    var initIsFinished = false //Set to true when the heading is set
    var lastTimeInAppReset = CACurrentMediaTime()
    //These Are Kinda In Order
    var groups : Array<WaypointGroup> //Just Blank
    internal var manage : WaypointManager
    var groupScreen : GroupScreen?
    var addButton : AddButton?
    var addGroupButton : AddGroup?
    var verifyButton : VerifyButton?
    var addressButton : AddAddressButton?
    var myMath : MyMath?
    var reader : WaypointReader?
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        classes.screenDiameter = Double(sqrt(pow(UIScreen.mainScreen().bounds.width,2) + pow(UIScreen.mainScreen().bounds.height,2)))
        groups = Array<WaypointGroup>()
        manage = WaypointManager(x: 0.0, y: 0.0, z: 0.0, cameraAngleX: cameraAngleX, cameraAngleY: cameraAngleY, groups: groups, startFromNorth: startFromNorth)
        groupScreen = nil
        addButton = nil
        self.verifyButton = nil
        addressButton = nil
        myMath = nil
        reader = nil
        motionManager = nil
        locationManager = nil
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        addGroupButton = AddGroup(viewController: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        classes.screenDiameter = Double(sqrt(pow(UIScreen.mainScreen().bounds.width,2) + pow(UIScreen.mainScreen().bounds.height,2)))
        groups = Array<WaypointGroup>()
        manage = WaypointManager(x: 0.0, y: 0.0, z: 0.0, cameraAngleX: cameraAngleX, cameraAngleY: cameraAngleY, groups: groups, startFromNorth: startFromNorth)
        groupScreen = nil
        addButton = nil
        self.verifyButton = nil
        addressButton = nil
        myMath = nil
        reader = nil
        motionManager = nil
        locationManager = nil
        super.init(coder: aDecoder)
        addGroupButton = AddGroup(viewController: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewWillAppear(anim : Bool) {
        //sleep(1)
        initStage1()
        startThread()
    }
    
    func startThread() {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            while(self.isAbleToRun) {
                usleep(20000)
                if(classes.isInForeground && self.initIsFinished && self.buttonsAreGood()) {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.updateVars()
                        self.manage.orderWaypoints()
                        self.updateWaypoints()
                    }
                }
            }
        }
    }
    //Periodic Processing ->
    
    func updateVars() {
        self.manage.generateVars()
    }
    
    func buttonsAreGood() -> Bool {
        for i in 0 ..< groupScreen!.buttons!.count {
            if !groupScreen!.buttons![i].shouldRedraw {
                return false
            }
        }
        return true
    }
    
    //<- Periodic Processing
    
    //Periodic Graphics ->
    
    func showGroupScreen() {
        self.view.addSubview(self.groupScreen!)
        addGroupButton!.showGroupScreen = false
        self.hideAllButtons()
    }
    
    func hideGroupScreen() {
        self.showAllButtons()
        self.groupScreen!.removeFromSuperview()
        groupScreen!.goAwayGroupScreen = false
    }
    
    func manageGroupScreen() {
        if(addGroupButton!.showGroupScreen) {
            self.view.addSubview(self.groupScreen!)
            addGroupButton!.showGroupScreen = false
            self.hideAllButtons()
        }
        if(groupScreen!.goAwayGroupScreen) {
            self.showAllButtons()
            self.groupScreen!.removeFromSuperview()
            groupScreen!.goAwayGroupScreen = false
        }
    }
    
    
    func updateWaypoints() {
        for i in (self.manage.drawnWaypoints.reverse()) {
            i.drawRect(self.view.frame)
            if(!i.drawn) {
                self.view.addSubview(i)
                i.drawn = true
            }
        }
    }
    
    //<- Periodic Graphics
    
    func removeWaypoints() {
        for i in 0 ..< self.manage.drawnWaypoints.count {
            self.manage.drawnWaypoints[i].removeFromSuperview()
            self.manage.drawnWaypoints[i].drawn = false
        }
    }
    
    
    func showAllButtons() {
        self.view.addSubview(addButton!)
        self.view.addSubview(addressButton!)
        self.view.addSubview(addGroupButton!)
    }
    
    func hideAllButtons() {
        addButton!.removeFromSuperview()
        addressButton!.removeFromSuperview()
        addGroupButton!.removeFromSuperview()
    }
    
    func removeAllGraphics() {
        for v in self.view.subviews {
            v.removeFromSuperview()
        }
    }
    
    //Init Stages ->
    
    func initStage1() {
        classes.cantRecal = true
        initCameraFeed()
        if(isAbleToRun) {
            self.view.addSubview(tint)
            locationManager = MyLocationManager(myView: self)
            self.verifyButton = VerifyButton()
        }
    }
    
    func initStage2()  {
        if(isAbleToRun) {
            tint.removeFromSuperview()
            motionManager = MyMotionManager(myView: self, manage: manage)
        }
        if(isAbleToRun) {
            self.centerLine.setY(Int(classes.screenHeight / 2))
            self.view.addSubview(activeLine)
            self.view.addSubview(centerLine)
            sleep(2)
            self.view.addSubview(verifyButton!)
        }
    }
    
    func initStage3() {
        if(isAbleToRun) {
            if(groupScreen == nil) {
                reader = WaypointReader(cameraAngleX: cameraAngleX, cameraAngleY: cameraAngleY, startFromNorth: startFromNorth, manage: manage)
                reader!.readGroups()
                groupScreen = GroupScreen( manage: manage, viewController: self)
                addButton = AddButton(manager: manage)
                addressButton = AddAddressButton(manager: manage)
            }
            motionManager!.motionStage1Or2 = false
            verifyButton!.removeFromSuperview()
            showAllButtons()
            self.activeLine.removeFromSuperview()
            self.centerLine.removeFromSuperview()
            //locationManager?.locationManager?.stopUpdatingHeading()
            
        }
    }
    
    //<- Init Stages
    
    //Device Parts Init ->
    
    func initCameraFeed() { //TO STUDY
        let captureSession = AVCaptureSession()
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspect //TO STUDY
        if let videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo) {
            //videoDevice.activeFormat.highResolutionStillImageDimensions
            var cameraRatio = 1.0
            var cameraHeight = 1.0
            var cameraWidth = 1.0
            if let formatDescription = videoDevice.activeFormat.formatDescription {
                let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
                cameraRatio = Double(dimensions.height) / Double(dimensions.width)
                cameraWidth = Double(dimensions.height)
                cameraHeight = Double(dimensions.width)
            }
            videoDevice.activeFormat.highResolutionStillImageDimensions
            cameraAngleX = Double(videoDevice.activeFormat.videoFieldOfView)
            cameraAngleY = Double(videoDevice.activeFormat.videoFieldOfView) * cameraRatio
            let screenRatio = classes.screenWidth / classes.screenHeight
            if(screenRatio > cameraRatio) {
                let scaleFactor = 1 - (((classes.screenWidth * cameraHeight / classes.screenHeight) - cameraWidth) / cameraWidth)
                cameraAngleX *= scaleFactor
            } else if(screenRatio < cameraRatio) {
                let scaleFactor = 1 - (((classes.screenHeight * cameraWidth / classes.screenWidth) - cameraHeight) / cameraHeight)
                cameraAngleY *= scaleFactor
            }
            cameraAngleX *= (M_PI / 180)
            cameraAngleY *= (M_PI / 180)
            myMath = MyMath()
            let videoIn : AVCaptureDeviceInput?
            do {
                videoIn = try AVCaptureDeviceInput(device: videoDevice)
                if (captureSession.canAddInput(videoIn! as AVCaptureInput)){
                    captureSession.addInput(videoIn! as AVCaptureDeviceInput)
                }
            } catch _ {
                removeAllGraphics()
                isAbleToRun = false
                self.view.addSubview(cannotRun)
            }
        } else {
            removeAllGraphics()
            isAbleToRun = false
            self.view.addSubview(cannotRun)
        }
        captureSession.startRunning()
        previewLayer.frame = self.view.bounds
        self.view.layer.addSublayer(previewLayer)
    }
    
    //<- Device Parts Init
    
    
    //Recalibrate Stuff ->
    
    func removeStuff() {
        self.removeWaypoints()
        self.removeScreens()
    }
    
    func fullRecalibrate() {
        self.resetVars()
        locationManager!.locationManager!.startUpdatingHeading()
        self.centerLine.setY(Int(classes.screenHeight / 2))
        self.view.addSubview(activeLine)
        activeLine.drawRect(CGRect(x: 0, y: 0, width: classes.screenWidth, height: classes.screenHeight))
        self.view.addSubview(centerLine)
        centerLine.drawRect(CGRect(x: 0, y: 0, width: classes.screenWidth, height: classes.screenHeight))
        self.view.addSubview(verifyButton!)
        verifyButton!.drawRect(CGRect(x: 0, y: 0, width: classes.screenWidth, height: classes.screenHeight))
    }
    
    func inAppRecalibrate() {
        classes.cantRecal = true
        self.initIsFinished = false
        self.startFromNorth = -1.0
        locationManager!.stageOne = true
        locationManager!.locationManager!.startUpdatingHeading()
    }
    
    func resetVars() {
        classes.cantRecal = true
        self.initIsFinished = false
        motionManager!.motionStage1Or2 = true
        motionManager!.gyroBaseImageSet = false
        self.startFromNorth = -1.0
        locationManager!.stageOne = true
        self.verifyButton = VerifyButton()
        addGroupButton!.removeFromSuperview()
        addressButton!.removeFromSuperview()
        addButton!.removeFromSuperview()
    }
    
    //<- Recalibrate Stuff
    
    func removeScreens() {
        if(groupScreen != nil) {
            groupScreen!.removeFromSuperview()
        }
    }
    
    
    
}

