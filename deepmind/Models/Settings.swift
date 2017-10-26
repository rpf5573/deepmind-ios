//
//  Settings.swift
//  deepmind
//
//  Created by mac88 on 2017. 7. 4..
//  Copyright © 2017년 mac88. All rights reserved.
//

import Foundation
import ObjectMapper

class mSettings : Mappable {
  static public var sharedInstance  : mSettings! //Singleton
  var totalTeamCount         : Int!
  var options                : mOptions!
  var jokerInfoQuestions     : [String]? //조커 정보를 입력하지 않는 Mode일 경우에는 nil이 들어감
  var mappingPoints          : [String : Int]!
  var wholeMapName           : String!
  var teamPlayerCounts       : [Int]!
  var ourTeam                : Int!
	var beaconInfos						 : [mBeaconInfo]?
  
  required init?(map: Map) {
    log.verbose( "called" )
    log.verbose( ["map --> ", map] )
  }
  func mapping(map: Map) {
    log.verbose( "called" )
    log.verbose( ["map --> ", map] )
    
    totalTeamCount      <- map["total_team_count"]
    options             <- map["options"]
    jokerInfoQuestions  <- map["joker_info_questions"]
    mappingPoints       <- map["mapping_points"]
    wholeMapName        <- map["whole_map_name"]
    teamPlayerCounts    <- map["team_player_counts"]
    ourTeam             <- map["our_team"]
		beaconInfos					<- map["beacon_infos"]
    
    log.debug(["total_team_count", totalTeamCount])
    log.debug(["joker_info_questions", jokerInfoQuestions as Any ])
    log.debug(["mapping_points", mappingPoints ])
    log.debug(["whole_map_name", wholeMapName ])
    log.debug(["team_player_counts --> " , teamPlayerCounts])
    log.debug(["ourTeam --> " , ourTeam])
    
    mSettings.sharedInstance = self
    mSettings.sharedInstance.wholeMapName = mSettings.sharedInstance.wholeMapName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!
  }
  func getOurTeamPlayerCount() -> Int {
    return teamPlayerCounts[ourTeam-1]
  }
  func getJokerInfoQuestionCount() -> Int {
    return jokerInfoQuestions!.count
  }
}
