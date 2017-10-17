//
//  PlayerCell.swift
//  deepmind
//
//  Created by mac88 on 2017. 7. 8..
//  Copyright © 2017년 mac88. All rights reserved.
//

import UIKit
import SnapKit
import CustomSwipeCellKit

class PlayerCell : SwipeTableViewCell {
  
  /* ------------------------------------------------------------------ */
  //  Property
  /* ------------------------------------------------------------------ */
  
  //  view component
  /* ------------------------------------ */
  lazy var outView : UIView = {
    let view = UIView()
    //view.backgroundColor = UIColor.flatWhite
    view.backgroundColor = UIColor.flatWhite.withAlphaComponent(0.85)
    view.isOpaque = false
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    return view
  }()
  lazy var outImageView : UIImageView = {
    let imageView : UIImageView = UIImageView()
    imageView.contentMode = UIViewContentMode.scaleToFill
    imageView.image = UIImage(named: "test1.png")
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()

  
  /* ------------------------------------------------------------------ */
  //  Function
  /* ------------------------------------------------------------------ */
  
  //  life cycle
  /* ------------------------------------ */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    log.verbose("called")
    setup()
  }
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    log.verbose("called")
  }
  
  //  setup
  /* ------------------------------------ */
  func setup() {
    self.selectionStyle = .none
    setupOutView()
  }
  func setupOutView() {
    self.outView.addSubview(outImageView)
    outImageView.snp.makeConstraints({ make in
      make.center.equalToSuperview()
    })
    self.addSubview(outView)
    outView.snp.makeConstraints({ make in
      make.edges.equalToSuperview()
    })
  }
  
  //  custom
  /* ------------------------------------ */
  func showOutView() {
    self.outView.isHidden = false
  }
  func hideOutView() {
    self.outView.isHidden = true
  }
}
