//
//  MediaAccess.swift
//  deepmind
//
//  Created by mac88 on 2017. 7. 10..
//  Copyright © 2017년 mac88. All rights reserved.
//

import AVFoundation
import MobileCoreServices
import Photos
import UIKit

class AccessManager : NSObject {
  
  /* ------------------------------------------------------------------ */
  //  Property
  /* ------------------------------------------------------------------ */
  
  //  enum
  /* ------------------------------------ */
  enum AccessType {
    case picture
    case video
    case microphone
    case photolibrary
  }
  enum Status {
    case granted
    case denied
    case notDetermind
  }
  
  //  data
  /* ------------------------------------ */
  var context : UIViewController!
  lazy var alert : Alert = { return Alert(ViewController: self.context) }()
  lazy var imagePicker : UIImagePickerController = {
    let ip : UIImagePickerController = UIImagePickerController()
    ip.videoMaximumDuration = 60.0 // 카메라 촬영 최장시간을 60초로 한다!
    ip.modalPresentationStyle = .overCurrentContext
    ip.allowsEditing = false
    ip.sourceType = UIImagePickerControllerSourceType.camera
    ip.delegate = self.context as! (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?;
    return ip
  }()
  
  
  /* ------------------------------------------------------------------ */
  //  Function
  /* ------------------------------------------------------------------ */
  
  // init & life cycle
  /* ------------------------------------ */
  override init() {
    super.init()
  }
  convenience init(ViewController _vc: UIViewController){
    self.init()
    if _vc is (UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
      self.context = _vc
    }else{
      log.error("Protocol Error")
    }
  }
  
  //  custom
  /* ------------------------------------ */
  // 만약에 사용자가 Media Access를 거부했다면, 설정창에서 ON 할 수 있도록 설정창으로 가는 버튼을 뿌려줍니다!   iOS9 에서 iOS10으로 넘어갈때 이 부분이 바뀌었는데, iOS11에서는 변하지 않았으면 좋겠다~
  func alertToAllowAccessViaSetting(Message _message: String) {
    let alert = UIAlertController(
      title: "IMPORTANT",
      message: _message,
      preferredStyle: UIAlertControllerStyle.alert
    )
    alert.addAction(UIAlertAction(title: "취소", style: .default, handler: nil))
    alert.addAction(UIAlertAction(title: "허용", style: .cancel, handler: { (alert) -> Void in
      if let url : URL = URL(string: UIApplicationOpenSettingsURLString) {
        if #available(iOS 10.0, *) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
          if(UIApplication.shared.canOpenURL(url)){
            UIApplication.shared.openURL(url)
          }
        }
      }
    }))
    context.present(alert, animated: true, completion: nil)
  }
  // 처음에 사용자가 Media Access를 OFF 또는 ON하기 전에! 맨 처음에 물어보는 역할을 합니다. " 미디어 자원을 사용해도 될까요??? "
  func alertToRequestAccess(Message _message: String, Type _type: AccessType) {
    switch _type {
    case .picture, .video:
      var devices : [AVCaptureDevice] = []
      if #available(iOS 10.0, *) {
        devices = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: AVCaptureDevicePosition.unspecified).devices
      } else {
        devices.append(AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo))
      }
      // 사용할 수 있는 카메라가 있다면 , ( 근데, 사용할 수 없는 카메라도 있니? )
      if devices.count > 0 {
        // Access를 request합니다
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { result in
          DispatchQueue.main.async(execute: {
            self.request(Of: _type)
          })
        })
      }
      break;
    case .photolibrary:
      PHPhotoLibrary.requestAuthorization({
        status in
        DispatchQueue.main.async(execute: {
          self.request(Of: _type)
        })
      })
    case .microphone:
      AVAudioSession.sharedInstance().requestRecordPermission({
        result in
        DispatchQueue.main.async(execute: {
          self.request(Of: _type)
        })
      })
      break
    }
  }
  func request(Of _type: AccessType) {
    log.verbose("called")
    switch _type {
    case .picture, .video:
      let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
      switch authStatus {
      case .authorized: self.call(Of: _type);
      case .denied: alertToAllowAccessViaSetting(Message: "설정창에서 허용을 해주세요")
      case .notDetermined: alertToRequestAccess(Message: "카메라 사용이 필요합니다", Type: _type)
      case .restricted: break;
      }
      break;
    case .photolibrary:
      let authStatus = PHPhotoLibrary.authorizationStatus()
      switch authStatus {
      case .authorized: self.call(Of: _type) // Do your stuff here i.e. callCameraMethod()
      case .denied: alertToAllowAccessViaSetting(Message: "사진함 허락해줘!")
      case .notDetermined: alertToRequestAccess(Message: "사진함 왜 거절해! 자꾸 이런식으로 할꼬얌>>???", Type: _type)
      case .restricted: break;
      }
      break
    case .microphone:
      let recordPermission = AVAudioSession.sharedInstance().recordPermission()
      switch recordPermission {
      case AVAudioSessionRecordPermission.denied: self.alertToAllowAccessViaSetting(Message: "마이크 사용 요청");
      case AVAudioSessionRecordPermission.granted: break;
      case AVAudioSessionRecordPermission.undetermined: self.alertToRequestAccess(Message: "마이크 사용 요청 - 2", Type: .microphone)
      default : break;
      }
      break;
    }
  }
  func call(Of _type: AccessType ) {
    log.verbose("called")
    switch _type {
    case .picture:
        log.verbose("picture")
      imagePicker.mediaTypes = [kUTTypeImage as String]
      imagePicker.sourceType = UIImagePickerControllerSourceType.camera
      break;
    case .video:
        log.verbose("video")
      imagePicker.mediaTypes = [kUTTypeMovie as String]
      imagePicker.sourceType = UIImagePickerControllerSourceType.camera
      imagePicker.showsCameraControls = true
      imagePicker.videoQuality = UIImagePickerControllerQualityType.typeMedium
      break;
    case .photolibrary:
        log.verbose("photolibrary")
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)){
            log.verbose("yes you can photolibrary")
            imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
      break;
    default: break
    }
    
    log.debug( "요기까지 왔쉽니더" )
    context.present(imagePicker, animated: true, completion: nil)
  }
  func statusOf(Type _type: AccessType)->Status{
    switch _type {
    case .picture, .video:
      let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
      if(authStatus == .authorized){
        return .granted
      }else if(authStatus == .denied){
        return .denied
      }else if(authStatus == .notDetermined){
        return .notDetermind
      }
    case .photolibrary:
      let authStatus = PHPhotoLibrary.authorizationStatus()
      if(authStatus == .authorized){
        return .granted
      }else if(authStatus == .denied){
        return .denied
      }else if(authStatus == .notDetermined){
        return .notDetermind
      }
    case .microphone:
      let authStatus = AVAudioSession.sharedInstance().recordPermission()
      if(authStatus == .granted){
        return .granted
      }else if(authStatus == .denied){
        return .denied
      }else if(authStatus == .undetermined){
        return .notDetermind
      }
    }
    return .granted
  }
  func isVideo()->Bool{
    return self.imagePicker.mediaTypes.contains(kUTTypeMovie as String)
  }
  func isPicture()->Bool{return false}
  func isPhotoLibrary()->Bool{return false}
}
