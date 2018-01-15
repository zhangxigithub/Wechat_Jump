//
//  ViewController.swift
//  Jumpelper
//
//  Created by zhangxi on 03/01/2018.
//  Copyright © 2018 zhangxi. All rights reserved.
//

import Cocoa
import CoreMediaIO
import AVFoundation
import QuartzCore

class ViewController: NSViewController,EngraveRobotDelegate
{
    func didConnected() {
        print("didConnected")
        self.view.viewWithTag(1)?.isHidden = false
    }
    
    func didDisconnected() {
        print("didDisconnected")
        self.view.viewWithTag(1)?.isHidden = true
    }
    
    func didReceviveMessgae(message: String) {
        print(message)
    }
    
    var robot : EngraveRobot!
    var preview : PreviewView?

    @IBOutlet weak var slider: NSSlider!
    @IBOutlet weak var rate: NSTextField!
    
    
    @IBOutlet weak var testSlider: NSSlider!
    
    @IBOutlet weak var testLabel: NSTextField!
    
    
    @IBAction func testChange(_ sender: Any) {
        testLabel.stringValue = testSlider.stringValue
    }
    @IBAction func changed(_ sender: Any) {
        
        rate.stringValue = slider.stringValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testLabel.stringValue = testSlider.stringValue
        rate.stringValue = slider.stringValue
        
        
        var property = CMIOObjectPropertyAddress(mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyAllowScreenCaptureDevices), mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal), mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMaster))
        var allow : UInt32 = 1
        let sizeOfAllow = MemoryLayout<UInt32>.size
        CMIOObjectSetPropertyData(CMIOObjectID(kCMIOObjectSystemObject), &property, 0, nil, UInt32(sizeOfAllow), &allow)
        
        
        //robot = EngraveRobot()
        //robot.delegate = self
        //robot.connect()
        
    }

    override var representedObject: Any? {
        didSet {
        
        }
    }
    @IBAction func jump(_ sender: Any) {
        
        
        guard preview?.targetPosition != nil,preview?.originPosition != nil else {
            return
        }
        
        
        let x1 =  preview!.originPosition!.x
        let y1 =  preview!.originPosition!.y
        let x2 =  preview!.targetPosition!.x
        let y2 =  preview!.targetPosition!.y
        print(sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1)))
        
        let a = (x2-x1)*(x2-x1)+(y2-y1)*(y2-y1)
        let value = Int(sqrt(a) * CGFloat(slider.doubleValue))
        
        let op = String(format:"m%4d#",value)
        robot?.send(message: op)
        preview?.clear()
    }
    
    @IBAction func connect(_ sender: Any) {
        robot = EngraveRobot()
        robot.delegate = self
        robot.connect()
    }
    
    @IBAction func test(_ sender: Any) {
        self.preview?.detect()
    }
    
    @IBAction func step(_ sender: Any) {
        
        //robot?.send(message: "m1000#")
        
        let value = Int(CGFloat(testSlider.doubleValue*1000))
        
        let op = String(format:"m%4d#",value)
        robot?.send(message: op)
    }
    
    

    @IBAction func start(_ sender: Any) {
     
        preview?.removeFromSuperview()
        
        guard let device  = AVCaptureDevice.devices(for: .muxed).first else
        {
            return
        }
        
        //let h = self.view.bounds.size.height
        
        //1125px × 2436px
        //375 812
        preview = PreviewView(frame: NSRect(x: 0, y: 0, width: 375, height: 812), device: device)
        self.view.addSubview(preview!)
    }
    
}




