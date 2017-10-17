//
//  PlayerRegister.swift
//  deepmind
//
//  Created by mac88 on 2017. 7. 5..
//  Copyright © 2017년 mac88. All rights reserved.
//

import UIKit
import PagingMenuController
import Alamofire
import SwiftyJSON
import SkyFloatingLabelTextField
import ObjectMapper

class PlayerRegisterViewController : PagingMenuController {
  
  /* ------------------------------------------------------------------ */
  //  Property
  /* ------------------------------------------------------------------ */
  
  //  data
  /* ------------------------------------ */
  lazy var alert : Alert = { return Alert(ViewController: self); }()
  var memberRegisterVC : MemberRegisterViewController!
  var jokerRegisterVC : JokerRegisterViewController!
  
  
  /* ------------------------------------------------------------------ */
  //  Function
  /* ------------------------------------------------------------------ */
  
  //  life cycle
  /* ------------------------------------ */
  override func viewDidLoad() {
    log.verbose("called")
    super.viewDidLoad();
    setup()
  }
  override func viewWillAppear(_ animated: Bool) {
    log.verbose("called")
    super.viewWillAppear(animated);
  }
  override func viewDidAppear(_ animated: Bool) {
    log.verbose("called")
    super.viewDidAppear(animated);
    self.view.backgroundColor = UIColor.flatPink
  }
  override func willMove(toParentViewController parent: UIViewController?) {
    log.verbose("called")
    self.view.dismissKeyboard()
  }
  
  //  setup
  /* ------------------------------------ */
  func setup() {
    self.onMove = { state in
      switch state {
      case .willMoveController(to: _, from: _):
        self.view.dismissKeyboard()
      default:
        break;
      }
    }
    NotificationCenter.default.addObserver(self, selector: #selector(self.handleRegisterRequest), name: NotificationName.RegisterRequest, object: nil)
  }
  
  //  handler
  /* ------------------------------------ */
  func handleRegisterRequest() {
    if( mSettings.sharedInstance.options.testMode! ) {
      fillAllFields()
    }
    let allFieldsResult = validateAllFields()
    if ( allFieldsResult.pass ) {
      alert.show(Message: "성공!", CallBack: { action in
        //shuffled해서 한번 솎은 새로운 array를 만든다!
        self.sendPlayersToServer(Players: (allFieldsResult.value!).shuffled())
      })
    }
  }
  
  //  useful
  /* ------------------------------------ */
  /* Validation */
  func validateAllFields() -> (pass:Bool, value:[mPlayer]?) {
    let memberResult = validateMember()
    if ( !memberResult.pass ) {
      alert.show(Message: "맴버 이름을 다시 확인해 주세요", CallBack: { _ in
        self.move(toPage: 0, animated: true)
      })
      return (false, nil)
    }
    let jokerResult = validateJoker()
    if ( !jokerResult.pass ) {
      alert.show(Message: "조커 이름을 다시 확인해 주세요", CallBack: { _ in
        self.move(toPage: 1, animated: true)
      })
      return (false, nil)
    }
    
    var jokerInfoResult : (pass: Bool, order: Int, value:[[String]]?)?
    
    if ( mSettings.sharedInstance.options.jokerInfo!) {
      jokerInfoResult = validateJokerInfo()
      if ( !(jokerInfoResult!.pass) ) {
        alert.show(Message: "조커 정보를 다시 확인해 주세요", CallBack: { _ in
          self.jokerRegisterVC.presentJokerInfoRegisterVC(Order: jokerInfoResult!.order)
        })
        return (false, nil)
      }
    }
    var players : [mPlayer] = []
    //맴버 추가
    for i in 0..<memberResult.value!.count {
      let player = mPlayer(Name: memberResult.value![i], IsOuted: false, OutedBy: 0, IsJoker: false, JokerInfo: nil)
      players.append(player)
    }
    //조커 추가
    for i in 0..<jokerResult.value!.count {
      var jokerInfo : mJokerInfo?
      if let jokerInfoResult = jokerInfoResult {
        jokerInfo = mJokerInfo(SoldBy: [], Answers: jokerInfoResult.value![i])
      }
      let player = mPlayer(Name: jokerResult.value![i], IsOuted: false, OutedBy: 0, IsJoker: true, JokerInfo: jokerInfo)
      players.append(player)
    }
    log.debug(["players --> " , players])
    return (true, players)
  }
  func validateMember() -> (pass:Bool, value:[String]?) {
    var names : [String] = []
    for i in 0..<memberRegisterVC.memberRegisterTextFields.count {
      let tf = memberRegisterVC.memberRegisterTextFields[i]
      if ( tf.text!.isEmpty || tf.hasErrorMessage ) {
        return (false, nil)
      }
      names.append(tf.text!)
    }
    return (true, names)
  }
  func validateJoker() -> (pass:Bool, value:[String]?) {
    var names : [String] = []
    for i in 0..<jokerRegisterVC.jokerRegisterTextFields.count {
      let tf = jokerRegisterVC.jokerRegisterTextFields[i]
      if ( tf.text!.isEmpty || tf.hasErrorMessage ) {
        return (false, nil)
      }
      names.append(tf.text!)
    }
    return (true, names)
  }
  func validateJokerInfo() -> (pass: Bool, order: Int, value:[[String]]?) {
    for i in 0..<mSettings.sharedInstance.getJokerInfoQuestionCount() {
      for z in 0..<2 {
        if ( jokerRegisterVC.jokerInfoRegisterVC.answers[z][i].isEmpty ) {
          return (false, z+1, nil)
        }
      }
    }
    return (true, 0, jokerRegisterVC.jokerInfoRegisterVC.answers)
  }
  /* Fill */
  func fillAllFields() {
    fillMemberFields()
    fillJokerFields()
    if ( mSettings.sharedInstance.options.jokerInfo! ) {
      fillJokerInfos()
    }
  }
  func fillMemberFields() {
    let testNames = ["정윤석","박사랑","김향기","박준목","정다빈","김유정","조수민","정채은","심혜원","은원재","고주연","주민수","이현우","정민아","한예린","남지현","박지빈","백승도","박보영"];
    for i in 0..<memberRegisterVC.memberRegisterTextFields.count {
      memberRegisterVC.memberRegisterTextFields[i].text = testNames[i]
    }
  }
  func fillJokerFields() {
    let testNames = ["조커일", "조커이"]
    for i in 0..<jokerRegisterVC.jokerRegisterTextFields.count {
      jokerRegisterVC.jokerRegisterTextFields[i].text = testNames[i]
    }
  }
  func fillJokerInfos() {
    let testAnswers = [
      [
        "비 내리면산 부풀고산 부풀면개울물 넘친다.",
        "귀뚜라미 귀뜨르르 가느단 소리",
        "7년 후에 지구를 한바퀴 돌 수 있다. ",
        "신은 용기있는자를 결코 버리지 않는다",
        "피할수 없으면 즐겨라",
        "더많이 실험할수록 더나아진다"
      ],
      [
        "푹푹 찌는 여름.",
        "아이스크림보다 생각나는 것이 있나.",
        "한 송이의 국화꽃",
        "너를 예로 들어",
        "문득 아름다운 것과 마주쳤을 때 지금 곁에 있으면 얼마나 좋을까 하고",
        "늦게 도착한 바람이 때를 놓치고, 책은 덮인다"
      ]
    ]
    for i in 0..<mSettings.sharedInstance.getJokerInfoQuestionCount() {
      jokerRegisterVC.jokerInfoRegisterVC.answers[0][i] = testAnswers[0][i]
      jokerRegisterVC.jokerInfoRegisterVC.answers[1][i] = testAnswers[1][i]
    }
  }
  /* Other */
  func sendPlayersToServer( Players _players: [mPlayer] ) {
    log.verbose(["_players.toJSONString(prettyPrint: true) --> " , _players.toJSONString(prettyPrint: true)])
    if let playersJsonString = _players.toJSONString(prettyPrint: false) {
      log.debug(["PlayersJsonString --> " , playersJsonString])
      let params : [String : Any] = ["players" : playersJsonString, "our_team" : mSettings.sharedInstance.ourTeam]
      Alamofire.request("\(BASE_URL)/register.php", method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { response in
        log.debug(["Response --> " , response])
        if let result = response.result.value {
          let json = JSON(result)
          log.debug(["json --> " , json])
          if ( json["response_code"].intValue == 201 ) {
            UIApplication.shared.keyWindow!.moveTo(VC: .MainFields)
          }
        }
      })
    }
  }

}
