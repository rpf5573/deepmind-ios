//
//  Fields.swift
//  deepmind
//
//  Created by mac88 on 2017. 7. 5..
//  Copyright © 2017년 mac88. All rights reserved.
//

import UIKit
import SwiftSpinner
import SwiftyJSON
import Alamofire

class MainFieldsTabBarController : UITabBarController, ESTBeaconManagerDelegate, ESTBeaconConnectionDelegate {
	
	/* ------------------------------------------------------------------ */
	//  Property
	/* ------------------------------------------------------------------ */
	
	//  constant
	/* ------------------------------------ */
	
	//  view component
	/* ------------------------------------ */
	lazy var alert : Alert = { return Alert(ViewController: UIApplication.shared.keyWindow!.rootViewController!) }()
	lazy var webViewController : WebViewController = WebViewController()
	
	
	//  data
	/* ------------------------------------ */
	let beaconManager : ESTBeaconManager = ESTBeaconManager()
	let region : CLBeaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "myRegion")
	var currentPost : Int = 0;
	

	/* ------------------------------------------------------------------ */
	//  Function
	/* ------------------------------------------------------------------ */
	
	// override & init & life cycle
	/* ------------------------------------ */
	override func viewDidLoad() {
		super.viewDidLoad()
		
		log.debug( mSettings.sharedInstance.beaconInfos )
		
		self.setup()
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	//  setup
	/* ------------------------------------ */
	func setup() {
		self.title = "딥마인드"
		if ( mSettings.sharedInstance.options.beacon ) {
			let btn : UIBarButtonItem = UIBarButtonItem(title: "무인미션찾기", style: .plain, target: self, action: #selector(self.handleSearchBeacon))
			self.navigationItem.setRightBarButton(btn, animated: true)
		}
		
	}
	
	//  handler
	/* ------------------------------------ */
	func handleSearchBeacon() {
		log.verbose("called")
		guard let _ = mSettings.sharedInstance.beaconInfos else {
			log.error("비콘 정보 없음")
			alert.error(Message: "비콘 데이타가 없습니다", CallBack: nil)
			return
		}
		if ( !beaconManager.isAuthorizedForMonitoring() ) {
			beaconManager.requestAlwaysAuthorization()
		} else {
			SwiftSpinner.show("무인 미션 찾는중...").addTapHandler({
				SwiftSpinner.hide({
					self.stopFindingBeacon()
				})
			}, subtitle: "화면을 탭하시면 미션찾기를 중단합니다")
			getCurrentPost(AndThen: { json in
				if ( json["response_code"].intValue == 201 ) {
					self.startFindingBeacon(post: json["value"].intValue)
				} else {
					self.alert.show(Message: json["error_message"].stringValue, CallBack: { _ in
						self.stopFindingBeacon()
						SwiftSpinner.hide()
					})
				}
			})
		}
	}
	
	//  delegate & datasource
	/* ------------------------------------ */
	/* Estimote Delegate */
	func beaconManager(_ manager: Any, didStartMonitoringFor region: CLBeaconRegion) {
		log.verbose("called")
	}
	func beaconManager(_ manager: Any, didEnter region: CLBeaconRegion) {
		log.verbose("called")
	}
	func beaconManager(_ manager: Any, didFailWithError error: Error) {
		log.error(error.localizedDescription)
	}
	func beaconConnectionDidSucceed(_ connection: ESTBeaconConnection) {
		log.verbose("called")
	}
	func beaconManager(_ manager: Any, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
		guard beacons.count > 0 else {
			log.error("No Beacon Founded")
			return
		}
		let nearestBeacon : CLBeacon = beacons[0]
		let minor : Int = nearestBeacon.minor.intValue
		if ( nearestBeacon.proximity.rawValue <= 2 ) {
			log.debug(minor)
			if ( minor == (currentPost + 100) ) {
				SwiftSpinner.hide({
					if let nc = self.navigationController {
						self.stopFindingBeacon()
						nc.pushViewController(self.webViewController, animated: true)
						log.debug( mSettings.sharedInstance.beaconInfos )
						if let beaconInfos = mSettings.sharedInstance.beaconInfos {
							beaconInfos.forEach({ beaconInfo in
								log.debug( beaconInfo.item )
								log.debug( beaconInfo.post )
								log.debug( beaconInfo.url )
								log.debug( self.currentPost )
								if ( beaconInfo.post == self.currentPost ) {
									self.webViewController.loadPage(Url: beaconInfo.url)
								}
							})
						}
					} else {
						log.error(" There is no navigation Controller ")
					}
				})
			}
		}
	}
	
	
	//  protocol
	/* ------------------------------------ */
	
	//  custom
	/* ------------------------------------ */
	func getCurrentPost(AndThen _cb: @escaping (JSON)->Void) {
		let ourTeam = mSettings.sharedInstance.ourTeam!
		let url = "\(BASE_URL)/post.php"
		let params : [String:Any] = ["get_current_post":true, "team":ourTeam]
		Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { response in
			log.debug(["Response --> " , response])
			if let result = response.result.value {
				let json = JSON(result)
				_cb(json)
			}
		})
	}
	func startFindingBeacon(post : Int) {
		log.verbose("called")
		self.currentPost = post;
		beaconManager.delegate = self
		beaconManager.startRangingBeacons(in: region)
	}
	func stopFindingBeacon() {
		log.verbose("called")
		beaconManager.delegate = nil
		beaconManager.stopRangingBeaconsInAllRegions()
	}

}
