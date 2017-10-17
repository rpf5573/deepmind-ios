//
//  JokerInfoList.swift
//  deepmind
//
//  Created by mac88 on 2017. 7. 9..
//  Copyright © 2017년 mac88. All rights reserved.
//

import UIKit
import SnapKit

class JokerInfoListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  /* ------------------------------------------------------------------ */
  //  Property
  /* ------------------------------------------------------------------ */
  
  //  constant
  /* ------------------------------------ */
  struct constants {
    struct inset {
      static let jokerInfoTableView : CGFloat = 0.0
    }
  }
  
  //  view component
  /* ------------------------------------ */
  lazy var jokerInfoTableView : UITableView = {
    let tv = UITableView(frame: .zero, style: UITableViewStyle.grouped)
    tv.translatesAutoresizingMaskIntoConstraints = false
    tv.dataSource = self
    tv.delegate = self
    return tv
  }()
  
  //  data
  /* ------------------------------------ */
  var answers : Array<String>!
  var currentOrder : Int = 1
  
  
  /* ------------------------------------------------------------------ */
  //  Function
  /* ------------------------------------------------------------------ */
  
  //  life cycle
  /* ------------------------------------ */
  override func viewDidLoad() {
    super.viewDidLoad();
    log.verbose("called")
    setup()
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated);
    log.verbose("called")
    self.jokerInfoTableView.reloadData()
    self.title = "조커\(currentOrder)정보"
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated);
    log.verbose("called")
  }
  
  //  setup
  /* ------------------------------------ */
  func setup() {
    //self.automaticallyAdjustsScrollViewInsets = false
    setupJokerInfoTableView()
  }
  func setupJokerInfoTableView() {
    self.view.addSubview(jokerInfoTableView)
    jokerInfoTableView.snp.makeConstraints({ make in
      make.edges.equalToSuperview().inset(constants.inset.jokerInfoTableView)
    })
  }
  
  //  delegate & datasource
  /* ------------------------------------ */
  /* TableView */
  func numberOfSections(in tableView: UITableView) -> Int {
    return mSettings.sharedInstance.jokerInfoQuestions!.count
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    cell.textLabel?.text = self.answers[indexPath.section]
    return cell
  }
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    log.verbose("called")
    return mSettings.sharedInstance.jokerInfoQuestions?[section]
  }
}
