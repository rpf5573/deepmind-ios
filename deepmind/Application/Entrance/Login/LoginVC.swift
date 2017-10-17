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

class LoginVC : UIViewController {
  
  /* ------------------------------------------------------------------ */
  //  Property
  /* ------------------------------------------------------------------ */
  
  //  constant
  /* ------------------------------------ */
  struct constants {
    struct space {
      static let base : CGFloat = 20
    }
    struct height {
      static let loginBtn : CGFloat = 40
      static let loginTextField : CGFloat = constants.height.loginBtn
      static let loginStackView : CGFloat = 100
    }
  }
  
  //  view component
  /* ------------------------------------ */
  var loginStackView : UIStackView = {
    let sv : UIStackView = UIStackView()
    sv.translatesAutoresizingMaskIntoConstraints = false
    return sv
  }()
  let loginTextField : UITextField = {
    let textField = UITextField()
    textField.placeholder = "비밀번호를 입력해 주세요"
    textField.backgroundColor = UIColor.white
    textField.font = UIFont.systemFont(ofSize: 15)
    textField.autocorrectionType = UITextAutocorrectionType.no
    textField.keyboardType = UIKeyboardType.numberPad
    textField.returnKeyType = UIReturnKeyType.done
    textField.clearButtonMode = UITextFieldViewMode.whileEditing
    textField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
    textField.textAlignment = NSTextAlignment.center
    return textField
  }()
  let loginBtn : SpringButton = {
    let btn : SpringButton = SpringButton()
    btn.translatesAutoresizingMaskIntoConstraints = false;
    btn.setTitle("완료", for: .normal)
    btn.setTitleColor(UIColor.white, for: .normal)
    btn.backgroundColor = Colors.mayaBlue
    return btn;
  }()
  
  //  data
  /* ------------------------------------ */
  lazy var alert : Alert = Alert(ViewController: self)
  
  
  /* ------------------------------------------------------------------ */
  //  Function
  /* ------------------------------------------------------------------ */
  
  //  life cycle
  /* ------------------------------------ */
  override func viewDidLoad() {
    super.viewDidLoad();
    log.verbose("called")
    self.view.setHideKeyboard() //화면을 누르면 키보드가 내려가도록 설정해 놓습니다
    self.view.backgroundColor = UIColor.flatWhite
    setup()
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated);
    log.verbose("called")
    
    // MemberVC에서 Keyboard Height이 필요하기 때문에 여기서 미리 구해놓습니다
    NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated);
    log.verbose("called")
  }
  override func viewWillDisappear(_ animated: Bool) {
    //Keyboard Notification을 제거해 줍니다!
    NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
  }
  
  //  setup
  /* ------------------------------------ */
  func setup() {
    setupLoginStackView()
  }
  func setupLoginStackView() {
    log.verbose( "called" )
    self.view.addSubview(loginStackView)
    loginStackView.axis = UILayoutConstraintAxis.vertical
    loginStackView.addArrangedSubview(loginTextField)
    loginStackView.addArrangedSubview(loginBtn)
    loginBtn.addTarget(self, action: #selector(handleLogin(btn:)), for: .touchUpInside)
    loginStackView.snp.makeConstraints { (make) -> Void in
      make.center.equalTo(self.view)
      make.height.equalTo(constants.height.loginStackView)
      make.left.equalTo(self.view).inset(constants.space.base)
      make.right.equalTo(self.view).inset(constants.space.base)
    }
    self.loginBtn.snp.makeConstraints { (make) -> Void in
      make.height.equalTo(constants.height.loginBtn)
    }
    self.loginTextField.snp.makeConstraints { (make) -> Void in
      make.height.equalTo(constants.height.loginTextField)
    }
    loginStackView.spacing = constants.space.base
  }
  
  //  handler
  /* ------------------------------------ */
  func handleLogin(btn: SpringButton) {
    log.verbose( "called" )
    btn.animation = "pop"
    btn.force = 0.1
    btn.animate()
    self.view.dismissKeyboard()
    
    //비밀번호 체크!
    if let password = loginTextField.text {
      SwiftSpinner.show("Login...")
      let params : [String : Any] = ["password" : password]
      Alamofire.request("\(BASE_URL)/login.php", method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { response in
        log.verbose(["Alamofire response --> " , response])
        if let json_string = response.result.value {
          SwiftSpinner.hide()
          let json = JSON( json_string )
          log.verbose(["login response code --> " , json["response_code"].intValue])
          if let response_code = json["response_code"].int {
            switch ( response_code ) {
            case 201, 202, 203: //비밀번호 일치
              log.verbose(["response_code --> " , "201,202,203"])
              mSettings(JSONString: json["value"].rawString()!)
              switch response_code {
              case 201: //처음 로그인
                log.verbose(["response_code --> " , 201])
                if let window = UIApplication.shared.keyWindow {
                  self.alert.show(Message: json["success_message"].stringValue, CallBack: { (action)in
                    if ( mSettings.sharedInstance.options.playerList! ) {
                      window.moveTo(VC: .PlayerRegister)
                    } else {
                      window.moveTo(VC: .MainFields)
                    }
                  })
                }
                break
              case 202: //아까 정보 다 입력하고 , 잠깐 앱 껏다가 다시 키고 들어온 상황.
                log.verbose(["response_code --> " , 202])
                if let window = UIApplication.shared.keyWindow {
                  self.alert.show(Message: json["success_message"].stringValue, CallBack: { (action)in
                    window.moveTo(VC: .MainFields)
                  })
                }
                break
              case 203:
                log.verbose(["response_code --> " , 203])
                break
              default:break
              }
            case 401, 402, 403, 404, 405, 406, 407: // 에러발생
              self.alert.show(Message: json["error_message"].stringValue, CallBack: nil)
              
            default:break
            }
          }
        }
      })
    } else {
      Alert(ViewController: self).show(Message: "비밀번호를 입력해 주세요", CallBack: nil)
    }
  }
  func handleKeyboardWillShow(notification: NSNotification) {
    let userInfo = notification.userInfo!
    keyBoardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
  }
}
