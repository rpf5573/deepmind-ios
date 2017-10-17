//
//  ToolBarTitleItem.swift
//  deepmind
//
//  Created by mac88 on 2017. 7. 7..
//  Copyright © 2017년 mac88. All rights reserved.
//

import UIKit

class ToolBarTitleItem : UIBarButtonItem {
  var label: UILabel
  
  init(text: String, font: UIFont, color: UIColor) {
    
    label =  UILabel()
    label.text = text
    label.sizeToFit()
    label.font = font
    label.textColor = color
    label.textAlignment = .center
    
    super.init()
    
    customView = label
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
