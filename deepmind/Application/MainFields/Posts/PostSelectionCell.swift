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

class PostSelectionCell : SwipeTableViewCell {
  
  /* ------------------------------------------------------------------ */
  //  Property
  /* ------------------------------------------------------------------ */
  
  //  constant
  /* ------------------------------------ */
  struct constants {
    struct space {
      static let betweenLabels : CGFloat = 10
    }
    struct fontSize {
      static let postLabel : CGFloat = 18
      static let hostsOfPostLabel : CGFloat = constants.fontSize.postLabel*0.84
    }
  }
  
  //  view component
  /* ------------------------------------ */
  lazy var postLabel : UILabel = {
    let label = UILabel()
    label.textAlignment = NSTextAlignment.left
    label.font = UIFont.systemFont(ofSize: constants.fontSize.postLabel)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  lazy var hostsOfPostLabel : UILabel = {
    let label = UILabel()
    label.textAlignment = NSTextAlignment.center
    label.font = UIFont.systemFont(ofSize: constants.fontSize.hostsOfPostLabel)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
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
    let horizontalStackView = makeHorizontalStackView()
    horizontalStackView.spacing = 10.0
    horizontalStackView.backgroundColor = UIColor.flatYellow
    horizontalStackView.addArrangedSubview(postLabel)
    horizontalStackView.addArrangedSubview(hostsOfPostLabel)
    
    self.addSubview(horizontalStackView)
    horizontalStackView.snp.makeConstraints({ make in
      make.edges.equalToSuperview()
    })
    postLabel.snp.makeConstraints({ make in
      make.top.equalToSuperview()
      make.left.equalToSuperview()
      make.bottom.equalToSuperview()
    })
    hostsOfPostLabel.snp.makeConstraints({ make in
      make.top.equalToSuperview()
      make.right.equalToSuperview()
      make.bottom.equalToSuperview()
    })
  }
  
  //  custom
  /* ------------------------------------ */
  func makeHorizontalStackView() -> UIStackView {
    let horizontalStackView = UIStackView()
    horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
    horizontalStackView.axis = UILayoutConstraintAxis.horizontal
    return horizontalStackView
  }
  func dim() {
    self.backgroundColor = UIColor.flatWhiteDark
    self.layer.opacity = 0.64
  }
  func clear() {
    self.backgroundColor = UIColor.white
    self.layer.opacity = 1.0
  }
}
