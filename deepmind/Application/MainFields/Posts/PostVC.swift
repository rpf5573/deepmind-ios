import AVFoundation
import AVKit
import MobileCoreServices
import UIKit
import SnapKit
import Alamofire
import SwiftyJSON
import ObjectMapper
import Kingfisher
import SwiftSpinner
import UICircularProgressRing
import ExpandingMenu
import Spring

protocol PostSelectionViewControllerDelegate {
  func didSelect(Post _post: Int)
}

class PostViewController : UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVPlayerViewControllerDelegate, PostSelectionViewControllerDelegate, UICircularProgressRingDelegate {
  
  /* ------------------------------------------------------------------ */
  //  Property
  /* ------------------------------------------------------------------ */
  
  //  constant
  /* ------------------------------------ */
  struct constants {
    struct size {
      static let menuBtn : CGSize = CGSize(width: 60.0, height: 60.0)
      static let menuBtnItem : CGSize = CGSize(width: 56.0, height: 56.0)
      static let videoPlayBtn : CGSize = CGSize(width: 80.0, height: 80.0)
    }
    struct point {
      static let menuBtn : (xInset:CGFloat, yInset:CGFloat) = (xInset:20.0, yInset:20.0)
    }
  }
  
  //  eunm
  /* ------------------------------------ */
  enum MediaType {
    case picture
    case video
  }
  enum ImageViewOwner : Int {
    case picture = 1
    case video = 2
    case post = 3
  }
  
  //  view component
  /* ------------------------------------ */
  lazy var expandingMenuBtn : ExpandingMenuButton = {
    struct images {
      static let expanding = UIImage(named: "ic_plus")!
      static let expandingOnHighlighted = UIImage(named: "ic_plus2")!
      static let picture = UIImage(named:"ic_camera")!
      static let video = UIImage(named: "ic_video_call_100")!
      static let gallery = UIImage(named: "ic_add_folder_100")!
      static let posts = UIImage(named: "ic_posts")!
      static let upload = UIImage(named: "ic_external_100")!
    }
    // Menu Items
    let pictureMenuItem : ExpandingMenuItem = ExpandingMenuItem(size: constants.size.menuBtnItem, title: "사진", titleColor: nil, image: images.picture, highlightedImage: images.picture, backgroundImage: nil, backgroundHighlightedImage: nil, itemTapped: { self.handlePictureMenuItem() })
    let videoMenuItem : ExpandingMenuItem = ExpandingMenuItem(size: constants.size.menuBtnItem, title: "비디오", titleColor: nil, image: images.video, highlightedImage: images.video, backgroundImage: nil, backgroundHighlightedImage: nil, itemTapped: { self.handleVideoMenuItem() })
    let galleryMenuItem : ExpandingMenuItem = ExpandingMenuItem(size: constants.size.menuBtnItem, title: "갤러리", titleColor: nil, image: images.gallery, highlightedImage: images.gallery, backgroundImage: nil, backgroundHighlightedImage: nil, itemTapped: { self.handleGalleryMenuItem() })
    let postsMenuItem : ExpandingMenuItem = ExpandingMenuItem(size: constants.size.menuBtnItem, title: "포스트", titleColor: nil, image: images.posts, highlightedImage: images.posts, backgroundImage: nil, backgroundHighlightedImage: nil, itemTapped: { self.handlePostsMenuItem() })
    let uploadMenuItem : ExpandingMenuItem = ExpandingMenuItem(size: constants.size.menuBtnItem, title: "업로드", titleColor: nil, image: images.upload, highlightedImage: images.upload, backgroundImage: nil, backgroundHighlightedImage: nil, itemTapped: { self.handleUploadMenuItem() })
    // Expading Menu
    let rect = CGRect(x: self.view.frame.size.width - (constants.point.menuBtn.xInset + constants.size.menuBtn.width ), y: self.view.frame.size.height - (constants.point.menuBtn.yInset + constants.size.menuBtn.height + self.tabBarController!.tabBar.frame.height ), width: constants.size.menuBtn.width, height: constants.size.menuBtn.height)
    let expandingMenu : ExpandingMenuButton = ExpandingMenuButton(frame: rect, centerImage: images.expanding, centerHighlightedImage: images.expanding)
    expandingMenu.addMenuItems([uploadMenuItem, postsMenuItem, galleryMenuItem, videoMenuItem, pictureMenuItem])
    
    return expandingMenu
  }()
  lazy var imageView : UIImageView = {
    let iv : UIImageView = UIImageView(frame: .zero)
    iv.translatesAutoresizingMaskIntoConstraints = false
    iv.isUserInteractionEnabled = true
    iv.contentMode = UIViewContentMode.scaleAspectFill
    iv.clipsToBounds = true
    iv.isHidden = true
    iv.addGestureRecognizer( self.fullImageTapGestureRecognizer )
    iv.set(Owner: .post)
    return iv
  }()
  lazy var zoomImageView : ZoomImageView = {
    log.verbose("resultImageView - called")
    let zi : ZoomImageView = ZoomImageView(frame: UIScreen.main.bounds)
    zi.translatesAutoresizingMaskIntoConstraints = false
    zi.isHidden = true
    zi.layer.opacity = 0.0
    zi.imageView.addGestureRecognizer(self.fadeOutImageTapGestureRecognizer)
    return zi
  }()
  lazy var videoPlayBtn : VideoPlayButton = {
    let btn = VideoPlayButton()
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.isHidden = true
    btn.isUserInteractionEnabled = true
    btn.addTarget(self, action: #selector(self.handleVideoPlayBtn(Button:)) , for: .touchUpInside)
    return btn
  }()
  lazy var circularProgressRing : UICircularProgressRingView = {
    let cp = UICircularProgressRingView()
    //cp.delegate = self
    cp.fontColor = UIColor.gray
    cp.font = UIFont.systemFont(ofSize: 16, weight: 12)
    cp.maxValue = 100
    cp.outerRingColor = UIColor.green
    cp.innerRingColor = UIColor.blue
    cp.innerRingWidth = 4
    cp.outerRingWidth = 4
    cp.ringStyle = UICircularProgressRingStyle.inside
    cp.frame = self.expandingMenuBtn.frame
    cp.isHidden = true
    cp.delegate = self
    return cp
  }()
  
  //  data
  /* ------------------------------------ */
  lazy var accessManager : AccessManager = { return AccessManager(ViewController : self) }()
  lazy var fullImageTapGestureRecognizer : UITapGestureRecognizer = { return UITapGestureRecognizer(target: self, action: #selector(self.handleImageViewTap(Recognizer:))) }()
  lazy var fadeOutImageTapGestureRecognizer : UITapGestureRecognizer = { return UITapGestureRecognizer(target: self, action: #selector(self.handleImageViewTap(Recognizer:))) }()
  lazy var avController : AVPlayerViewController = {
    let ac = AVPlayerViewController()
    ac.delegate = self
    return ac
  }()
  lazy var alamofireSessionManager : SessionManager = {
    let configuration = URLSessionConfiguration.background(withIdentifier: "sessonId")
    let manager = Alamofire.SessionManager(configuration: configuration)
    return manager;
  }()
  lazy var alert : Alert = { return Alert(ViewController: UIApplication.shared.keyWindow!.rootViewController!) }()
  lazy var postSelectionVC : PostSelectionViewController = {
    let vc = PostSelectionViewController()
    vc.delegate = self
    return vc
  }()
  
  
  /* ------------------------------------------------------------------ */
  //  Function
  /* ------------------------------------------------------------------ */
  
  //  life cycle
  /* ------------------------------------ */
  override func viewDidLoad() {
    super.viewDidLoad();
    log.verbose("called")
    self.setup()
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    log.verbose("called")
    
    // 화면을 내릴 수도 있잖아~
    if (imageView.getOwner() == .post) {
      if let currentPost = self.postSelectionVC.postCrate?.currentPost {
        disableVideoPlayBtn()
        openPostImage(Post: currentPost)
      }
        // 처음 온건지, 앱을 껏다가 다시 킨건지 몰라!
      else {
        getPosts(AndThen: { json in
          if ( json["response_code"].intValue == 201 ) {
            self.postSelectionVC.postCrate = mPostCrate(JSONString: json["value"].rawString()!)
            // 잘 진행 하다가, 껏다가 다시 킨상황
            if ( self.postSelectionVC.postCrate?.currentPost != nil ) {
              self.openPostImage(Post: self.postSelectionVC.postCrate.currentPost!)
            }
              // 그냥 처음들어온 상황
            else {}
          }
        })
      }
    } else {
      log.debug(["NONO --> " , "NONO"])
    }
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    log.verbose("called")
  }
  
  //  setup
  /* ------------------------------------ */
  func setup() {
    setupImageView()
    setupExpadingMenu()
    setupZoomImageView()
    setupVideoPlayBtn()
    setupCircularProgressRing()
  }
  func setupExpadingMenu() {
    self.view.addSubview(expandingMenuBtn)
  }
  func setupImageView() {
    self.view.addSubview(imageView)
    imageView.snp.makeConstraints({ make in
      make.width.equalToSuperview()
      make.height.equalToSuperview().dividedBy(2)
      make.center.equalToSuperview()
    })
  }
  func setupZoomImageView() {
    let window : UIWindow = UIApplication.shared.keyWindow!
    window.addSubview(zoomImageView)
    zoomImageView.snp.makeConstraints({ make in
      make.edges.equalToSuperview();
    })
    window.bringSubview(toFront: zoomImageView)
  }
  func setupVideoPlayBtn() {
    imageView.addSubview(videoPlayBtn)
    videoPlayBtn.snp.makeConstraints({ make in
      // 신기한게,,, 이렇게 나중에 해도 다시 drawRect가 호출되나보다...
      make.width.equalTo(constants.size.videoPlayBtn.width)
      make.height.equalTo(constants.size.videoPlayBtn.height)
      make.center.equalToSuperview()
    })
  }
  func setupCircularProgressRing() {
    self.view.addSubview(circularProgressRing)
  }
  
  //  handler
  /* ------------------------------------ */
  func handlePictureMenuItem() {
    log.verbose("called")
    self.accessManager.request(Of: .picture)
  }
  func handleVideoMenuItem() {
    log.verbose("called")
    self.accessManager.request(Of: .video)
  }
  func handleGalleryMenuItem() {
    log.verbose("called")
    self.accessManager.request(Of: .photolibrary)
  }
  func handlePostsMenuItem() {
    log.verbose("called")
    getPosts(AndThen: { json in
      log.debug(["json --> " , json])
      if ( json["response_code"].intValue == 201 ) {
        self.postSelectionVC.postCrate = mPostCrate(JSONString: json["value"].rawString()!)
        self.navigationController?.pushViewController(self.postSelectionVC, animated: true)
      }
    })
  }
  func handleUploadMenuItem() {
    log.verbose("called")
    let owner = imageView.getOwner()
    guard let img = imageView.image, owner != .post else {
      alert.show(Message: "업로드할 자료가 없습니다", CallBack: nil)
      return
    }
    if ( owner == .picture ) {
      upload(Image: img)
    } else {
      upload(Video: videoPlayBtn.videoPath!)
    }
  }
  //(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
  func handleSaveImageToAlbum(Image _img: UIImage, didFinishSavingWithError _error: NSError?, ContextInfo _contextInfo: AnyObject ) {
    guard let error = _error else {
      comeBackWithPicture(Image: _img)
      return
    }
    log.error(["Save Image Error! --> " , error])
  }
  func hadleVideoSaveEnd(videoPath: NSString, didFinishSavingWithError _error: NSError?, contextInfo info: AnyObject) {
    log.verbose("called")
    guard let error = _error else {
      let path = videoPath as String
      comeBackWithVideo(VideoPath: path)
      return
    }
    log.error(["ERRO Message --> " , error])
  }
  func handleImageViewTap(Recognizer _recognizer : UITapGestureRecognizer) {
    log.verbose("called")
    if ( _recognizer == fullImageTapGestureRecognizer ) {
      zoomImageView.imageView.image = imageView.image
      zoomImageView.isHidden = false
      UIView.animate(withDuration: 0.3, animations: {
        self.zoomImageView.layer.opacity = 1.0
      })
    } else if ( _recognizer == fadeOutImageTapGestureRecognizer ) {
      UIView.animate(withDuration: 0.5, animations: {
        self.zoomImageView.frame.origin.y = 1100
        self.zoomImageView.layer.opacity = 0.0
      },completion: { result in
        self.zoomImageView.isHidden = true
        self.zoomImageView.imageView.image = nil
      })
    }
  }
  func handleVideoPlayBtn(Button _btn: VideoPlayButton) {
    log.verbose("called")
    animateVideoPlayBtn(Button: _btn, CallBack: {
      if let _videoPath = _btn.videoPath {
        self.openVideo(Path: _videoPath)
      } else {
        log.error(["VideoPath is Null --> " , "NU~~~LL"])
      }
    })
  }
  func handleBeforeUpload() {
    circularProgressRing.isHidden = false
    expandingMenuBtn.isHidden = true
  }
  func handleAfterUpload(JSON _json: JSON) {
    circularProgressRing.value = 0.0
    circularProgressRing.isHidden = true
    expandingMenuBtn.isHidden = false
    // 서버에서 이미지를 회전시키느라 좀 오래걸림~
    SwiftSpinner.hide({
      if ( _json["response_code"].intValue == 201 ) {
        self.alert.show(Message: _json["success_message"].stringValue, CallBack: { action in
          self.disableVideoPlayBtn()
          self.openPostImage(Post: self.postSelectionVC.postCrate.currentPost!)
        })
      } else {
        self.alert.show(Message: _json["error_message"].stringValue, CallBack: nil)
      }
    })
  }

  //  delegate & datasource
  /* ------------------------------------ */
  /* NavigationController */
  func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    log.verbose("called")
    self.navigationController!.isNavigationBarHidden = true
  }
  /* ImagePickerController */
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    log.verbose("called")
    picker.dismiss(animated: true, completion: { result in
      self.navigationController!.isNavigationBarHidden = false
    })
  }
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    log.verbose("called")
    log.debug(["Info --> " , info])
    self.imageView.isHidden = false
    
    if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
      // 포토라이브러리에서 갖고왔을때
      if ( info["UIImagePickerControllerReferenceURL"] != nil ) {
        comeBackWithPicture(Image: img)
      }
        // 직접 찍었을 때는 저장을 한다!
      else {
        UIImageWriteToSavedPhotosAlbum(img, self, #selector(self.handleSaveImageToAlbum(Image:didFinishSavingWithError:ContextInfo:)), nil)
      }
      
    } else if let pickedVideoURL: URL = (info[UIImagePickerControllerMediaURL] as? URL) {
      // 포토라이브러리에서 갖고왔을때
      if ( info["UIImagePickerControllerReferenceURL"] != nil ) {
        comeBackWithVideo(VideoPath: pickedVideoURL.relativePath)
      }
        // 직접 찍었을 때는 저장을 한다!
      else {
        UISaveVideoAtPathToSavedPhotosAlbum(pickedVideoURL.relativePath, self, #selector(self.hadleVideoSaveEnd(videoPath:didFinishSavingWithError:contextInfo:)), nil)
      }
    }else{
      log.error("이미지가 없습니다")
    }
  }
  /* UICircleProgressRing */
  func finishedUpdatingProgress(forRing ring: UICircularProgressRingView) {}
  func didUpdateProgressValue(to newValue: CGFloat) {
    if ( newValue == 100.0 ) {
      SwiftSpinner.show("처리중...")
    }
  }
  
  /* PostSelect */
  func didSelect(Post _post: Int) {
    if let url = URL(string: "\(BASE_URL)/Posts/\(self.postSelectionVC.postCrate.currentPost!).jpg") {
      self.imageView.set(Owner: .post)
      self.imageView.kf.setImage(with: url)
    }
  }
  
  //  custom
  /* ------------------------------------ */
  func getPreviewImageFromVideo(Path _path: String) -> UIImage? {
    let vidURL = NSURL(fileURLWithPath:_path)
    let asset = AVURLAsset(url: vidURL as URL)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    let timestamp = CMTime(seconds: 2, preferredTimescale: 60)
    do {
      let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
      return UIImage(cgImage: imageRef)
    }
    catch let error as NSError
    {
      print("Image generation failed with error \(error)")
      return nil
    }
  }
  func animateVideoPlayBtn(Button _btn: VideoPlayButton, CallBack _cb:@escaping ()->Void) {
    _btn.animation = "pop"
    _btn.curve = "easeInOut"
    _btn.force = 0.2
    _btn.duration = 0.3
    _btn.scaleX = 1.1
    _btn.scaleY = 1.1
    _btn.animate()
    _btn.animateNext(completion: _cb)
  }
  // close는 done버튼 누르면 됨~ 애플이 만들어 놨음
  func openVideo(Path _path:String){
    log.verbose("called")
    let url = URL(fileURLWithPath: _path, isDirectory: true)
    let videoAsset = AVAsset(url: url)
    let playerItem = AVPlayerItem(asset: videoAsset)
    let player = AVPlayer(playerItem: playerItem)
    avController.player = player
    self.present(avController, animated: true, completion: nil)
  }
  func comeBackWithPicture(Image _img: UIImage) {
    disableVideoPlayBtn()
    imageView.set(Owner: .picture)
    imageView.image = _img
    imageView.addGestureRecognizer(fullImageTapGestureRecognizer)
    imageView.isHidden = false
    accessManager.imagePicker.dismiss(animated: true, completion: { result in
      self.navigationController!.isNavigationBarHidden = false
    })
  }
  func comeBackWithVideo(VideoPath _path: String) {
    if let img = getPreviewImageFromVideo(Path: _path) {
      imageView.set(Owner: .video)
      self.imageView.gestureRecognizers?.forEach(imageView.removeGestureRecognizer)
      self.videoPlayBtn.videoPath = _path
      self.imageView.image = img
      self.imageView.isHidden = false
      self.videoPlayBtn.isHidden = false
      self.accessManager.imagePicker.dismiss(animated: true, completion: { result in
        self.navigationController!.isNavigationBarHidden = false
      })
    } else {
      log.error(["NO Preview Image --> " , "아아아아아아악!!"])
    }
  }
  func upload(Image _img: UIImage) {
    handleBeforeUpload()
    let urlString = "\(BASE_URL)/upload.php"
    let time : String = getCurrentTime()
    let team : Int = mSettings.sharedInstance.ourTeam!
    let teamData : Data = "\(team)".data(using: .utf8, allowLossyConversion: false)!
    
    if let imageData : Data = UIImageJPEGRepresentation(_img, 0.5) {
      self.alamofireSessionManager.upload(multipartFormData: { multipartformdata in
        multipartformdata.append(teamData, withName: "team")
        multipartformdata.append(imageData, withName: "upload_file", fileName: "\(team)_team_\(time).jpeg", mimeType: "image/jpeg")
      }, to: urlString, encodingCompletion: { encoding in
        log.debug(["encoding --> " , encoding])
        switch encoding {
        case .success(let request,_,_):
          request.uploadProgress(closure: { handler in
            let degree = CGFloat(handler.fractionCompleted*100);
            self.circularProgressRing.value = degree
          }).responseJSON(completionHandler: { response in
            log.debug(["response --> " , response])
            if let value = response.result.value {
              let json = JSON(value)
              log.debug(["json --> " , json])
              self.handleAfterUpload(JSON: json)
            }
          })
          break
        case .failure(let error):
          log.error(["Upload Error --> " , error])
          break
        }
      })
    }
  }
  func upload(Video _path: String) {
    handleBeforeUpload()
    let urlString = "\(BASE_URL)/upload.php"
    let videoUrl : URL = URL(fileURLWithPath: _path, isDirectory: true)
    let time : String = getCurrentTime()
    let team : Int = mSettings.sharedInstance.ourTeam!
    let teamData : Data = "\(team)".data(using: .utf8, allowLossyConversion: false)!
    self.alamofireSessionManager.upload(multipartFormData: { multipartformdata in
      multipartformdata.append(teamData, withName: "team")
      multipartformdata.append(videoUrl, withName: "upload_file", fileName: "\(team)team_\(time).mov", mimeType: "video/mp4")
    }, to: urlString, encodingCompletion: { encoding in
      switch encoding {
      case .success(let request,_,_):
        request.uploadProgress(closure: { handler in
          let degree = CGFloat(handler.fractionCompleted*100);
          self.circularProgressRing.value = degree
        }).responseJSON(completionHandler: { response in
          log.debug(["response --> " , response])
          if let value = response.result.value {
            let json = JSON(value)
            self.handleAfterUpload(JSON: json)
          }
        })
        break
      case .failure(let error):
        log.error(["Upload Error --> " , error])
        break
      }
    })
  }
  func getCurrentTime()->String{
    let date = Date()
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: date)
    let minutes = calendar.component(.minute, from: date)
    let seconds = calendar.component(.second, from: date)
    let time = "\(hour)_\(minutes)_\(seconds)"
    return time
  }
  func getPosts(AndThen _cb: @escaping (JSON)->Void) {
    let ourTeam = mSettings.sharedInstance.ourTeam!
    let url = "\(BASE_URL)/post.php"
    let total_team_count = mSettings.sharedInstance.totalTeamCount!
    let params : [String:Any] = ["get_posts":true, "team":ourTeam, "total_team_count":total_team_count]
    Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { response in
      log.debug(["Response --> " , response])
      if let result = response.result.value {
        let json = JSON(result)
        log.verbose(["json --> " , json])
        _cb(json)
      }
    })
  }
  func openPostImage(Post _post: Int) {
    log.verbose("called")
    let urlString = "\(BASE_URL)/Posts/\(_post).jpg"
    log.debug(["urlString --> " , urlString])
    if let url = URL(string: urlString) {
      log.error(["url --> " , url])
      self.imageView.isHidden = false
      self.imageView.kf.setImage(with: url)
      self.imageView.addGestureRecognizer(fullImageTapGestureRecognizer)
    }
  }
  func disableVideoPlayBtn() {
    videoPlayBtn.videoPath = nil
    videoPlayBtn.isHidden = true
  }
}
