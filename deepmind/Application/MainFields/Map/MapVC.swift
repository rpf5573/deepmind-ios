import UIKit
import SnapKit
import Kingfisher

class MapViewController : UIViewController, UIScrollViewDelegate {
  
  /* ------------------------------------------------------------------ */
  //  Property
  /* ------------------------------------------------------------------ */
  
  //  constant
  /* ------------------------------------ */
  
  //  view component
  /* ------------------------------------ */
  lazy var zoomImageView : ZoomImageView = {
    let zi = ZoomImageView(frame: .zero)
    zi.backgroundColor = UIColor.flatWhite
    return zi
  }()
  
  //  data
  /* ------------------------------------ */
  
  
  /* ------------------------------------------------------------------ */
  //  Function
  /* ------------------------------------------------------------------ */
  
  //  life cycle
  /* ------------------------------------ */
  override func viewDidLoad() {
    super.viewDidLoad();
    log.verbose("called")
    self.view.backgroundColor = UIColor.flatRed
    setup()
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated);
    log.verbose("called")
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated);
    log.verbose("called")
    zoomImageView.contentOffset.y = 0
  }
  
  //  setup
  /* ------------------------------------ */
  func setup() {
    self.view.addSubview(zoomImageView)
    zoomImageView.snp.makeConstraints({ make in
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
      make.height.equalToSuperview()
    })
    if let imgName = mSettings.sharedInstance.wholeMapName {
      let urlString = "\(BASE_URL)/Whole_Map/\(imgName)"
      log.debug(["urlString --> " , urlString])
      if let url = URL(string: urlString) {
        log.error(["url --> " , url])
        zoomImageView.imageView.kf.setImage(with: url)
      }
    }
  }
}
