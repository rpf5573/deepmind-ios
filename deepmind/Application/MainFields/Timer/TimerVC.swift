//
//  VC_Timer.swift
//  AlphagoDeepMind
//
//  Created by mac88 on 2017. 1. 6..
//  Copyright © 2017년 mac88. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire
import SwiftyJSON

class TimerViewController : UIViewController {
  
  /* ------------------------------------------------------------------ */
  //  Property
  /* ------------------------------------------------------------------ */
  
  //  view component
  /* ------------------------------------ */
  lazy var countDownView : CountDownView = {
    let cdv = CountDownView(frame: .zero)
    cdv.translatesAutoresizingMaskIntoConstraints = false
    return cdv
  }()
  
  //  data
  /* ------------------------------------ */
  lazy var alert : Alert = { return Alert(ViewController: self) }()
  

  /* ------------------------------------------------------------------ */
  //  Function
  /* ------------------------------------------------------------------ */
  
  //  life cycle
  /* ------------------------------------ */
  override func viewDidLoad() {
    log.verbose("called")
    setup()
  }
  override func viewWillAppear(_ animated: Bool) {
    log.verbose("called")
    getTime(AndThen: { json in
      log.debug(json)
      if json["response_code"].intValue == 201 {
        self.countDownView.set(Time: (json["value"]["time"].intValue * 100))
        self.countDownView.go()
      } else {
        self.alert.show(Message: json["error_message"].stringValue, CallBack: nil)
      }
    })
  }
  override func viewDidAppear(_ animated: Bool) {
    log.verbose("called")
  }
  override func viewDidDisappear(_ animated: Bool) {
    log.verbose("called")
    self.countDownView.stop()
  }
  
  //  setup
  /* ------------------------------------ */
  func setup(){
    self.title = "타이머"
    setupCountDownView()
  }
  func setupCountDownView() {
    self.view.addSubview(countDownView)
    countDownView.snp.makeConstraints({ make in
      make.width.equalToSuperview().multipliedBy(0.8)
      make.height.equalToSuperview().multipliedBy(0.2)
      make.center.equalToSuperview()
    })
  }
  
  //  custom
  /* ------------------------------------ */
  func getTime(AndThen _cb:@escaping (JSON)->Void){
    let team : Int = mSettings.sharedInstance.ourTeam
    let url = "\(BASE_URL)/timer.php"
    let param : [String:Any] = ["get_time":true, "team":team]
    Alamofire.request(url, method: .post, parameters: param, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { response in
      log.debug(response)
      if let value = response.result.value {
        let json = JSON(value)
        _cb(json)
      }
    })
  }
}
