//
//  memberRegister.swift
//  deepmind
//
//  Created by mac88 on 2017. 7. 5..
//  Copyright © 2017년 mac88. All rights reserved.
//

import UIKit
import SnapKit
import SkyFloatingLabelTextField

class MemberRegisterViewController : UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
  
  /* ------------------------------------------------------------------ */
  //  Property
  /* ------------------------------------------------------------------ */
  
  //  constants
  /* ------------------------------------ */
  struct constants {
    struct height {
      static let skyTextField : CGFloat = 36
    }
  }
  
  //  view components
  /* ------------------------------------ */
  lazy var memberRegisterScrollView : UIScrollView = {
    let sv = UIScrollView(frame: self.view.frame)
    sv.delegate = self
    sv.translatesAutoresizingMaskIntoConstraints = false
    sv.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
    return sv
  }()
  lazy var memberRegisterStackView : UIStackView = {
    let mlsv : UIStackView = UIStackView(frame: self.view.frame)
    mlsv.translatesAutoresizingMaskIntoConstraints = false
    mlsv.axis = UILayoutConstraintAxis.vertical
    return mlsv
  }()
  var memberRegisterTextFields : [SkyFloatingLabelTextField] = []
  
  
  /* ------------------------------------------------------------------ */
  //  Functions
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

    // Keyboard가 TextField를 가리지 않도록 Notification을 달아주고 handler에서 처리해 준다
    NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated);
    log.verbose("called")
    //빈 화면을 누르면, 키보드가 내려감!
    self.view.setHideKeyboard()
  }
  
  //  setups
  /* ------------------------------------ */
  func setup() {
    setupmemberRegisterScrollView()
    setupmemberRegisterStackView()
  }
  func setupmemberRegisterScrollView() {
    self.view.addSubview(memberRegisterScrollView)
    self.memberRegisterScrollView.snp.makeConstraints({ (make) in
      make.edges.equalToSuperview()
    })
  }
  func setupmemberRegisterStackView() {
    self.memberRegisterScrollView.addSubview(memberRegisterStackView)
    memberRegisterStackView.snp.makeConstraints({ (make) in
      make.width.equalToSuperview().inset(20)
      make.top.equalToSuperview().inset(20)
      make.right.equalToSuperview().inset(20)
      make.bottom.equalToSuperview()
      make.left.equalToSuperview().inset(20)
    })
    memberRegisterStackView.spacing = 20
    
    let memberCount = mSettings.sharedInstance.getOurTeamPlayerCount() - 2 //조커 2명을 빼줘야함!
    for _ in 0 ..< (memberCount/2) {
      //position * 2를 하는 이유는 -> 받는쪽에서 짝수만 받기 때문이다. 0, 2, 4..이런식으로 보내면, 받는쪽에서는 , (0,1) , (2,3), (4,5) 이렇게 뿌려주기 때문이지!
      let filledHorizontalmemberRegister = makeHorizontalPlayerRegister(isLast: false)
      //horizontal Stack View를 Vertical Stack View에 붙여봅시다.
      self.memberRegisterStackView.addArrangedSubview(filledHorizontalmemberRegister)
      filledHorizontalmemberRegister.snp.makeConstraints({ (make) in
        make.left.equalToSuperview()
        make.right.equalToSuperview()
      })
    }
    //teamPlayerCount가 홀수라서 마지막으로 한명 더 추가 해야한다면!
    if ( memberCount%2 == 1 ) {
      log.verbose(["마지막 여행 --> " , "called"])
      //memberCount - 1을 하는 이유는 -> 받는쪽에서 position + i + 1을 하는데,그냥 memberCount를 넣어버리면, memberCount + 0(isLast가 true니까 1은 되지 않는다) + 1 이 되어버려서, 문제가 발생한다
      let filledHorizontalmemberRegister = makeHorizontalPlayerRegister(isLast: true)
      memberRegisterStackView.addArrangedSubview(filledHorizontalmemberRegister)
    }
  }
  
  //  handlers
  /* ------------------------------------ */
  func handleKeyboardWillShow(notification: NSNotification) {
    log.verbose("called")
    // 스크롤뷰의 아래에 여분을 주자!
  }
  func handleKeyboardWillHide(notification: NSNotification) {
    log.verbose("called")
    // 스크롤뷰의 아래에 여분을 없애자!
  }
  
  //  delegate & datasource
  /* ------------------------------------ */
  
  /* TextField */
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    log.verbose("called")
    if ( textField.tag != memberRegisterTextFields.count ) {
      let nextIndex = textField.tag //position으로 설정해놔서 +1되어있음
      memberRegisterTextFields[nextIndex].becomeFirstResponder()
    }
    return true
  }
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    log.verbose("called")
    // 계산식 : ( keyboardHeight - ( (offset.y + view.height) - the_view.frame.y ) ) + skyTextFieldHeight.superView.height
    let scrollViewMovingDistance = keyBoardHeight - ( ( memberRegisterScrollView.contentOffset.y + self.view.frame.height ) - textField.superview!.frame.origin.y ) + textField.superview!.frame.height + 36
    
    if ( scrollViewMovingDistance > 0 ) {
      let originalOffset = memberRegisterScrollView.contentOffset
      let newOffset = CGPoint(x: originalOffset.x, y: originalOffset.y + scrollViewMovingDistance)
      memberRegisterScrollView.setContentOffset(newOffset, animated: true)
    }
    //재미있는 점은 , offset이 contentSize를 넘어섰을때, bounce되면서 내려온다!! 그래서 내가 직접 offset을 원상복귀 안시켜줘도됨 ㅇㅋ 개이득
    return true
  }
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
  func makeHorizontalPlayerRegister( isLast _isLast: Bool ) -> UIStackView {
    let horizontalStackView = makeHorizontalStackView(Spacing: 20)
    for i in 0 ..< 2 {
      let position = memberRegisterTextFields.count + 1
      let skyTextField = makeSkyTextField(At: position)
      horizontalStackView.addArrangedSubview(skyTextField)
      skyTextField.snp.makeConstraints({ (make) in
        if ( i == 0 ) {
          make.left.equalToSuperview()
        } else {
          make.right.equalToSuperview()
        }
        make.top.equalToSuperview()
        make.bottom.equalToSuperview()
      })
      //요게 중요합니다! 이걸로 누적 개수를 알아낼 수 있음
      
      //마지막으로 더하는 것이라면~
      if ( _isLast ) {
        let emptyView = UIView()
        horizontalStackView.addArrangedSubview(emptyView)
        return horizontalStackView
      }
    }
    return horizontalStackView
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
    skyTF.placeholder = "맴버 \(_position)"
    skyTF.title = "맴버 \(_position)"
    memberRegisterTextFields.append(skyTF)
    skyTF.delegate = self
    return skyTF
  }
  func makeHorizontalStackView( Spacing _spacing: CGFloat ) -> UIStackView {
    let horizontalStackView = UIStackView()
    horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
    horizontalStackView.axis = UILayoutConstraintAxis.horizontal
    horizontalStackView.spacing = _spacing
    horizontalStackView.distribution = UIStackViewDistribution.fillEqually
    return horizontalStackView
  }
}
