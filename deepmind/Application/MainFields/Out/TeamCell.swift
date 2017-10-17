//
//  TeamCell.swift
//  deepmind
//
//  Created by mac88 on 2017. 7. 8..
//  Copyright © 2017년 mac88. All rights reserved.
//

import UIKit
import SnapKit
import Spring
import ChameleonFramework
import NVActivityIndicatorView

class TeamCell : UICollectionViewCell {
  
  /* ------------------------------------------------------------------ */
  //  Property
  /* ------------------------------------------------------------------ */
  
  //  constant
  /* ------------------------------------ */
  
  //  view component
  /* ------------------------------------ */
  lazy var indicatorView : NVActivityIndicatorView = {
    let iv = NVActivityIndicatorView(frame: .zero)
    iv.translatesAutoresizingMaskIntoConstraints = false
    //iv.backgroundColor = UIColor.flatYellow
    iv.type = .ballBeat
    return iv
  }()
  lazy var teamLabel : UILabel = {
    let label : UILabel = UILabel()
    label.text = ""
    label.font = UIFont.systemFont(ofSize: 42, weight: 12)
    label.textColor = UIColor.flatBlackDark
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  //  data
  /* ------------------------------------ */
  
  
  /* ------------------------------------------------------------------ */
  //  Function
  /* ------------------------------------------------------------------ */
  
  //  life cycle
  /* ------------------------------------ */
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.addSubview(teamLabel)
    teamLabel.snp.makeConstraints({ make in
      make.center.equalToSuperview()
    })
    self.addSubview(indicatorView)
    indicatorView.snp.makeConstraints({ make in
      make.edges.equalToSuperview().inset(20)
    })
    indicatorView.isHidden = true
    
    self.contentView.layer.cornerRadius = 10.0
    self.contentView.layer.borderWidth = 2.0
    self.contentView.layer.borderColor = UIColor.flatBlackDark.cgColor
    self.contentView.layer.masksToBounds = true
    self.contentView.layer.backgroundColor = UIColor.flatWhite.cgColor
    
    self.layer.shadowColor = UIColor.flatBlack.cgColor
    self.layer.shadowOffset = CGSize(width: 0, height: 4.0)
    self.layer.shadowRadius = 6.0
    self.layer.shadowOpacity = 0.3
    self.layer.masksToBounds = false
    self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  //  custom
  /* ------------------------------------ */
  func wating() {
    self.teamLabel.isHidden = true
    self.indicatorView.isHidden = false
    self.indicatorView.startAnimating()
  }
  func stop() {
    self.indicatorView.stopAnimating()
    self.indicatorView.isHidden = true
    self.teamLabel.isHidden = false
  }

}
