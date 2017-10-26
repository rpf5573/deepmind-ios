//
//  WebViewController.swift
//  deepmind
//
//  Created by mac88 on 2017. 10. 21..
//  Copyright © 2017년 mac88. All rights reserved.
//

import UIKit
import SnapKit

class WebViewController : UIViewController {
	/* ------------------------------------------------------------------ */
	//  Property
	/* ------------------------------------------------------------------ */
	
	//  constant
	/* ------------------------------------ */
	
	//  view component
	/* ------------------------------------ */
	let webView : UIWebView = UIWebView(frame: .zero)
	
	//  data
	/* ------------------------------------ */
	
	/* ------------------------------------------------------------------ */
	//  Function
	/* ------------------------------------------------------------------ */
	
	// override & init & life cycle
	/* ------------------------------------ */
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
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
		self.view.backgroundColor = UIColor.white
		setupWebView()
	}
	func setupWebView() {
		self.view.addSubview(webView)
		webView.snp.makeConstraints({ make in
			make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
		})
	}
	
	//  handler
	/* ------------------------------------ */
	
	//  delegate & datasource
	/* ------------------------------------ */
	
	//  protocol
	/* ------------------------------------ */
	
	//  custom
	/* ------------------------------------ */
	func loadPage(Url _url : String) {
		log.verbose("called")
		if let url = URL(string: _url) {
			log.debug(url)
			webView.loadRequest(URLRequest(url: url))
		}
	}
}

