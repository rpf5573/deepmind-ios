//
//  Alert.swift
//  AlphagoDeepMind
//
//  Created by mac88 on 2016. 12. 27..
//  Copyright © 2016년 mac88. All rights reserved.
//

import UIKit

class Alert {
  
  private var viewController : UIViewController!
  
  init(ViewController _vc: UIViewController) {
    self.viewController = _vc
  }
  
  func show(Message _message: String, CallBack _cb : ((UIAlertAction)->Void)?){
    let alert = UIAlertController(title: "알림", message: _message, preferredStyle: UIAlertControllerStyle.alert)
    let action = UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: _cb)
    alert.addAction(action)
    self.viewController.present(alert, animated: true, completion: nil)
  }
  
  func error(Message _message: String, CallBack _cb : ((UIAlertAction)->Void)?){
    let alert = UIAlertController(title: "", message: _message, preferredStyle: UIAlertControllerStyle.alert)
    
    alert.setValue(NSAttributedString(string: _message, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17),NSForegroundColorAttributeName : UIColor.red]), forKey: "attributedMessage")
    
    let action = UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: _cb)
    alert.addAction(action)
    self.viewController.present(alert, animated: true, completion: nil)
  }
  
  func approval(Title _title: String, OKTitle _oktitle: String, NOTitle _notitle: String, Message _message: String, DidOKBtnClick _okcb : ((UIAlertAction)->Void)?, DidNOBtnClick _nocb: ((UIAlertAction)->Void)?, DidAlertOpen _opencb : (()->Void)?){
    
    let alertController = UIAlertController(title: _title, message: _message, preferredStyle: .alert)
    // Create OK button
    let OKAction = UIAlertAction(title: _oktitle, style: .default) { (action:UIAlertAction!) in
      _okcb!(action)
    }
    alertController.addAction(OKAction)
    // Create Cancel button
    let cancelAction = UIAlertAction(title: _notitle, style: .destructive) { (action:UIAlertAction!) in
      _nocb!(action)
    }
    alertController.addAction(cancelAction)
    // Present Dialog message
    self.viewController.present(alertController, animated: true, completion:nil)
  }
  
  func sheet(Title _title: String, Message _message: String, Btn1Title _btn1Title: String,
                 Btn1CallBack _btn1Callback:@escaping ((UIAlertAction)->Void), Btn2title _btn2Title: String, Btn2CallBack _btn2Callback:@escaping ((UIAlertAction)->Void), BtnCancelTitle _btnCancelTitle: String ) {
    
    let alertController = UIAlertController(title: _title, message: _message, preferredStyle: .actionSheet)
    
    let btn1 = UIAlertAction(title: _btn1Title, style: .default, handler: _btn1Callback)
    
    let btn2 = UIAlertAction(title: _btn2Title, style: .default, handler: _btn2Callback)
    
    let cancelButton = UIAlertAction(title: _btnCancelTitle, style: .cancel, handler: { (action) -> Void in
      
    })
    
    alertController.addAction(btn1)
    alertController.addAction(btn2)
    alertController.addAction(cancelButton)
    
    self.viewController.present(alertController, animated: true, completion: nil)
  }
}
