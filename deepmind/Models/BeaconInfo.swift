//
//  BeaconInfo.swift
//  deepmind
//
//  Created by mac88 on 2017. 10. 20..
//  Copyright © 2017년 mac88. All rights reserved.
//

import Foundation
import ObjectMapper

class mBeaconInfo : Mappable {
	var item : String!
	var post : Int!
	var url : String!
	
	required init?(map: Map) {
		log.verbose( "called" )
		log.verbose( ["map --> ", map] )
	}
	
	func mapping(map: Map) {
		log.verbose( "called" )
		log.verbose( ["map --> " : map] )
		
		item   <- map["item"]
		post   <- map["post"]
		url    <- map["url"]
		
		log.debug([ "mBeaconInfos", post ])
		log.debug([ "mBeaconInfos", item ])
		log.debug([ "mBeaconInfos", url ])
	}
}
