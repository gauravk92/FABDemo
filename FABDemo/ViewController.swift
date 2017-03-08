//
//  ViewController.swift
//  FABDemo
//
//  Created by Gaurav Khanna on 4/27/15.
//  Copyright (c) 2015 Gaurav Khanna. All rights reserved.
//

import UIKit
import ObjectiveC


//infix operator ** { associativity left precedence 160 }
//func ** (left: Double, right: Double) -> Double {
//    return pow(left, right)
//}
//
//infix operator += { associativity right precedence 90 }
//func += (inout left: Double, right: Double) {
//    left = left ** right
//}

//infix operator = { associativity left precedence 160 }
//func = (left: Double, right: Double) -> Double {
//    return pow(left, right)
//}
//



open class TestLayer: CALayer {
    
    override open func preferredFrameSize() -> CGSize {
        return CGSize(width: 200, height: 200)
    }
}

open class TestView: UIView {
    open let testLayer = TestLayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.green
        
//        testLayer.contentHugging = 750
//        let x = testLayer.contentHugging
//        NSLog("%i", x)
        
        //self.layer.anchorPoint = CGPointMake(0.5, 0.5)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        let ctx = UIGraphicsGetCurrentContext()
        
        let locs: [CGFloat] = [0.0, 1.0]
        let colors: [CGColor] = [UIColor.white.cgColor, UIColor.clear.cgColor]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: locs)
        ctx?.drawLinearGradient(gradient!, start: CGPoint.zero, end: CGPoint(x: 100, y: 0), options: CGGradientDrawingOptions(0))
        
        let mask = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        testLayer.contents = mask.cgImage
        
        testLayer.backgroundColor = UIColor.red.cgColor
        //testLayer.anchorPoint = CGPointMake(0.0, 0.5)
        //testLayer.bounds.size = CGSizeMake(40, 40)
        //testLayer.position = CGPointMake(20, 20)
        testLayer.contentHugging = .required
        testLayer.right = self.layer.right - 20
        //testLayer.right = self.layer.right - 20
        //testLayer.right.equals(self.layer.right - 20)
        
        //testLayer.right = self.layer.left.Required
        //testLayer.left = self.layer.right.Required
        //testLayer.top.Required = self.layer.top + self.layer.right + 20
        //testLayer.left.Required = self.layer.right + 20
        //testLayer.right.priority = .Required
        
        
        //testLayer.contentsRect = CGRectMake(-1, 0, 1, 1)
        //testLayer.bounds = CGRectMake(20, 20, 40, 40)
        
        //testLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMakeScale(0.7, 1))
//        if CATransform3DEqualToTransform(testLayer.superlayer.sublayerTransform, CATransform3DIdentity) {
//            NSLog("yup")
//        }
        //testLayer.frame = CGRectMake(40, 40, 40, 40)
        
        
        
        self.layer.addSublayer(testLayer)
        
        
    }
    override open func layoutSubviews() {
        super.layoutSubviews()
        let start = Date.timeIntervalSinceReferenceDate
        testLayer.performLayout()
        let duration = Date.timeIntervalSinceReferenceDate - start;
        println("time \(duration)")
        let start1 = Date.timeIntervalSinceReferenceDate
        testLayer.performLayout()
        let duration1 = Date.timeIntervalSinceReferenceDate - start1;
        println("time \(duration1)")
        let start2 = Date.timeIntervalSinceReferenceDate
        testLayer.performLayout()
        let duration2 = Date.timeIntervalSinceReferenceDate - start2;
        println("time \(duration2)")
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
}

open class ViewController: UIViewController {
    open let testView = TestView()
    let debugLabel = UILabel()
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    //let fab = FABView(frame: CGRectZero)
    //self.view.addSubview(fab)
        //self.view.backgroundColor = UIColor.blackColor()
        
        testView.frame = CGRect(x: 20, y: 20, width: 300, height: 300)
        self.view.addSubview(testView)
        
        //debugLabel.frame = CGRectMake(10, 320, 300, 100)
        debugLabel.textColor = UIColor.black
        debugLabel.numberOfLines = 0
        self.view.addSubview(debugLabel)
        
    }

    override open func viewWillAppear(_ animated: Bool) {
        let layer = testView.testLayer
        
    }
    override open func viewDidAppear(_ animated: Bool) {
        let layer = testView.testLayer
        
        let cPoint = self.view.layer.convert(CGPoint.zero, from: self.testView.testLayer)
        let lPoint = self.view.layer.convert(CGPoint.zero, to: self.testView.testLayer)
        
        let cpPoint = self.view.layer.pointFromChild(self.testView.testLayer, P: CGPoint.zero)
        let lpPoint = self.view.layer.pointToChild(self.testView.testLayer, P: CGPoint.zero)
        
        let debugString = NSString(format: "bounds = %@\nframe = %@\nanchorPoint = %@\nposition = %@\nfromPoint = %@\ntoPoint = %@\nfromP = %@\ntoP = %@", NSStringFromCGRect(layer.bounds), NSStringFromCGRect(layer.frame), NSStringFromCGPoint(layer.anchorPoint), NSStringFromCGPoint(layer.position), NSStringFromCGPoint(cPoint), NSStringFromCGPoint(lPoint), NSStringFromCGPoint(cpPoint), NSStringFromCGPoint(lpPoint))
        debugLabel.text = debugString as String
        
        debugLabel.sizeToFit()
        debugLabel.frame.origin = CGPoint(x: 20, y: 340)
        
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}



