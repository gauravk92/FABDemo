//
//  FABDemoTests.swift
//  FABDemoTests
//
//  Created by Gaurav Khanna on 4/27/15.
//  Copyright (c) 2015 Gaurav Khanna. All rights reserved.
//

import UIKit
import XCTest

var controller:ViewController?

class FABDemoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
//        let layer = CALayer()
//        layer.backgroundColor = UIColor.redColor().CGColor
//        layer.bounds = CGRectMake(100, 100, 120, 120)
        controller = ViewController()
        UIApplication.shared.keyWindow?.rootViewController = controller
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        UIApplication.shared.keyWindow?.rootViewController = nil
        
        
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(controller != nil, "Pass")
        
        controller?.testView.testLayer.right = controller?.testView.layer.right + 20
        
        controller?.testView.testLayer.setNeedsLayout()
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock() {
//            // Put the code you want to measure the time of here.
//            for (var i = 0;i<1000;i++) {
//                let z = cgfsum(0.0, 1.0)
//            }
//        }
//    }
//    
//    func testPerformanceExample2() {
//        // This is an example of a performance test case.
//        self.measureBlock() {
//            // Put the code you want to measure the time of here.
//            for (var i = 0;i<1000;i++) {
//                let x:CGFloat = 0.0
//                let y:CGFloat = 1.0
//                let z = x + y
//            }
//        }
//    }
    
}
