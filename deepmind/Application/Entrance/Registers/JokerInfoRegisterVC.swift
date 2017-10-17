//
//  JokerInfoVC.swift
//  deepmind
//
//  Created by mac88 on 2017. 7. 7..
//  Copyright © 2017년 mac88. All rights reserved.
//

import UIKit
import SnapKit
import SkyFloatingLabelTextField
import PopupDialog

class JokerInfoRegisterViewController : UIViewController, UITableViewDelegate,UITableViewDataSource {
  
  /* ------------------------------------------------------------------ */
  //  Property
  /* ------------------------------------------------------------------ */
  
  //  constant
  /* ------------------------------------ */
  struct constants {
    struct height {
      static let jokerInfoCell : CGFloat = 56
    }
  }
  
  //  view component
  /* ------------------------------------ */
  lazy var topNavBar : UIToolbar = {
    let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50)
    let tb = UIToolbar(frame: rect)
    tb.translatesAutoresizingMaskIntoConstraints = false
    var items = [UIBarButtonItem]()
    
    let fixedEmptyItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
    fixedEmptyItem.width = 20
    items.append( fixedEmptyItem )
    items.append(
      UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleToolBarCancel(Button:)))
    )
    items.append(
      UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
    )
    items.append(
      //이게 신기한게,,, text에다가 미리 어떤 값을 넣어놓지 않으면, 자리를 못잡나봐! bounds가 너무 작게 잡히나봐!
      ToolBarTitleItem(text: "조커\(self.currentOrder)정보", font: UIFont.boldSystemFont(ofSize: 16), color: UIColor.flatBlackDark)
    )
    items.append(
      UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
    )
    items.append(
      UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(handleToolBarDone(Button:)))
    )
    items.append( fixedEmptyItem )
    tb.setItems(items, animated: true)
    return tb
  }()
  lazy var jokerInfoTableView : UITableView = {
    let tv = UITableView(frame: UIScreen.main.bounds, style: UITableViewStyle.plain)
    tv.translatesAutoresizingMaskIntoConstraints = false
    tv.delegate = self
    tv.dataSource = self
    tv.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
    tv.setHideKeyboard()
    return tv
  }()
  
  //  data
  /* ------------------------------------ */
  lazy var answers : [[String]] = {
    var aws = [[String](),[String]()]
    let questionCount = mSettings.sharedInstance.getJokerInfoQuestionCount()
    aws[0].fill(With: "", Count: questionCount)
    aws[1].fill(With: "", Count: questionCount)
    return aws
  }()
  var currentOrder : Int = 1 {
    willSet(newVal) {
      (topNavBar.items![3] as! ToolBarTitleItem).label.text = "조커\(newVal)정보"
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
    log.debug(["answers --> " , answers])
    
    //이 타이밍에는 currentOrder가 바뀐 뒤일것입니다! 그렇기 때문에 , reload는 꼭 해줘야 합니다 ^*^
    self.jokerInfoTableView.reloadData()
  }
  
  //  setup
  /* ------------------------------------ */
  func setup() {
    log.verbose("called")
    
    //answer안에다가 questions.count만큼 값을 채워넣자
    log.debug(["answers[0] --> " , answers[0]])
    log.debug(["answers[1] --> " , answers[1]])
    
    self.view.backgroundColor = UIColor.white
    setupTopNavBar()
    setupTableView()
  }
  func setupTopNavBar() {
    self.view.addSubview(topNavBar)
    topNavBar.snp.makeConstraints({ make in
      make.top.equalToSuperview().inset(20)
      make.left.equalToSuperview()
      make.right.equalToSuperview()
    })
  }
  func setupTableView() {
    jokerInfoTableView.register(JokerInfoRegisterCell.self, forCellReuseIdentifier: "jokerInfoCell")
    self.view.addSubview(jokerInfoTableView)
    jokerInfoTableView.snp.makeConstraints({ make in
      make.top.equalTo(topNavBar.snp.bottom)
      make.left.equalToSuperview().inset(20)
      make.right.equalToSuperview().inset(20)
      make.bottom.equalToSuperview()
    })
  }
  
  //  handler
  /* ------------------------------------ */
  func handleToolBarCancel(Button _btn: UIBarButtonItem) {
    log.verbose("called")
    self.view.dismissKeyboard()
    alert.approval(Title: "확인", OKTitle: "예", NOTitle: "아니오", Message: "지금 입력된 자료는 저장되지 않습니다. 뒤로 가시겠습니까?", DidOKBtnClick: { _ in
      self.clearAnswer(Order: self.currentOrder)
      self.dismiss(animated: true, completion: nil)
    }, DidNOBtnClick: { _ in
    }, DidAlertOpen: nil)
  }
  func handleToolBarDone(Button _btn: UIBarButtonItem) {
    log.verbose("called")
    self.view.dismissKeyboard()
    var answers : [String] = []
    let questionCount = mSettings.sharedInstance.getJokerInfoQuestionCount()
    for i in 0..<questionCount {
      let indexPath = IndexPath(row: i, section: 0)
      if let cell = self.jokerInfoTableView.cellForRow(at: indexPath) as? JokerInfoRegisterCell {
        if let answer = cell.jokerInfoRegisterTextField.text {
          if ( answer.length == 0 ) {
            cell.jokerInfoRegisterTextField.errorMessage = "이곳에 답변을 입력해 주세요"
            return;
          } else {
            answers.append(answer)
          }
        }
      } else {
        log.error("NO CELL!!!")
      }
    }
    self.answers[currentOrder-1] = answers
    dismiss(animated: true, completion: nil) // 현재 VC를 내리자!
  }
  
  //  delegate & datasource
  /* ------------------------------------ */
  /* TableView */
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return constants.height.jokerInfoCell
  }
  func numberOfSections(in tableView: UITableView) -> Int {
    log.verbose("called")
    return 1
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    log.verbose("called")
    return mSettings.sharedInstance.getJokerInfoQuestionCount()
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    log.verbose("called")
    let cell : JokerInfoRegisterCell = tableView.dequeueReusableCell(withIdentifier: "jokerInfoCell", for: indexPath) as! JokerInfoRegisterCell
    cell.jokerInfoRegisterTextField.placeholder = mSettings.sharedInstance.jokerInfoQuestions![indexPath.row]
    cell.jokerInfoRegisterTextField.errorMessage = nil
    //그냥 있을지 없을지 모르는 상태로 넣어두는거야!!!
    cell.jokerInfoRegisterTextField.text = answers[currentOrder-1][indexPath.row]
    return cell
  }
  
  //  custom
  /* ------------------------------------ */
  func clearAnswer(Order _order: Int) {
    for i in 0..<mSettings.sharedInstance.getJokerInfoQuestionCount() {
      answers[_order-1][i] = ""
    }
  }
}
