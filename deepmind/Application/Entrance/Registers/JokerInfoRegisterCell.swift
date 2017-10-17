//
//  InfoCell.swift
//  deepmind
//
//  Created by mac88 on 2017. 7. 7..
//  Copyright © 2017년 mac88. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SnapKit

class JokerInfoRegisterCell : UITableViewCell, UITextFieldDelegate {
  
  /* ------------------------------------------------------------------ */
  //  Property
  /* ------------------------------------------------------------------ */
  
  //  view component
  /* ------------------------------------ */
  lazy var jokerInfoRegisterTextField : SkyFloatingLabelTextField = {
    let rect = CGRect(x: 0, y: 0, width: 0, height: 36)
    let skyTF = SkyFloatingLabelTextField(frame: rect)
    skyTF.translatesAutoresizingMaskIntoConstraints = false
    skyTF.textAlignment = NSTextAlignment.left
    skyTF.font = UIFont(name: "HelveticaNeue-Light", size: 18)
    skyTF.autocorrectionType = .no
    skyTF.delegate = self
    return skyTF
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
    fatalError("init(coder:) has not been implemented")
  }
  
  //  setup
  /* ------------------------------------ */
  func setup() {
    log.verbose("called")
    self.addSubview(jokerInfoRegisterTextField)
    jokerInfoRegisterTextField.snp.makeConstraints({ make in
      make.right.equalToSuperview()
      make.left.equalToSuperview()
      make.bottom.equalToSuperview()
    })
  }
  
  //  delegate & datasource
  /* ------------------------------------ */
  /* TextField */
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    log.verbose("called")
    //글자 입력할때는 , Error을 없애줘야해!! 좀 귀찮지만 어쩔 수 없음~
    jokerInfoRegisterTextField.errorMessage = nil
    return true
  }
  
}
