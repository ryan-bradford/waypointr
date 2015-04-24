//
//  Waypoint.swift
//  Waypointer
//
//  Created by Ryan on 4/20/15.
//  Copyright (c) 2015 Ryan. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

public class Waypoint : UIView {
    
    public var line  = Line(startingXPos: 1.0, startingYPos: 1.0, startingZPos: 1.0, endingXPos: 1.0, endingYPos: 1.0, endingZPos: 1.0)
    public var red = 0, blue = 0, green = 0
    public var name = ""
    public var added = false
    var stringDraw = UILabel()
    var xWidth : Double = 0.0
    var yWidth : Double = 0.0
    var x : Double = 0.0
    var y : Double = 0.0
    var scaler : Double = 0.0
    var circleDiameter : Double = 0.0
    
    required public init(xPos : Double, yPos : Double, zPos : Double, red : Int, green : Int, blue : Int, name : String) {
        self.line = Line(startingXPos: 1.0, startingYPos: 1.0, startingZPos: 1.0, endingXPos: 1.0, endingYPos: 1.0, endingZPos: 1.0)
        self.red = red
        self.name = name
        self.blue = blue
        self.green = green
        stringDraw = UILabel()
        self.line = Line(startingXPos: classes.manage.personX, startingYPos: classes.manage.personY, startingZPos: classes.manage.personZ, endingXPos: xPos, endingYPos: yPos, endingZPos: zPos)
        super.init(frame : CGRect(x: 0, y: 0, width: 20, height: 20))
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func drawRect(rect: CGRect) {
        generateVars()
        removeAllGraphics()
        var yShift = 40/scaler
        self.frame = CGRect(x: x  - xWidth / 2, y: y - circleDiameter - yShift, width: 50, height: 50)
        if(x > classes.screenWidth && y - yShift > classes.screenHeight) {
            return
        } else if(x > classes.screenWidth && y - yShift < 0) {
            return
        } else if(x < 0 && y - yShift < 0) {
            return
        } else if(x < 0 && y - yShift > classes.screenHeight) {
            return
        } else if(x > classes.screenWidth) {
            //drawRightArrow()
            return
        } else if(x < 0) {
            //drawLeftArrow()
            return
        } else if(y - yShift > classes.screenHeight) {
            return
        } else if(y - yShift < 0) {
            return
        }
        addPolygon()
        addOuterOval()
        addInnerOval()
        drawText()
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    }
    
    public func updatePersonPossition() {
        self.line = Line(startingXPos: classes.manage.personX, startingYPos: classes.manage.personY, startingZPos: classes.manage.personZ, endingXPos: line.end.xPos, endingYPos: line.end.yPos, endingZPos: line.end.zPos)
        drawRect(CGRect(x: 0, y: 0, width: 300, height: 300))
    }
    
    public func updateDistance() {
        line = Line(startingXPos: classes.manage.personX, startingYPos: classes.manage.personY, startingZPos: classes.manage.personZ, endingXPos: line.end.xPos, endingYPos: line.end.yPos, endingZPos: line.end.zPos)
    }
    
    public func getScreenX() -> Double {
        var x1 = CGFloat(classes.startFromNorth)
        if let attitude = classes.motionManager.deviceMotion?.attitude {
            x1 = CGFloat(-attitude.pitch - classes.startFromNorth)
        }
        var realAngle = classes.cameraAngle * (classes.screenWidth / classes.screenHeight)
        var horAngle = MyMath.getLineHorizontalAngle(line)
        horAngle = (horAngle + Double(x1))
        horAngle = MyMath.findSmallestAngle(horAngle)
        var perInstanceIncrease = Double(classes.cameraAngle) * (classes.screenWidth / classes.screenHeight) / classes.screenWidth
        return (horAngle + realAngle) / (perInstanceIncrease * 2)
    }
    
    public func getScreenY() -> Double {
        var y1 = CGFloat(0)
        if let attitude = classes.motionManager.deviceMotion?.attitude {
            y1 = CGFloat(-attitude.yaw)
        }
        var vertAngle = MyMath.getLineVerticalAngle(line)
        vertAngle = vertAngle + Double(y1)
        vertAngle = MyMath.findSmallestAngle(vertAngle)
        var perInstanceIncrease = Double(classes.cameraAngle) / classes.screenHeight
        //return -vertAngle / perInstanceIncrease + classes.cameraAngle
        //return -((vertAngle - classes.cameraAngle) / (perInstanceIncrease * 2))
        return classes.screenHeight - (vertAngle + classes.cameraAngle) / (perInstanceIncrease * 2)
    }
    
    public func getScreenScaller() -> Double {
        var length = line.length
        var multiplier = 0.0005
        var scaler : Double
        scaler = 1 - (length * multiplier)
        if(scaler < 0.3) {
            scaler = 1 - (length * 0.0001) - 0.24
        }
        if(scaler < 0.1) {
            scaler = 0.1
        }
        return scaler / 1.5
    }
    
    //Different Graphic Stuff From Here Down
    
    func removeAllGraphics() {
        if(self.layer.sublayers != nil) {
            for v in self.layer.sublayers {
                v.removeFromSuperlayer()
            }
        }
    }
    
    func generateVars() {
        x = getScreenX()
        y = getScreenY()
        scaler = getScreenScaller()
        xWidth = (20 * scaler)
        yWidth = (70 * scaler)
        circleDiameter = ((xWidth * 2))
    }
    
    func addPolygon() {
        let shape = CAShapeLayer()
        self.layer.addSublayer(shape)
        shape.opacity = 1
        shape.lineWidth = 2
        shape.lineJoin = kCALineJoinMiter
        shape.fillColor = UIColor(red: CGFloat(Double(red)/255.0), green: CGFloat(Double(green)/255.0), blue: CGFloat(Double(blue)/255.0), alpha: CGFloat(classes.waypointTransparency)).CGColor
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(CGFloat(0), CGFloat(circleDiameter)))
        path.addLineToPoint(CGPointMake(CGFloat(xWidth), CGFloat(circleDiameter + yWidth)))
        path.addLineToPoint(CGPointMake(CGFloat(xWidth * 2), CGFloat(circleDiameter)))
        path.closePath()
        shape.path = path.CGPath
    }
    
    func addOuterOval() {
        let circle = CAShapeLayer() //Draw Outer Oval
        self.layer.addSublayer(circle)
        circle.opacity = 1
        circle.lineWidth = 2
        circle.lineJoin = kCALineJoinMiter
        circle.fillColor = UIColor(red: CGFloat(Double(red)/255.0), green: CGFloat(Double(green)/255.0), blue: CGFloat(Double(blue)/255.0), alpha: CGFloat(classes.waypointTransparency)).CGColor
        var ovalPath = UIBezierPath(ovalInRect: CGRectMake(CGFloat(0), CGFloat((((circleDiameter / 2)))), CGFloat(circleDiameter), CGFloat(circleDiameter)))
        ovalPath.closePath()
        circle.path = ovalPath.CGPath
    }
    
    func addInnerOval() {
        let frontCircle = CAShapeLayer() //Draw Inner Oval
        self.layer.addSublayer(frontCircle)
        frontCircle.opacity = 1
        frontCircle.lineWidth = 2
        frontCircle.lineJoin = kCALineJoinMiter
        frontCircle.fillColor = UIColor(red: CGFloat(255.0/255.0), green: CGFloat(255.0/255.0), blue: CGFloat(255.0/255.0), alpha: CGFloat(1.0)).CGColor
        var newOvalPath = UIBezierPath(ovalInRect: CGRectMake(CGFloat(circleDiameter / 4), CGFloat(circleDiameter * 3 / 4), CGFloat(circleDiameter / 2), CGFloat(circleDiameter / 2)))
        newOvalPath.closePath()
        frontCircle.path = newOvalPath.CGPath
    }
    
    func drawText() {
        let text = name as NSString
        let font = UIFont(name: "Times New Roman", size: CGFloat(6))
        let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.Center
        if let actualFont = font {
            let textFontAttributes = [
                NSFontAttributeName: actualFont,
                NSParagraphStyleAttributeName: textStyle
            ]
            
            text.drawAtPoint(CGPoint(x: CGFloat(xWidth - Double(count(name)) * 1.7) + 2, y: CGFloat(4.0 * scaler)), withAttributes: textFontAttributes)
        }
    }
    
    func drawLeftArrow() {
        var arrowWidth = 60 * scaler
        var arrowHeight = yWidth/4
        var middleWidth = 6.0
        let shape = CAShapeLayer()
        self.layer.addSublayer(shape)
        shape.opacity = 1
        shape.lineWidth = 2
        shape.lineJoin = kCALineJoinMiter
        shape.fillColor = UIColor(red: CGFloat(Double(red)/255.0), green: CGFloat(Double(green)/255.0), blue: CGFloat(Double(blue)/255.0), alpha: CGFloat(classes.waypointTransparency)).CGColor
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(CGFloat(0), CGFloat(0)))
        path.addLineToPoint(CGPointMake(CGFloat(arrowWidth/3), CGFloat(arrowHeight)))
        path.addLineToPoint(CGPointMake(CGFloat(arrowWidth/3), CGFloat(middleWidth * scaler)))
        path.addLineToPoint(CGPointMake(CGFloat(arrowWidth), CGFloat(middleWidth * scaler)))
        path.addLineToPoint(CGPointMake(CGFloat(arrowWidth), CGFloat(-middleWidth * scaler)))
        path.addLineToPoint(CGPointMake(CGFloat(arrowWidth/3), CGFloat(-middleWidth * scaler)))
        path.addLineToPoint(CGPointMake(CGFloat(arrowWidth/3), CGFloat(-arrowHeight)))
        path.closePath()
        shape.path = path.CGPath
        let text = name as NSString
        let font = UIFont(name: "Times New Roman", size: CGFloat(6))
        let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.Center
        if let actualFont = font {
            let textFontAttributes = [
                NSFontAttributeName: actualFont,
                NSParagraphStyleAttributeName: textStyle
            ]
            
            text.drawAtPoint(CGPoint(x: CGFloat(arrowWidth / 3 + 5), y: CGFloat(middleWidth + 0 * scaler)), withAttributes: textFontAttributes)
        }
    }
    
    func drawRightArrow() {
        var arrowWidth = -60 * scaler
        var arrowHeight = yWidth/4
        var middleWidth = 6.0
        let shape = CAShapeLayer()
        self.layer.addSublayer(shape)
        shape.opacity = 1
        shape.lineWidth = 2
        shape.lineJoin = kCALineJoinMiter
        shape.fillColor = UIColor(red: CGFloat(Double(red)/255.0), green: CGFloat(Double(green)/255.0), blue: CGFloat(Double(blue)/255.0), alpha: CGFloat(classes.waypointTransparency)).CGColor
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(CGFloat(-arrowWidth), CGFloat(arrowHeight)))
        path.addLineToPoint(CGPointMake(CGFloat(arrowWidth/3 - arrowWidth), CGFloat(2 * arrowHeight)))
        path.addLineToPoint(CGPointMake(CGFloat(arrowWidth/3 - arrowWidth), CGFloat(arrowHeight + middleWidth * scaler)))
        path.addLineToPoint(CGPointMake(CGFloat(0), CGFloat(arrowHeight + middleWidth * scaler)))
        path.addLineToPoint(CGPointMake(CGFloat(0), CGFloat(arrowHeight + -middleWidth * scaler)))
        path.addLineToPoint(CGPointMake(CGFloat(arrowWidth/3 - arrowWidth), CGFloat(arrowHeight + -middleWidth * scaler)))
        path.addLineToPoint(CGPointMake(CGFloat(arrowWidth/3 - arrowWidth), CGFloat(0)))
        path.closePath()
        shape.path = path.CGPath
        let text = name as NSString
        let font = UIFont(name: "Times New Roman", size: CGFloat(6))
        let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.Center
        if let actualFont = font {
            let textFontAttributes = [
                NSFontAttributeName: actualFont,
                NSParagraphStyleAttributeName: textStyle
            ]
            
            text.drawInRect(CGRect(x: CGFloat((arrowWidth / 3 + 3 * scaler)), y: CGFloat(middleWidth + 15 * scaler), width: 50, height: 50), withAttributes: textFontAttributes)
        }
    }
    
}
