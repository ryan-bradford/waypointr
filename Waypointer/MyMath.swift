//
//  MyMath.swift
//  Sidus
//
//  Created by Ryan on 4/20/15.
//  Copyright (c) 2015 Ryan. All rights reserved.
//

import Foundation
import Darwin

public class MyMath {
    
    var cameraAngle :Double
    
    public init(cameraAngle : Double) {
        self.cameraAngle = cameraAngle
    }
    
    func findSmallestAngle(angle : Double) -> Double {
        var calc = angle
        if(calc > M_PI - self.cameraAngle) {
            calc = calc -  M_PI * 2
            return findSmallestAngle(calc)
        } else if(calc < (-self.cameraAngle - M_PI)) {
            calc = calc + M_PI * 2
            return findSmallestAngle(calc)
        } else {
            return calc
        }
    }
    
    func degreesToFeet(angle : Double) -> Double {
        let kiloScaler = Double(10000/90)
        let kilos = angle * kiloScaler
        let feetScaler = 3280.84
        let feet = kilos * feetScaler
        return feet
    }
    
    func getMyAverage(nums : Array<Double>, placeToRoundTo : Double) -> Double {
        var heighestCount = 0.0
        var heighestID = 0.0
        var currentCount = 0.0
        var currentID = 0.0
        var currentID1 = 0.0
        for i in 0 ..< nums.count {
            currentCount = 0
            currentID = round(nums[i] / placeToRoundTo) * placeToRoundTo
            for x in 0 ..< nums.count {
                currentID1 = round(nums[x] / placeToRoundTo) * placeToRoundTo
                if(currentID == currentID1) {
                    currentCount += 1
                }
            }
            if(currentCount > heighestCount) {
                heighestCount = currentCount
                heighestID = currentID
            }
        }
        var total = 0.0
        for i in 0 ..< nums.count {
            currentID = round(nums[i] / placeToRoundTo) * placeToRoundTo
            if( currentID == heighestID) {
                total += nums[i]
            }
        }
        return total / heighestCount;
    }
    
    
}
