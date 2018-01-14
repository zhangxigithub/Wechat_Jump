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

    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        
        
        print(preview?.targetPosition)
        print(preview?.originPosition)
        
        
        let x1 =  preview!.originPosition!.x
        let y1 =  preview!.originPosition!.y
        let x2 =  preview!.targetPosition!.x
        let y2 =  preview!.targetPosition!.y
        print(sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1)))
        
        let value = Int(sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1)) * 1.2)
        
        let op = String(format:"m%4d#",value)
        robot?.send(message: op)
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
        
        robot?.send(message: "m1000#")
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




class PreviewView : NSView , AVCaptureVideoDataOutputSampleBufferDelegate
{
    var session : AVCaptureSession?
    var device  : AVCaptureDevice?
    var input   : AVCaptureDeviceInput?
    var output  : AVCaptureVideoDataOutput?
    var preview : AVCaptureVideoPreviewLayer?
    var imageOutput : AVCaptureStillImageOutput!
    
    
    var originPosition : CGPoint?
    var targetPosition : CGPoint?
    
    
    init(frame frameRect: NSRect,device:AVCaptureDevice) {
        super.init(frame: frameRect)
        self.wantsLayer = true

        session = AVCaptureSession()
        do {
            try input = AVCaptureDeviceInput(device: device)
            session?.addInput(input!)
        }catch{
            
        }
        
        output = AVCaptureVideoDataOutput()
        output?.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        
        session?.addOutput(output!)
        
        imageOutput = AVCaptureStillImageOutput()
        session?.addOutput(imageOutput)
        
        
        
        preview = AVCaptureVideoPreviewLayer(session: session!)
        preview!.frame.size = self.frame.size
        preview!.videoGravity = .resizeAspectFill
        
        self.layer?.addSublayer(preview!)
        
        session?.startRunning()

        self.becomeFirstResponder()
    }
    func detect()
    {
        self.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        imageOutput.captureStillImageAsynchronously(from: self.imageOutput.connection(with: .video)!) { (buffer, error) in
            
            guard buffer != nil else{return}
            
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer!)
            let image = NSImage(data: imageData!)
            
            guard let rep = NSBitmapImageRep(data: imageData!) else{return}
            
            print("w:\(rep.pixelsWide),y:\(rep.pixelsHigh) ,size:\(rep.size)")
            
            let w = rep.pixelsWide
            let h = rep.pixelsHigh
            
            var start  : CGPoint?
            var end    : CGPoint?
            var target : CGPoint? = nil//67,58,98   0.2627 0.2275  0.3843
            
            
            //detect piece
            for r in 550 ..< h
            {
                let row = 2436-r
                for x in 1 ..< w
                {
                    if rep.isTarget(x: x, y: row) && (target == nil)
                    {
                        self.originPosition = CGPoint(x: x, y: 2436-(row+5))
                        target = self.originPosition
                        self.addPoint(color:NSColor.orange,point: self.originPosition!)
                        break
                    }
                }
            }

            
            for row in 550 ..< h
            {
                var startColor = rep.colorAt(x: 0, y: row)
                for x in 1 ..< w
                {
                    let color = rep.colorAt(x: x, y: row)
                    if (color?.different(with: startColor!))!
                    {//上顶点，往下走500px向上检测
                        start = CGPoint(x: x, y: 2436-(row+5))
                        startColor = rep.colorAt(x: x, y: row+505)!
                        self.addPoint(color:NSColor.blue,point: start!)
                        self.addPoint(color:NSColor.gray,point: CGPoint(x: x, y: 2436-(row+505)))
                        for yy in 1 ..< (row+505)
                        {
                            let y = (row+505) - yy
                            let color = rep.colorAt(x: x, y: y)!
                            let edge = startColor!.different(with: color)
                            //self.addPoint(color:NSColor.gray,point: CGPoint(x: x, y: 2436-(y)))
                                //&& startColor!.different(with: rep.colorAt(x: x, y: y+25)!)
                            if (edge)
                            {
                                end = CGPoint(x: x, y: 2436-(y-153+5))
                                self.addPoint(color:NSColor.green,point: end!)
                                
                                let point = CGPoint(x: end!.x, y: end!.y+(start!.y-end!.y)/2)
                                self.addPoint(color:NSColor.red,point: point)
                                self.targetPosition = point
                                return
                            }
                        }
                    }
                }
            }
        }

    }
    /*
    func getImage()
    {
        self.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        imageOutput.captureStillImageAsynchronously(from: self.imageOutput.connection(with: .video)!) { (buffer, error) in
            
            if buffer == nil
            {
                print(error)
                return
            }
            
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer!)
            let image = NSImage(data: imageData!)
            
            guard let rep = NSBitmapImageRep(data: imageData!) else{return}
           
            print("w:\(rep.pixelsWide),y:\(rep.pixelsHigh)")
            //w:Optional(1126),y:Optional(2436)
            
            print(rep.size)
            //print(rep.colorAt(x: 10, y: 10))
            //let c1 = rep.colorAt(x: 884, y: 1513)
            //let c2 = rep.colorAt(x: 418, y: 901)
            
            let w = rep.pixelsWide
            let h = rep.pixelsHigh
            
            var start : CGPoint?
            var end : CGPoint?
            var target : CGPoint? = nil//67,58,98   0.2627 0.2275  0.3843
            
            
            for r in 550 ..< h
            {
                let row = 2436-r
                for x in 1 ..< w
                {
                    let color = rep.colorAt(x: x, y: row)!
                    if (fabsf(Float(color.redComponent)-0.2627) < 0.05) &&
                       (fabsf(Float(color.greenComponent)-0.2275) < 0.05) &&
                       (fabsf(Float(color.blueComponent)-0.3843) < 0.05) &&
                       (target == nil)
                    {
                        target = CGPoint(x: x, y: 2436-(row+5))
                        self.originPosition = target
                        self.addPoint(color:NSColor.orange,point: target!)
                        break;
                    }

                }
            }
            
            for row in 550 ..< h
            {
                var startColor = rep.colorAt(x: 0, y: row)
                for x in 1 ..< w
                {
                    let color = rep.colorAt(x: x, y: row)
                    if (color?.different(with: startColor!))!
                    {
                        print("start in \(x/3),\(row/3)")
                        start = CGPoint(x: x, y: 2436-(row+5))
                        startColor = rep.colorAt(x: x, y: row+5)!
                        self.addPoint(color:NSColor.blue,point: start!)
                        
                        for y in row+5 ..< h
                        {
                            let color = rep.colorAt(x: x, y: y)!
                            
                            let edge = startColor!.different(with: color) &&
                                       startColor!.different(with: rep.colorAt(x: x, y: y+25)!)
                            if (edge)
                            {
                                end = CGPoint(x: x, y: 2436-y+5)
                                self.addPoint(color:NSColor.green,point: end!)
                                
                                let point = CGPoint(x: end!.x, y: end!.y+(start!.y-end!.y)/2)
                                self.addPoint(color:NSColor.red,point: point)
                                self.targetPosition = point
                                return
                            }
                        }
                    }
                }
            }
        }
        
        
        
        //self.setNeedsDisplay(self.bounds)
        //self.needsDisplay = true
    }
    */

    override func mouseDown(with event: NSEvent) {
        
        var p = event.locationInWindow
        p.x *= 3
        p.y *= 3
        addPoint(color: NSColor.red, point: p)
        
        targetPosition = p;
    }
    
    override func rightMouseDown(with event: NSEvent) {
        
        var p = event.locationInWindow
        p.x *= 3
        p.y *= 3
        addPoint(color: NSColor.orange, point: p)
        
        originPosition = p;
    }
    func addPoint(color:NSColor,point:CGPoint)
    {
        DispatchQueue.main.async {
            let tip = NSView(frame: NSRect(x: point.x/3-5, y: point.y/3-5, width: 10, height: 10))
            tip.wantsLayer = true
            tip.layer?.backgroundColor = color.cgColor
            self.addSubview(tip)
        }
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }

    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension NSView {
    var snapshot: NSImage {
        let bitmapRep = self.bitmapImageRepForCachingDisplay(in: bounds)!
        bitmapRep.size = bounds.size
        cacheDisplay(in: bounds, to: bitmapRep)
        let image = NSImage(size: bounds.size)
        image.addRepresentation(bitmapRep)
        return image
    }
}
extension NSColor
{
    func different(with color:NSColor) -> Bool
    {
        return (fabsf(Float(self.redComponent - color.redComponent)) +
            fabsf(Float(self.greenComponent - color.greenComponent)) +
            fabsf(Float(self.blueComponent - color.blueComponent))) > 0.15
    }
}
extension NSBitmapImageRep
{
    func isTarget(x:Int,y:Int)  -> Bool
    {
        let color = self.colorAt(x: x, y: y)!
        return (fabsf(Float(color.redComponent)-0.2627) < 0.05) &&
        (fabsf(Float(color.greenComponent)-0.2275) < 0.05) &&
        (fabsf(Float(color.blueComponent)-0.3843) < 0.05)
    }
    
    func different(x1:Int,y1:Int,x2:Int,y2:Int)  -> Bool
    {
        let c1 = self.colorAt(x: x1, y: y1)!
        let c2 = self.colorAt(x: x2, y: y2)!
        return c1.different(with: c2)
    }
    func isWhiteTarget(x:Int,y:Int)  -> Bool
    {
        let color = self.colorAt(x: x, y: y)!
        return (fabsf(Float(color.redComponent)-0.96) < 0.01) &&
            (fabsf(Float(color.greenComponent)-0.96) < 0.01) &&
            (fabsf(Float(color.blueComponent)-0.96) < 0.01)
    }
}
