//
//  Login.swift
//  deepmind
//
//  Created by mac88 on 2017. 7. 4..
//  Copyright © 2017년 mac88. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
import ObjectMapper
import SnapKit
import ChameleonFramework
import Spring
import BouncyLayout
import NVActivityIndicatorView

class OutViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  /* ------------------------------------------------------------------ */
  //  Property
  /* ------------------------------------------------------------------ */
  
  //  constant
  /* ------------------------------------ */
  struct constants {
    struct count {
      static let cellInHorizontal : CGFloat = 2
    }
    struct height {
      static let cell : CGFloat = 120
    }
  }
  
  //  data
  /* ------------------------------------ */
  let outListVC : OutListViewController = OutListViewController()
  lazy var alert : Alert = { return Alert(ViewController: self) }()
  
  
  /* ------------------------------------------------------------------ */
  //  Function
  /* ------------------------------------------------------------------ */
  
  //  life cycle
  /* ------------------------------------ */
  override func viewDidLoad() {
    super.viewDidLoad();
    log.verbose("called")
    self.view.backgroundColor = UIColor.flatPink
    setup()
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated);
    log.verbose("called")
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated);
    log.verbose("called")
  }
  
  //  setup
  /* ------------------------------------ */
  func setup() {
    setupCollectionView()
  }
  func setupCollectionView() {
    let layout = (self.collectionViewLayout as! UICollectionViewFlowLayout)
    layout.minimumLineSpacing = 40
    layout.minimumInteritemSpacing = 40
    
    self.collectionView?.register(TeamCell.self, forCellWithReuseIdentifier: "cellId")
    self.collectionView?.backgroundColor = UIColor.white
    
    //self.view 가 collection view의 parent view니까 ! 이게 가능한거야!
    self.collectionView!.translatesAutoresizingMaskIntoConstraints = false
    self.collectionView!.snp.makeConstraints({ make in
      make.top.equalToSuperview()
      make.right.equalToSuperview()
      make.bottom.equalToSuperview().inset(self.tabBarController!.tabBar.frame.height)
      make.left.equalToSuperview()
    })
  }
  
  //  handler
  /* ------------------------------------ */
  
  //  delegate & datasource
  /* ------------------------------------ */
  /* CollectionView */
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return mSettings.sharedInstance.totalTeamCount!
  }
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell : TeamCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! TeamCell
    cell.teamLabel.text = "\(indexPath.row+1)"
    //기본적으로는 멈추자
    cell.stop()
    // 만약에 선택된 indexPath였다면, 그거는 계속 돌려줘야지~
    if let selectedItem = collectionView.getSelectedItemIndexPath() {
      if ( selectedItem.row == indexPath.row ) {
        cell.wating()
      }
    }
    //현재 그리려는 Cell이 우리팀 Cell이라면 테두리 색을 바꿔보자!
    if ( (indexPath.row+1) == mSettings.sharedInstance.ourTeam! ) {
      cell.contentView.layer.borderColor = UIColor.flatYellow.cgColor
    } else {
      cell.contentView.layer.borderColor = UIColor.flatBlack.cgColor
    }
    return cell
  }
  override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    let cell : TeamCell = collectionView.cellForItem(at: indexPath) as! TeamCell
    
    //이전에 돌고있는게 있었다면 거기서 스탑!
    if let selectedItem = collectionView.getSelectedItem() {
      (selectedItem as! TeamCell).stop()
    }
    cell.wating()
    let team: Int = indexPath.row + 1
    self.outListVC.currentTeam = team
    self.getPlayers(Of: team, CallBack: { _error, _players in
      if ( _error ) {
        self.alert.show(Message: "\(team)팀의 명단이 아직 다 입력되지 않았습니다", CallBack: { action in
          cell.stop()
        })
      } else {
        log.debug(["Players --> " , _players!])
        self.outListVC.currentTeam = team
        self.outListVC.players = _players
        self.navigationController?.pushViewController(self.outListVC, animated: true)
        cell.stop()
      }
    })
    return true
  }
  /* FlowLayout */
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = (view.frame.width/constants.count.cellInHorizontal) - 60
    return CGSize(width: width, height: constants.height.cell)
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    //64 --> Navigationbar(40) + StatusBar(20)
    return UIEdgeInsets(top: 40+64, left: 40, bottom: 40, right: 40)
  }
  
  //  custom
  /* ------------------------------------ */
  func getPlayers(Of _team: Int, CallBack _cb: @escaping (Bool, [mPlayer]?)->Void ) {
    let url = "\(BASE_URL)/out.php"
    let params : [String:Int] = ["team":_team, "get_players": 1] //1은 아무 의미 없고 그냥 인자값으로 날려주는거
    Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { response in
      if let result = response.result.value {
        let json = JSON(result)
        log.verbose(["json --> " , json])
        if (json["response_code"].intValue == 201) {
          // 이게 불안하기는 한데,,, 일단 냅둬보자 ! 그리고 CallBack을 이런식으로 작성하면 안되고, String으로 JSON전체를 넘겨줘야함!
          let playersJson = json["value"].arrayObject!
          let players : Array<mPlayer> = Mapper<mPlayer>().mapArray(JSONObject: playersJson)!
          _cb(false, players);
        } else {
          _cb(true, nil)
        }
      }
    })
  }
  
}
