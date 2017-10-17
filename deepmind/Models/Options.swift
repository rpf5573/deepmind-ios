//
//  Options.swift
//  deepmind
//
//  Created by mac88 on 2017. 7. 4..
//  Copyright © 2017년 mac88. All rights reserved.
//

import Foundation
import ObjectMapper

class mOptions : Mappable {
  var beacon       : Bool!
  var testMode     : Bool!
  var jokerInfo    : Bool!
  var playerList   : Bool!
  
  init(options : [String : Bool]) {
    log.verbose( "called" )
    log.verbose( ["options --> " : options] )
  }
  public required init?(map: Map) {
    log.verbose( "called" )
    log.verbose( ["map --> " : map] )
  }
  func mapping(map: Map) {
    log.verbose( "called" )
    log.verbose( ["map --> " : map] )
    
    beacon      <- map["beacon"]
    jokerInfo   <- map["joker_info"]
    testMode    <- map["test_mode"]
    playerList  <- map["player_list"]
    
    log.debug([ "options", beacon ])
    log.debug([ "options", playerList ])
    log.debug([ "options", jokerInfo ])
    log.debug([ "options", testMode ])
  }
}
