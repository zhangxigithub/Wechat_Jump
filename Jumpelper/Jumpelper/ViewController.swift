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
    }
    
    func didDisconnected() {
        print("didDisconnected")
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
        
        let value = Int(sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1)))
        
        let op = String(format:"m%4d#",value)
        robot.send(message: op)
    }
    
    @IBAction func connect(_ sender: Any) {
        robot = EngraveRobot()
        robot.delegate = self
        robot.connect()
    }
    
    @IBAction func test(_ sender: Any) {
        
        self.preview?.getImage()
    
//        let i = preview?.snapshot
//
//        guard let rep = preview?.bitmapImageRepForCachingDisplay(in: preview!.bounds) else{return}
//
//        let w        = rep.pixelsWide
//        let h        = rep.pixelsHigh
//        let rowBytes = rep.bytesPerRow
//        var bitmapByteCount = (rowBytes * h)
//
//        var pixel_value: Int = 0
//        let color = rep.colorAt(x: 10, y: 10)
//
//
//        var pixel = rep.bitmapData!
//        //print(rep.bitmapData)
//
//        for row in 720..<h
//        {
//            for x in 0..<w
//            {
//                let offset = 4 * x * row
//                print(pixel[offset])
//            }
//        }
//
//        print("w:\(w),h:\(h)  \(color)")
//
        /*
         int width = [imageRep pixelsWide];
         int height = [imageRep pixelsHight];
         int rowBytes = [imageRep bytesPerRow];
         char* pixels = [imageRep bitmapData];
         int row, col;
         for (row = 0; row < height; row++)
         {
         unsigned char* rowStart = (unsigned char*)(pixels + (row * rowBytes));
         unsigned char* nextChannel = rowStart;
         for (col = 0; col < width; col++)
         {
         unsigned char red, green, blue, alpha;
         
         red = *nextChannel;
         nextChannel++;
         green = *nextChannel;
         nextChannel++;
         // ...etc...
         }
         }
         
         
         let viewToCapture = self.window!.contentView!
         let rep = viewToCapture.bitmapImageRepForCachingDisplayInRect(viewToCapture.bounds)!
         viewToCapture.cacheDisplayInRect(viewToCapture.bounds, toBitmapImageRep: rep)
         
         let img = NSImage(size: viewToCapture.bounds.size)
         img.addRepresentation(rep)
         */
    }
    
    @IBAction func step(_ sender: Any) {
        
        robot.send(message: "m1000#")
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
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
//        if originPosition != nil && targetPosition != nil
//        {
//            let figure = NSBezierPath() // container for line(s)
//            figure.move(to: originPosition!) // start point
//            figure.line(to: targetPosition!) // destination
//            figure.lineWidth = 5  // hair line
//            figure.stroke()  // draw line(s) in color
//        }
    }
    override func mouseDown(with event: NSEvent) {
        
        var p = event.locationInWindow
        p.x *= 3
        p.y *= 3
        addPoint(color: NSColor.red, point: p)
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
        if let buffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) //as? CVPixelBuffer
        {

        
            
        }
        
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