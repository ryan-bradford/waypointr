//
//  VerifyButton.swift
//  Waypointer
//
//  Created by Ryan on 4/20/15.
//  Copyright (c) 2015 Ryan. All rights reserved.
//

import Foundation
import UIKit

public class CannotRunScreen : UIView {
    
    var redVal = 1.0
    var blueVal = 1.0
    var alphaVal = 0.3
    
    public init() {
        super.init(frame: CGRectMake(0, 0, CGFloat(classes.screenWidth), CGFloat(classes.screenHeight)))
        self.backgroundColor = UIColor(red: CGFloat(redVal), green: 1, blue: CGFloat(blueVal), alpha: CGFloat(alphaVal))
    }
    
    override public func drawRect(rect: CGRect) {
        drawMessage("The Application Could Not Launch", X: 0, Y: CGFloat(classes.screenHeight / 2.0) - 30.0)
        
    }
    
    func drawMessage(message2 : String, X : CGFloat, Y : CGFloat) {
        
        var message1  = message2
        var message: NSMutableAttributedString = NSMutableAttributedString(string: message1)
        
        let fieldColor: UIColor = UIColor.blackColor()
        let fieldFont = UIFont(name: "Helvetica Neue", size: CGFloat(25))
        var paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = NSTextAlignment.Center
        paraStyle.lineSpacing = 6.0
        var skew = 0.1
        message.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(25)], range: NSRange(location: 5, length: 2))
        
        var attributes: NSDictionary = [
            NSForegroundColorAttributeName: fieldColor,
            NSParagraphStyleAttributeName: paraStyle,
            NSObliquenessAttributeName: skew,
            NSFontAttributeName: fieldFont!
        ]
        let countString = (message.length)
        message.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(25)], range: NSRange(location: 0, length: countString))
        message.addAttributes(attributes as [NSObject : AnyObject], range: NSRange(location: 0, length: countString) )
        let toSubtract = CGFloat(countString / 2 * 7)
        //classes.screenWidth / 2) - toSubtract) + 10
        message.drawInRect(CGRectMake(X, Y, 300.0, 60.0))
        
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}