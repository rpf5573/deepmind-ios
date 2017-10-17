//
//  JokerRegister.swift
//  deepmind
//
//  Created by mac88 on 2017. 7. 5..
//  Copyright © 2017년 mac88. All rights reserved.
//

import UIKit
import SnapKit
import Spring
import SkyFloatingLabelTextField

class JokerRegisterViewController : UIViewController, UITextFieldDelegate {
  
  /* ------------------------------------------------------------------ */
  //  Property
  /* ------------------------------------------------------------------ */
  
  //  constant
  /* ------------------------------------ */
  struct constants {
    struct space {
      static let base : CGFloat = 20
      static let jokerRegisterView : CGFloat = 60
      static let jokerHorizontalStackView : CGFloat = constants.space.base
    }
    struct height {
      static let skyTextField : CGFloat = 36
      static let completeBtn : CGFloat = 40
    }
    struct width {
      static let jokerInfoBtn : CGFloat = 80
    }
  }
  
  //  view component
  /* ------------------------------------ */
  lazy var completeBtn: SpringButton = {
    let btn : SpringButton = SpringButton()
    btn.translatesAutoresizingMaskIntoConstraints = false;
    btn.setTitle("입력 완료", for: .normal)
    btn.setTitleColor(UIColor.white, for: .normal)
    btn.backgroundColor = Colors.mayaBlue
    btn.addTarget(self, action: #selector(self.handleCompleteBtn(Button:)), for: UIControlEvents.touchUpInside)
    return btn
  }()
  lazy var jokerRegisterView : UIStackView = {
    let sv : UIStackView = UIStackView()
    sv.axis = UILayoutConstraintAxis.vertical
    sv.spacing = constants.space.jokerRegisterView
    return sv
  }()
  
  //  data
  /* ------------------------------------ */
  var jokerRegisterTextFields : [SkyFloatingLabelTextField] = []
  var jokerInfoRegisterVC : JokerInfoRegisterViewController = JokerInfoRegisterViewController()
  static var currentJokerInfoOrder : Int = 1
  
  
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
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated);
    log.verbose("called")
  }
  
  //  setup
  /* ------------------------------------ */
  func setup() {
    //빈 화면 누르면 키보드 내려감~
    self.view.setHideKeyboard()
    setupHorizontalJokerStackView()
    setupCompleteBtn()
    if ( mSettings.sharedInstance.options.jokerInfo! ) {
      setupJokerRegisterView()
    }
  }
  func setupHorizontalJokerStackView() {
    for i in 0..<2 {
      let position = i+1
      let sv : UIStackView = makeHorizontalStackView()
      sv.spacing = constants.space.jokerHorizontalStackView
      let skyTF : SkyFloatingLabelTextField = makeSkyTextField(At: position)
      
      sv.addArrangedSubview(skyTF)
      
      skyTF.snp.makeConstraints({ make in
        make.left.equalToSuperview()
        make.top.equalToSuperview()
        make.bottom.equalToSuperview()
        make.right.equalToSuperview()
      })
      
      if ( mSettings.sharedInstance.options.jokerInfo!) {
        let infoBtn : SpringButton = SpringButton()
        infoBtn.translatesAutoresizingMaskIntoConstraints = false;
        infoBtn.setTitle("정보입력", for: .normal)
        infoBtn.setTitleColor(UIColor.white, for: .normal)
        infoBtn.backgroundColor = Colors.mayaBlue
        infoBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        infoBtn.tag = position
        infoBtn.addTarget(self, action: #selector(handleJokerInfoBtn(Button:)), for: UIControlEvents.touchUpInside)
        sv.addArrangedSubview(infoBtn)
        infoBtn.snp.makeConstraints({ make in
          make.right.equalToSuperview()
          make.top.equalToSuperview()
          make.bottom.equalToSuperview()
          make.width.equalTo(constants.width.jokerInfoBtn)
        })
        
        skyTF.snp.makeConstraints({ make in
          make.right.equalTo(infoBtn.snp.left)
        })
      }
      
      self.jokerRegisterView.addArrangedSubview(sv)
      sv.snp.makeConstraints({ make in
        make.left.equalToSuperview()
        make.right.equalToSuperview()
      })
    }
  }
  func setupJokerRegisterView() {
    self.view.addSubview(jokerRegisterView)
    jokerRegisterView.snp.makeConstraints({ make in
      make.centerY.equalToSuperview().multipliedBy(0.8)
      make.centerX.equalToSuperview()
      make.left.equalToSuperview().inset(constants.space.base)
      make.right.equalToSuperview().inset(constants.space.base)
    })
  }
  func setupCompleteBtn() {
    self.view.addSubview(completeBtn)
    completeBtn.snp.makeConstraints({ make in
      make.bottom.equalToSuperview().inset(20)
      make.left.equalToSuperview().inset(20)
      make.right.equalToSuperview().inset(20)
      make.height.equalTo(constants.height.completeBtn)
    })
  }
  
  //  handler
  /* ------------------------------------ */
  func handleJokerInfoBtn(Button _btn: SpringButton) {
    presentJokerInfoRegisterVC(Order: _btn.tag)
  }
  func handleCompleteBtn(Button _btn: SpringButton) {
    log.verbose("called")
    _btn.animation = "pop"
    _btn.force = 0.1
    _btn.animate()
    NotificationCenter.default.post(name: NotificationName.RegisterRequest, object: nil)
  }
  
  //  delegate & datasource
  /* ------------------------------------ */
  /* TextField */
  func textFieldDidEndEditing(_ textField: UITextField) {
    let skyTextField = textField as! SkyFloatingLabelTextField
    if let text = skyTextField.text {
      skyTextField.validate(Name: text, Limit: 5)
    }
  }
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let skyTextField = textField as! SkyFloatingLabelTextField
    guard let oldText = skyTextField.text else {
      return false
    }
    if(string.lengthOfBytes(using: String.Encoding.utf8) > 1){
      let newText = "\(oldText)\(string)"
      skyTextField.validate(Name: newText, Limit: 5)
    } else {
      skyTextField.errorMessage = nil
    }
    return true;
  }
  
  //  custom
  /* ------------------------------------ */
  func presentJokerInfoRegisterVC(Order _order: Int) {
    jokerInfoRegisterVC.currentOrder = _order
    self.present(jokerInfoRegisterVC, animated: true, completion: { finish in
      log.verbose("called")
    })
  }
  func makeSkyTextField( At _position: Int ) -> SkyFloatingLabelTextField {
    //높이만 defalt로 정해놓자구요!
    let rect = CGRect(x: 0, y: 0, width: 0, height: constants.height.skyTextField)
    let skyTF = SkyFloatingLabelTextField(frame: rect)
    skyTF.translatesAutoresizingMaskIntoConstraints = false
    skyTF.textAlignment = NSTextAlignment.center
    skyTF.font = UIFont(name: "HelveticaNeue-Light", size: 20)
    skyTF.tag = _position
    skyTF.autocorrectionType = .no
    skyTF.placeholder = "조커 \(_position)"
    skyTF.title = "조커 \(_position)"
    self.jokerRegisterTextFields.append(skyTF)
    skyTF.delegate = self
    return skyTF
  }
  func makeHorizontalStackView() -> UIStackView {
    let horizontalStackView = UIStackView()
    horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
    horizontalStackView.axis = UILayoutConstraintAxis.horizontal
    return horizontalStackView
  }
}
