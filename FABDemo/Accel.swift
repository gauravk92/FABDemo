//
//  Accel.swift
//  FABDemo
//
//  Created by Gaurav Khanna on 5/14/15.
//  Copyright (c) 2015 Gaurav Khanna. All rights reserved.
//

import Foundation
import UIKit
import Accelerate

private let AccelCGFloatNativeType = CGFloat.NativeType() == Double()

public func cgfsum(_ lhs: CGFloat, rhs: CGFloat) -> CGFloat {
    //if AccelCGFloatNativeType {
        var results:[Double] = [Double(rhs)]
        let x:[Double] = [Double(lhs)]
        cblas_daxpy(Int32(x.count), 1.0, x, 1, &results, 1)

        return CGFloat(results[0])
   // } else {
        let result: CGFloat = 0.0
        //vDSP_sve(lhs, 1, &result, vDSP_Length(lhs.count))
        
        return result
  //  }
    //return nil
}
//
//public func sum(x: [Float]) -> Float {
//    var result: Float = 0.0
//    vDSP_sve(x, 1, &result, vDSP_Length(x.count))
//    
//    return result
//}
//
//public func sum(x: [Double]) -> Double {
//    var result: Double = 0.0
//    vDSP_sveD(x, 1, &result, vDSP_Length(x.count))
//    
//    return result
//}



//
//public func add(x: [Float], y: [Float]) -> [Float] {
//    var results = [Float](y)
//    cblas_saxpy(Int32(x.count), 1.0, x, 1, &results, 1)
//    
//    return results
//}
//
//public func add(x: [Double], y: [Double]) -> [Double] {
//    var results = [Double](y)
//    cblas_daxpy(Int32(x.count), 1.0, x, 1, &results, 1)
//    
//    return results
//}
