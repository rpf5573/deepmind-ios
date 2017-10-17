//
//  Player.swift
//  deepmind
//
//  Created by mac88 on 2017. 7. 7..
//  Copyright © 2017년 mac88. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import SwiftyJSON

class mPlayer : Mappable {
  var name : String!
  var isOuted : Bool!
  var outedBy : Int!
  var isJoker : Bool!
  var jokerInfo : mJokerInfo?
  
  //쓰지는 않지만, 일단 만들어 둬보자!
  init(Name _name: String, IsOuted _isOuted: Bool, OutedBy _outedBy: Int, IsJoker _isJoker: Bool, JokerInfo _jokerInfo: mJokerInfo?) {
    log.verbose( "called" )
    self.name = _name
    self.isOuted = _isOuted
    self.outedBy = _outedBy
    self.isJoker = _isJoker
    self.jokerInfo = _jokerInfo
  }
  public required init?(map: Map) {
    log.verbose( "called" )
    log.verbose( ["map --> " : map] )
  }
  func mapping(map: Map) {
    log.verbose( "called" )
    log.verbose( ["map --> " : map] )
    
    name        <- map["name"]
    isOuted     <- map["is_outed"]
    outedBy     <- map["outed_by"]
    isJoker     <- map["is_joker"]
    jokerInfo   <- map["joker_info"]
    
    log.debug(["name --> " , name])
    log.debug(["is_outed --> " , isOuted])
    log.debug(["outed_by --> " , outedBy])
    log.debug(["is_joker --> " , isJoker])
    log.debug(["joker_info --> " , jokerInfo as Any])
  }
}

class mJokerInfo : Mappable {
  var soldBy : [Int]!
  var answers : [String]!
  
  init(SoldBy _soldBy: [Int], Answers _answers: [String]) {
    self.soldBy = _soldBy
    self.answers = _answers
  }
  public required init?(map: Map) {
    log.verbose( "called" )
    log.verbose( ["map --> " : map] )
  }
  func mapping(map: Map) {
    log.verbose( "called" )
    log.verbose( ["map --> " : map] )
    
    soldBy        <- map["sold_by"]
    answers    <- map["answers"]
    
    log.debug(["sold_by --> " , soldBy])
    log.debug(["answers --> " , answers])
  }
  
  func didSoldBy(Team _team: Int) -> Bool {
    for i in 0..<soldBy.count {
      if ( soldBy[i] == _team ) {
        return true
      }
    }
    return false
  }
}
