//
//  Enums.swift
//  deepmind
//
//  Created by mac88 on 2017. 7. 5..
//  Copyright © 2017년 mac88. All rights reserved.
//

import Foundation

enum ViewController {
  case PlayerRegister
  case MemberRegister
  case JokerRegister
  case MainFields
}

enum priority : Int {
  case low = 250
  case medium = 500
  case high = 750
  case required = 1000
}
