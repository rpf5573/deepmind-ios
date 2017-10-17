//
//  Options.swift
//  deepmind
//
//  Created by mac88 on 2017. 7. 4..
//  Copyright © 2017년 mac88. All rights reserved.
//

import Foundation
import ObjectMapper

class mPostCrate : Mappable {
  var count : Int!
  var currentPost : Int?
  var selectedPosts : [Int]!
  var hostsOfEachPost : [Array<Int>]!
  
  init(Posts : [String : Bool]) {
    log.verbose( "called" )
  }
  public required init?(map: Map) {
    log.verbose( "called" )
    log.verbose( ["map --> " : map] )
  }
  func mapping(map: Map) {
    log.error(["MAPPING --> " , "MAPPING"])
    log.verbose( ["map --> " : map] )
    
    count             <- map["count"]
    currentPost       <- map["current_post"]
    selectedPosts     <- map["selected_posts"]
    hostsOfEachPost   <- map["hosts_of_each_post"]
    
    if let cp = currentPost {
      log.debug([ "mPostsCrate", cp ])
    }
    log.debug([ "mPostsCrate", selectedPosts ])
    log.debug([ "mPostsCrate", hostsOfEachPost ])
  }
  func wasSelected(Post _post: Int) -> Bool {
    for i in 0..<selectedPosts.count {
      if ( selectedPosts[i] == _post ) {
        return true
      }
    }
    return false
  }
  func updateNew(Post _post: Int) {
    let ourTeam = mSettings.sharedInstance.ourTeam!;
    // 이전의 기록을 없애야지 물론~ 처음이 아니라면!
    if let currentPost = currentPost {
      var newHostsOfEachPost = Array<Int>()
      for team in self.hostsOfEachPost[currentPost-1] {
        if ( team != ourTeam ) {
          newHostsOfEachPost.append(team)
        }
      }
      // 그라고 새로 업데이토~
      self.hostsOfEachPost[currentPost-1] = newHostsOfEachPost
    }
    
    self.currentPost = _post
    self.selectedPosts.append(_post)
    self.hostsOfEachPost[_post-1].append(ourTeam)
  }
}
