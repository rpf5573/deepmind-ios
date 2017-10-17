//
//  JokerInfoList.swift
//  deepmind
//
//  Created by mac88 on 2017. 7. 9..
//  Copyright © 2017년 mac88. All rights reserved.
//

import UIKit
import SnapKit
import CustomSwipeCellKit
import Alamofire
import SwiftyJSON

class PostSelectionViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
  
  /* ------------------------------------------------------------------ */
  //  Property
  /* ------------------------------------------------------------------ */
  
  //  constant
  /* ------------------------------------ */
  struct constants {
    struct height {
      static let tableViewCell : CGFloat = 66.0
    }
    struct inset {
      static let tableView : CGFloat = 20.0
    }
  }
  
  //  view component
  /* ------------------------------------ */
  lazy var postsListView : UITableView = {
    let tv = UITableView(frame: .zero, style: UITableViewStyle.plain)
    tv.translatesAutoresizingMaskIntoConstraints = false
    tv.separatorInset = .zero
    tv.register(PostSelectionCell.self, forCellReuseIdentifier: "Cell")
    tv.dataSource = self
    tv.delegate = self
    return tv
  }()
  
  //  data
  /* ------------------------------------ */
  var postCrate : mPostCrate!
  lazy var alert : Alert = { return Alert(ViewController: self) }()
  var delegate : PostSelectionViewControllerDelegate!
  
  
  /* ------------------------------------------------------------------ */
  //  Function
  /* ------------------------------------------------------------------ */
  
  //  life cycle
  /* ------------------------------------ */
  override func viewDidLoad() {
    super.viewDidLoad();
    log.verbose("called")
    // 현재 포스트가 없다면!
    setup()
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated);
    log.verbose("called")
    self.postsListView.reloadData()
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated);
    log.verbose("called")
  }
  
  //  setup
  /* ------------------------------------ */
  func setup() {
    self.title = "포스트 선택"
    //self.automaticallyAdjustsScrollViewInsets = false
    self.view.backgroundColor = UIColor.white
    setupPostsListView()
  }
  func setupPostsListView() {
    self.view.addSubview(postsListView)
    //postsListView.contentInset = UIEdgeInsets
    postsListView.snp.makeConstraints({ make in
      make.edges.equalToSuperview().inset(constants.inset.tableView)
    })
  }
  
  //  handler
  /* ------------------------------------ */
  
  //  delegate & datasource
  /* ------------------------------------ */
  /* SwipeTableViewCell */
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    log.verbose("called")
    let post = indexPath.row + 1
    guard orientation == .right, !self.postCrate!.wasSelected(Post: post) else {
      return nil
    }
    let selectAction = SwipeAction(style: .selective, title: "선택") { action, indexPath in
      log.verbose("called")
      action.font = UIFont.systemFont(ofSize: 20)
      action.textColor = UIColor.green
      //---- 여기서 부터는 현제포스트는 없지만 row == 1인경우 + 현제포스트가 있는경우 ---
      self.alert.approval(Title: "확인", OKTitle: "예", NOTitle: "아니오", Message: "\(post)포스트를 선택하시겠습니까?", DidOKBtnClick: { action in
        self.select(Post: post, AndThen: { json in
          if ( json["response_code"].intValue == 201 ) {
            // 모델을 새로 업데이트!
            self.postCrate.updateNew(Post: post)
            self.alert.show(Message: json["success_message"].stringValue, CallBack: { _ in
              log.debug(["postsCrate.selectedPosts --> " , self.postCrate!.selectedPosts])
              self.delegate.didSelect(Post: post)
              self.postsListView.reloadData()
            })
          } else {
            self.alert.show(Message: json["error_message"].stringValue, CallBack: nil);
          }
        })
      }, DidNOBtnClick: { action in
      }, DidAlertOpen: nil)
    }
    return [selectAction]
  }
  func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation:
    SwipeActionsOrientation) -> SwipeTableOptions {
    log.verbose("called")
    var options = SwipeTableOptions()
    options.expansionStyle = SwipeExpansionStyle.selection
    options.transitionStyle = .border
    return options
  }
  /* TableView */
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return constants.height.tableViewCell
  }
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    log.verbose("called")
    let cell = tableView.cellForRow(at: indexPath) as! PostSelectionCell
    if ( !self.postCrate!.wasSelected(Post: indexPath.row + 1) ) {
      cell.showSwipe(orientation: .right, animated: true, completion: nil)
    } else {
      alert.show(Message: "이미 선택하신 포스트입니다", CallBack: nil)
    }
    return indexPath
  }
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    log.verbose("0")
    return postCrate!.count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostSelectionCell
    cell.delegate = self
    cell.postLabel.text = "\(indexPath.row + 1)포스트"
    cell.hostsOfPostLabel.text = ""
    cell.clear()
    if ( self.postCrate!.wasSelected(Post: indexPath.row + 1) ) {
      cell.dim()
    }
    let hostsOfPost : Array<Int> = self.postCrate!.hostsOfEachPost[indexPath.row]
    if ( hostsOfPost.count > 0 ) {
      var hostsList = "진행중 : ["
      //self.postsCrate.hostsOfEachPost[indexPath.row]
      for i in hostsOfPost {
        hostsList.append(" \(i)팀")
      }
      hostsList.append(" ]")
      cell.hostsOfPostLabel.text = hostsList
    }
    return cell
  }
  
  //  custom
  /* ------------------------------------ */
  func select(Post _post: Int, AndThen _cb: @escaping (JSON)->Void) {
    let ourTeam = mSettings.sharedInstance.ourTeam!
    let url = "\(BASE_URL)/post.php"
    let params : [String:Any] = ["update_post":true, "team":ourTeam, "post":_post]
    Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { response in
      log.debug(["Response --> " , response])
      if let result = response.result.value {
        let json = JSON(result)
        log.verbose(["json --> " , json])
        _cb(json)
      }
    })
  }
  func highlightFirstPostCell() {
    let indexPath = IndexPath(row: 0, section: 0)
    if let firstCell = self.postsListView.cellForRow(at: indexPath) {
      self.postsListView.clipsToBounds = false
      UIView.animate(withDuration: 1.0, animations: {
        firstCell.backgroundColor = UIColor.green
        firstCell.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
      }, completion: { result in
        UIView.animate(withDuration: 1.0, animations: {
          firstCell.backgroundColor = UIColor.white
          firstCell.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: { result in
          self.postsListView.clipsToBounds = true
        })
      })
    }
  }
  func encourageToSelectFirstPost() {
    alert.show(Message: "1포스트를 먼저 선택해 주세요!", CallBack: { _ in
      self.highlightFirstPostCell()
    })
  }
}
