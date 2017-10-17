//
//  JokerInfoVC.swift
//  deepmind
//
//  Created by mac88 on 2017. 7. 7..
//  Copyright © 2017년 mac88. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire
import SwiftyJSON
import CustomSwipeCellKit

class OutListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
  
  /* ------------------------------------------------------------------ */
  //  Property
  /* ------------------------------------------------------------------ */
  
  //  constant
  /* ------------------------------------ */
  
  //  view component
  /* ------------------------------------ */
  lazy var outTableView : UITableView = {
    let tv = UITableView(frame: UIScreen.main.bounds, style: UITableViewStyle.plain)
    tv.translatesAutoresizingMaskIntoConstraints = false
    tv.delegate = self
    tv.dataSource = self
    tv.separatorInset = .zero
    return tv
  }()
  
  //  data
  /* ------------------------------------ */
  var jokerInfoListVC : JokerInfoListViewController = JokerInfoListViewController()
  var players : [mPlayer]!
  var currentTeam : Int = 0 {
    willSet(newVal){
      //currentTeam의 값이 바뀌면, 그에 ToolBar Label도 바꾸어 줘야한다! Swift는 이런게 있어서 편하네~
      if ( newVal == mSettings.sharedInstance.ourTeam! ) {
        //(topNavBar.items![3] as! ToolBarTitleItem).label.text = "우리팀"
        self.title = "우리팀"
      } else {
        //(topNavBar.items![3] as! ToolBarTitleItem).label.text = "\(newVal)팀 활동제한"
        self.title = "\(newVal)팀 활동제한"
      }
    }
  }
  lazy var alert : Alert = {
    return Alert(ViewController: self)
  }()
  
  
  /* ------------------------------------------------------------------ */
  //  Function
  /* ------------------------------------------------------------------ */
  
  //  life cycle
  /* ------------------------------------ */
  override func viewDidLoad() {
    log.verbose("called")
    self.setup()
  }
  override func viewWillAppear(_ animated: Bool) {
    log.verbose("called")
    //이 타이밍에는 currentOrder가 바뀐 뒤일것입니다! 그렇기 때문에 , reload는 꼭 해줘야 합니다 ^*^
    self.outTableView.reloadData()
  }
  override func viewDidAppear(_ animated: Bool) {
    log.verbose("called")
  }
  override func viewDidDisappear(_ animated: Bool) {}
  
  //  setup
  /* ------------------------------------ */
  func setup() {
    log.verbose("called")
    self.view.backgroundColor = UIColor.white
    setupNavTopBar()
    setupTableView()
  }
  func setupTableView() {
    self.outTableView.register(PlayerCell.self, forCellReuseIdentifier: "Cell")
    self.view.addSubview(outTableView)
    outTableView.snp.makeConstraints({ make in
      make.top.equalToSuperview().inset(10)
      make.left.equalToSuperview().inset(20)
      make.right.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(10)
    })
  }
  func setupNavTopBar() {
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "조커정보", style: UIBarButtonItemStyle.done, target: self, action: #selector(handleToolBarJokerInfo(Button:)))
  }
  
  //  handler
  /* ------------------------------------ */
  func handleToolBarCancel(Button _btn: UIBarButtonItem) {
    log.verbose("called")
    self.dismiss(animated: true, completion: nil)
  }
  func handleToolBarJokerInfo(Button _btn: UIBarButtonItem) {
    log.verbose("called")
    let joker1 = self.findJoker(Order: 1)!
    let joker2 = self.findJoker(Order: 2)!
    // 총 5가지의 경우의수가 나옵니다
    // 첫번째( 기본셋팅 ) - 조커1,2정보를 둘다 사지 않은 경우 - 이게 제일 흔하지!
    var sheetComponets : (title:String,message:String,btn1title:String,btn1cb:((UIAlertAction)->Void),btn2title:String,btn2cb:((UIAlertAction)->Void)) = (
      title : "조커 정보 구매",
      message: "\(mSettings.sharedInstance.mappingPoints["joker_info"]!)포인트가 소모됩니다",
      btn1title : "조커1정보 구매",
      btn1cb : { _ in
        self.buyJokerInfo(Name: joker1.name!, CallBack: { result in
          if ( result ) {
            //샀으니까~ 우리도 추가 시켜 줘야지
            joker1.jokerInfo!.soldBy.append(mSettings.sharedInstance.ourTeam)
            self.openJokerInfoVC(Order: 1, Answers: joker1.jokerInfo!.answers)
          }
        })
    },
      btn2title : "조커2정보 구매",
      btn2cb : { _ in
        self.buyJokerInfo(Name: joker2.name!, CallBack: { result in
          if ( result ) {
            //샀으니까~ 우리도 추가 시켜 줘야지
            joker2.jokerInfo!.soldBy.append(mSettings.sharedInstance.ourTeam)
            self.openJokerInfoVC(Order: 2, Answers: joker2.jokerInfo!.answers)
          }
        })
    }
    )
    
    let ourTeam : Int = mSettings.sharedInstance.ourTeam;
    // 두번째 경우 - 현재 이곳이 우리팀이라면~!
    if ( self.currentTeam == ourTeam ) {
      sheetComponets.title = "조커 정보 확인"
      sheetComponets.message = "우리팀의 조커 정보를 확인해 보세요"
      sheetComponets.btn1title = "정보확인"
      sheetComponets.btn1cb = { _ in
        // buyJokerInfo를 호출하지 않고 바로 띄워준다
        self.openJokerInfoVC(Order: 1, Answers: joker1.jokerInfo!.answers)
      }
      sheetComponets.btn2title = "정보확인"
      sheetComponets.btn2cb = { _ in
        // buyJokerInfo를 호출하지 않고 바로 띄워준다
        self.openJokerInfoVC(Order: 2, Answers: joker2.jokerInfo!.answers)
      }
    } else {
      // 세번째 경우 - 우리팀이 조커1의 정보만 샀을때
      if ( joker1.jokerInfo!.didSoldBy(Team: ourTeam) && !joker2.jokerInfo!.didSoldBy(Team: ourTeam) ) {
        sheetComponets.btn1title = "정보확인"
        sheetComponets.btn1cb = { _ in
          // 샀으니까 추가시켜줘야지
          joker1.jokerInfo!.soldBy.append(mSettings.sharedInstance.ourTeam)
          // buyJokerInfo를 호출하지 않고 바로 띄워준다
          self.openJokerInfoVC(Order: 1, Answers: joker1.jokerInfo!.answers)
        }
      }
        // 네번째 경우 - 우리팀이 조커2의 조커정보만 샀을때
      else if ( !joker1.jokerInfo!.didSoldBy(Team: ourTeam) && joker2.jokerInfo!.didSoldBy(Team: ourTeam) ) {
        sheetComponets.btn2title = "정보확인"
        sheetComponets.btn2cb = { _ in
          // 샀으니까 추가시켜줘야지
          joker2.jokerInfo!.soldBy.append(mSettings.sharedInstance.ourTeam)
          // buyJokerInfo를 호출하지 않고 바로 띄워준다
          self.openJokerInfoVC(Order: 2, Answers: joker2.jokerInfo!.answers)
        }
      }
        // 다섯번째 경우 - 둘다 샀을때
      else if ( joker1.jokerInfo!.didSoldBy(Team: ourTeam) && joker2.jokerInfo!.didSoldBy(Team: ourTeam) ) {
        sheetComponets.title = "조커 정보 확인"
        sheetComponets.message = "모든 정보를 구매하셨습니다"
        sheetComponets.btn1title = "정보확인"
        sheetComponets.btn1cb = { _ in
          // 샀으니까 추가시켜줘야지
          joker1.jokerInfo!.soldBy.append(mSettings.sharedInstance.ourTeam)
          // buyJokerInfo를 호출하지 않고 바로 띄워준다
          self.openJokerInfoVC(Order: 1, Answers: joker1.jokerInfo!.answers)
        }
        sheetComponets.btn2title = "정보확인"
        sheetComponets.btn2cb = { _ in
          // 샀으니까 추가시켜줘야지
          joker2.jokerInfo!.soldBy.append(mSettings.sharedInstance.ourTeam)
          // buyJokerInfo를 호출하지 않고 바로 띄워준다
          self.openJokerInfoVC(Order: 2, Answers: joker2.jokerInfo!.answers)
        }
      }
    }
    alert.sheet(Title: sheetComponets.title, Message: sheetComponets.message, Btn1Title: sheetComponets.btn1title, Btn1CallBack: sheetComponets.btn1cb, Btn2title: sheetComponets.btn2title, Btn2CallBack: sheetComponets.btn2cb, BtnCancelTitle: "취소")
  }
  
  //  delegate & datasource
  /* ------------------------------------ */
  /* TableView */
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 64
  }
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    log.verbose("called")
    let cell = tableView.cellForRow(at: indexPath) as! PlayerCell
    cell.showSwipe(orientation: .right, animated: true, completion: nil)
    return indexPath
  }
  func numberOfSections(in tableView: UITableView) -> Int {
    log.verbose("called")
    return 1
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    log.verbose("called")
    return self.players.count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    log.verbose("called")
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! PlayerCell
    cell.textLabel?.text = self.players[indexPath.row].name
    cell.delegate = self
    //기본적으로는 안보이게 한다음에
    cell.hideOutView()
    
    //만약에 아웃되었으면 보이게 하자
    if ( players[indexPath.row].isOuted! ) {
      cell.showOutView()
    }
    return cell
  }
  /* SwipTableViewCell */
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    log.verbose("called")
    guard orientation == .right, players[indexPath.row].isOuted! == false, (mSettings.sharedInstance.ourTeam!) != currentTeam else { return nil }
    
    let deleteAction = SwipeAction(style: .destructive, title: "활동제한") { action, indexPath in
      log.verbose("called")
      let cell : PlayerCell = tableView.cellForRow(at: indexPath) as! PlayerCell
      self.alert.approval(Title: "확인", OKTitle: "예", NOTitle: "아니오", Message: "\(mSettings.sharedInstance.mappingPoints["out_cost"]!)점을 소모하고 활동제한 시키겠습니까?", DidOKBtnClick: { action in
        // handle action by updating model with deletion
        self.out(IndexPath: indexPath, CallBack: { result in
          cell.hideSwipe(animated: true)
          if ( result ) {
            self.players[indexPath.row].isOuted = true
            cell.showOutView()
          } else {
          }
        })
        
      }, DidNOBtnClick: { action in
        cell.hideSwipe(animated: true)
      }, DidAlertOpen: nil)
    }
    return [deleteAction]
  }
  func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation:
    SwipeActionsOrientation) -> SwipeTableOptions {
    log.verbose("called")
    var options = SwipeTableOptions()
    options.expansionStyle = SwipeExpansionStyle.selection
    options.transitionStyle = .border
    return options
  }
  
  //  custom
  /* ------------------------------------ */
  func out(IndexPath _indexPath: IndexPath, CallBack _cb:@escaping ((Bool)->Void)) {
    let ourTeam = mSettings.sharedInstance.ourTeam!
    let name = players[_indexPath.row].name!
    let url = "\(BASE_URL)/out.php"
    let params : [String:Any] = ["out":true, "team":currentTeam, "name":name, "our_team":ourTeam]
    Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { response in
      log.debug(["Response --> " , response])
      if let result = response.result.value {
        let json = JSON(result)
        log.verbose(["json --> " , json])
        if let response_code = json["response_code"].int {
          if ( response_code == 201 ) {
            self.alert.show(Message: json["success_message"].stringValue, CallBack: { action in
              _cb(true)
            })
          } else {
            self.alert.show(Message: json["error_message"].stringValue, CallBack: { action in
              _cb(false)
            })
          }
        }
      }
    })
  }
  func buyJokerInfo(Name _name: String, CallBack _cb:@escaping (Bool)->Void) {
    let ourTeam = mSettings.sharedInstance.ourTeam!
    let url = "\(BASE_URL)/out.php"
    let params : [String:Any] = ["buy_joker_info":true, "team":currentTeam, "name":_name, "our_team":ourTeam]
    Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { response in
      log.debug(["Response --> " , response])
      if let result = response.result.value {
        let json = JSON(result)
        log.verbose(["json --> " , json])
        if let response_code = json["response_code"].int {
          //이렇게하니까, 편하네~~!
          if ( response_code == 201 ) {
            self.alert.show(Message: json["success_message"].stringValue, CallBack: { action in
              _cb(true)
            })
          } else {
            self.alert.show(Message: json["error_message"].stringValue, CallBack: { action in
              _cb(false)
            })
          }
        }
      }
    })
  }
  func findJoker(Order _order: Int) -> mPlayer? {
    var player : mPlayer?
    if ( _order == 1 ) {
      for i in 0..<players.count {
        if ( players[i].isJoker! ) {
          player = players[i]
        }
      }
    } else {
      for i in (0..<players.count).reversed() {
        log.verbose(["i --> " , i])
        if ( players[i].isJoker! ) {
          player = players[i]
        }
      }
    }
    return player
  }
  func openJokerInfoVC(Order _order: Int, Answers _answers: [String]) {
    //let joker = self.findJoker(Order: _order)!
    self.jokerInfoListVC.currentOrder = _order
    self.jokerInfoListVC.answers = _answers
    self.navigationController?.pushViewController(self.jokerInfoListVC, animated: false)
  }
}
