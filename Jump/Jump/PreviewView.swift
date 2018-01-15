//
//  PreviewView.swift
//  Jumpelper
//
//  Created by zhangxi on 15/01/2018.
//  Copyright © 2018 zhangxi. All rights reserved.
//

import Cocoa
import CoreMediaIO
import AVFoundation
import QuartzCore


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
    var originView : NSView?
    var targetView : NSView?
    
    
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
    func clear()
    {
        self.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        originPosition = nil
        targetPosition = nil
        originView = nil
        targetView = nil
    }
    func detect()
    {
        clear()
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
                        DispatchQueue.main.async {
                        self.originView = self.addPoint(color:NSColor.orange,point: self.originPosition!)
                        }
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
                        DispatchQueue.main.async {
                        self.addPoint(color:NSColor.blue,point: start!)
                        self.addPoint(color:NSColor.gray,point: CGPoint(x: x, y: 2436-(row+505)))
                        }
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
                                DispatchQueue.main.async {
                                    self.addPoint(color:NSColor.green,point: end!)
                                }
                                
                                let point = CGPoint(x: end!.x, y: end!.y+(start!.y-end!.y)/2)
                                DispatchQueue.main.async {
                                   self.targetView = self.addPoint(color:NSColor.red,point: point)
                                }
                                self.targetPosition = point
                                return
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    override func mouseDown(with event: NSEvent) {
        
        self.targetView?.removeFromSuperview()
        
        var p = event.locationInWindow
        p.x *= 3
        p.y *= 3
        self.targetView = addPoint(color: NSColor.red, point: p)
        
        targetPosition = p;
    }
    
    override func rightMouseDown(with event: NSEvent) {
        self.originView?.removeFromSuperview()
        
        var p = event.locationInWindow
        p.x *= 3
        p.y *= 3
        self.originView = addPoint(color: NSColor.orange, point: p)
        
        originPosition = p;
    }
    @discardableResult func addPoint(color:NSColor,point:CGPoint) -> NSView
    {
        let tip = NSView(frame: NSRect(x: point.x/3-5, y: point.y/3-5, width: 10, height: 10))
        tip.wantsLayer = true
        tip.layer?.backgroundColor = color.cgColor
        self.addSubview(tip)
        return tip
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
