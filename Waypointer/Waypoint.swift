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
    public var orderNum = 0
    var background = CAShapeLayer()
    var circle = CAShapeLayer()
    var rightArrowShape = CAShapeLayer()
    var leftArrowShape = CAShapeLayer()
    
    public init(xPos : Double, yPos : Double, zPos : Double, red : Int, green : Int, blue : Int, name : String) {
        self.red = red
        self.name = name
        self.blue = blue
        self.green = green
        self.line = Line(startingXPos: classes.manage.personX, startingYPos: classes.manage.personY, startingZPos: classes.manage.personZ, endingXPos: xPos, endingYPos: yPos, endingZPos: zPos)
        super.init(frame : CGRect(x: 0, y: 0, width: 20, height: 20))
        self.drawText()
        self.initGraphics()
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func drawRect(rect: CGRect) {
        var yShift = Double(orderNum * 10)
        if(x > classes.screenWidth) {
            stringDraw.removeFromSuperview()
            drawRightArrow(yShift)
            return
        } else if(x < 0) {
            stringDraw.removeFromSuperview()
            drawLeftArrow(yShift)
            return
        }
        drawBackground()
        drawCircle()
        self.addSubview(stringDraw)
        updateText()
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.frame = CGRect(x: x, y: y - yShift, width: 50, height: 50)
    }
    
    public func updatePersonPossition() {
        self.line = Line(startingXPos: classes.manage.personX, startingYPos: classes.manage.personY, startingZPos: classes.manage.personZ, endingXPos: line.end.xPos, endingYPos: line.end.yPos, endingZPos: line.end.zPos)
        drawRect(CGRect(x: 0, y: 0, width: 300, height: 300))
    }
    
    public func updateDistance() {
        line = Line(startingXPos: classes.manage.personX, startingYPos: classes.manage.personY, startingZPos: classes.manage.personZ, endingXPos: line.end.xPos, endingYPos: line.end.yPos, endingZPos: line.end.zPos)
    }
    
    public func getScreenX() -> Double {
        var x1 = CGFloat(classes.manage.horAngle - MyMath.findSmallestAngle(classes.startFromNorth))
        var realFOV = classes.cameraAngle * (classes.screenWidth / classes.screenHeight)
        var horAngle = line.getLineHorizontalAngle()
        horAngle = (horAngle + Double(x1))
        horAngle = MyMath.findSmallestAngle(horAngle)
        var perInstanceIncrease = Double(classes.cameraAngle) * (classes.screenWidth / classes.screenHeight) / classes.screenWidth
        return (horAngle + realFOV) / (perInstanceIncrease)
    }
    
    public func getScreenY() -> Double {
        var y1 = CGFloat(-classes.manage.vertAngle)
        var vertAngle = line.getLineVerticalAngle()
        vertAngle = vertAngle + Double(y1)
        vertAngle = MyMath.findSmallestAngle(vertAngle)
        var perInstanceIncrease = Double(classes.cameraAngle) / classes.screenHeight
        return (-vertAngle + classes.cameraAngle) / (perInstanceIncrease)
    }
    
    public func getScreenScaller() -> Double {
        var length = line.length
        var multiplier = 0.00005
        var scaler : Double
        scaler = 1 - (length * multiplier)
        if(scaler < 0.2) {
            scaler = 0.2
        }
        return scaler
    }
    
    //Different Graphic Stuff From Here Down
    
    public func generateVars() {
        x = getScreenX()
        y = getScreenY()
        scaler = getScreenScaller()
        xWidth = (20 * scaler)
        yWidth = (70 * scaler)
        circleDiameter = ((xWidth / 2.5))
    }
    
    func drawText() {
        stringDraw = UILabel(frame: CGRect(x: CGFloat(-Double(count(name)) * 1.7), y: CGFloat(-yWidth - 17), width: 50, height: 20))
        stringDraw.text = name
        stringDraw.font = UIFont(name: "Times New Roman", size: CGFloat(6))
        self.addSubview(stringDraw)
    }
    
    func updateText() {
        stringDraw.frame = CGRect(x: CGFloat(-Double(count(name)) * 1.7), y: CGFloat(-yWidth - 17), width: 50, height: 20)
    }
    
    func initGraphics() {
        leftArrowShape = CAShapeLayer()
        leftArrowShape.opacity = 1
        leftArrowShape.lineWidth = 2
        leftArrowShape.lineJoin = kCALineJoinMiter
        leftArrowShape.fillColor = UIColor(red: CGFloat(Double(red)/255.0), green: CGFloat(Double(green)/255.0), blue: CGFloat(Double(blue)/255.0), alpha: CGFloat(classes.waypointTransparency)).CGColor
        rightArrowShape = CAShapeLayer()
        rightArrowShape.opacity = 1
        rightArrowShape.lineWidth = 2
        rightArrowShape.lineJoin = kCALineJoinMiter
        rightArrowShape.fillColor = UIColor(red: CGFloat(Double(red)/255.0), green: CGFloat(Double(green)/255.0), blue: CGFloat(Double(blue)/255.0), alpha: CGFloat(classes.waypointTransparency)).CGColor
        background = CAShapeLayer()
        background.opacity = 1
        background.lineJoin = kCALineJoinMiter
        background.strokeColor = UIColor.blackColor().CGColor
        background.lineWidth = 1
        background.fillColor = UIColor(red: CGFloat(Double(red)/255.0), green: CGFloat(Double(green)/255.0), blue: CGFloat(Double(blue)/255.0), alpha: CGFloat(classes.waypointTransparency)).CGColor
        circle = CAShapeLayer()
        circle.opacity = 1
        circle.lineWidth = 1
        circle.strokeColor = UIColor.blackColor().CGColor
        circle.lineJoin = kCALineJoinMiter
        circle.fillColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: CGFloat(classes.waypointTransparency)).CGColor
    }
    
    func drawLeftArrow(yShift : Double) {
        x = 0
        var arrowWidth = 80 * scaler
        var arrowHeight = yWidth/3
        var middleWidth = 10.0
        self.layer.addSublayer(leftArrowShape)
        rightArrowShape.removeFromSuperlayer()
        background.removeFromSuperlayer()
        circle.removeFromSuperlayer()
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(CGFloat(0), CGFloat(0)))
        path.addLineToPoint(CGPointMake(CGFloat(arrowWidth/3), CGFloat(arrowHeight)))
        path.addLineToPoint(CGPointMake(CGFloat(arrowWidth/3), CGFloat(middleWidth * scaler)))
        path.addLineToPoint(CGPointMake(CGFloat(arrowWidth), CGFloat(middleWidth * scaler)))
        path.addLineToPoint(CGPointMake(CGFloat(arrowWidth), CGFloat(-middleWidth * scaler)))
        path.addLineToPoint(CGPointMake(CGFloat(arrowWidth/3), CGFloat(-middleWidth * scaler)))
        path.addLineToPoint(CGPointMake(CGFloat(arrowWidth/3), CGFloat(-arrowHeight)))
        path.closePath()
        leftArrowShape.path = path.CGPath
        self.frame = CGRect(x: x, y: y - yShift, width: 50, height: 50)
    }
    
    func drawRightArrow(yShift : Double) {
        x = classes.screenWidth
        var arrowWidth = -80 * scaler
        var arrowHeight = yWidth/3
        var middleWidth = 10.0
        self.layer.addSublayer(rightArrowShape)
        leftArrowShape.removeFromSuperlayer()
        background.removeFromSuperlayer()
        circle.removeFromSuperlayer()
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(CGFloat(0), CGFloat(0)))
        path.addLineToPoint(CGPointMake(CGFloat(arrowWidth/3), CGFloat(arrowHeight)))
        path.addLineToPoint(CGPointMake(CGFloat(arrowWidth/3), CGFloat(middleWidth * scaler)))
        path.addLineToPoint(CGPointMake(CGFloat(arrowWidth), CGFloat(middleWidth * scaler)))
        path.addLineToPoint(CGPointMake(CGFloat(arrowWidth), CGFloat(-middleWidth * scaler)))
        path.addLineToPoint(CGPointMake(CGFloat(arrowWidth/3), CGFloat(-middleWidth * scaler)))
        path.addLineToPoint(CGPointMake(CGFloat(arrowWidth/3), CGFloat(-arrowHeight)))
        path.closePath()
        rightArrowShape.path = path.CGPath
        self.frame = CGRect(x: x, y: y - yShift, width: 50, height: 50)
    }
    
    public func drawBackground() {
        self.layer.addSublayer(background)
        rightArrowShape.removeFromSuperlayer()
        leftArrowShape.removeFromSuperlayer()
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(CGFloat(0), CGFloat(0)))
        path.addLineToPoint(CGPointMake(CGFloat(xWidth/2), CGFloat(-yWidth * 13/24)))
        path.addLineToPoint(CGPointMake(CGFloat(xWidth * 5 / 4), CGFloat(-yWidth * 17/24)))
        path.addLineToPoint(CGPointMake(CGFloat(xWidth/2), CGFloat(-yWidth * 17/24)))
        path.addLineToPoint(CGPointMake(CGFloat(0), CGFloat(-yWidth)))
        path.addLineToPoint(CGPointMake(CGFloat(-xWidth/2), CGFloat(-yWidth * 17/24)))
        path.addLineToPoint(CGPointMake(CGFloat(-xWidth * 5 / 4), CGFloat(-yWidth * 17/24)))
        path.addLineToPoint(CGPointMake(CGFloat(-xWidth/2), CGFloat(-yWidth * 13/24)))
        path.closePath()
        background.path = path.CGPath
    }
    
    func drawCircle() {
        self.layer.addSublayer(circle)
        rightArrowShape.removeFromSuperlayer()
        leftArrowShape.removeFromSuperlayer()
        var ovalPath = UIBezierPath(ovalInRect: CGRectMake(CGFloat(-circleDiameter/2), CGFloat(-yWidth * 16/24 - circleDiameter/2), CGFloat(circleDiameter), CGFloat(circleDiameter)))
        ovalPath.closePath()
        circle.path = ovalPath.CGPath
    }
    
}
