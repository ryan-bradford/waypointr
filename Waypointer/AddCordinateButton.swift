//
//  AddCordinateButton.swift
//  waypointr
//
//  Created by Ryan Bradford on 7/14/17.
//  Copyright © 2017 Ryan. All rights reserved.
//

import Foundation
import UIKit

public class AddCordinateButton: UIButton {
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.5)
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	
}
