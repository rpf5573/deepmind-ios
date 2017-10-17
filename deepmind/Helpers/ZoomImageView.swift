//
//  ZoomImageView.swift
//  deepmind
//
//  Created by mac88 on 2017. 7. 8..
//  Copyright © 2017년 mac88. All rights reserved.
//

import UIKit
class ZoomImageView : UIScrollView, UIScrollViewDelegate {
  var imageView : UIImageView!
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = UIColor.black
    self.delegate = self
    //self.contentSize = frame.size
    self.showsHorizontalScrollIndicator = false
    self.showsVerticalScrollIndicator = false
    self.alwaysBounceVertical = false
    self.alwaysBounceHorizontal = false
    self.maximumZoomScale = 3.0
    self.minimumZoomScale = 1.0
    self.clipsToBounds = true
    self.contentMode = .scaleAspectFit
    self.translatesAutoresizingMaskIntoConstraints = false
    //ImageView Setting
    self.imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = UIViewContentMode.scaleAspectFit
    imageView.isUserInteractionEnabled = true
    //let urlString = "\(baseURL)/User/WholeMap/\(mSettings.me.MapURL!)"
    self.addSubview(imageView)
    
    imageView.snp.makeConstraints({ make in
//      make.right.equalToSuperview()
//      make.left.equalToSuperview()
//      make.bottom.equalToSuperview()
//      make.top.equalToSuperview()
      make.center.equalToSuperview()
      make.width.equalToSuperview()
      make.height.equalToSuperview()
    })
    
  }
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    print("zooming")
    log.debug(scrollView.contentSize)
    log.debug(scrollView.contentOffset)
    return self.imageView
  }
  func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
    if(scale < 1.0){
      UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.curveLinear, animations: {
        view?.center = self.superview!.center
        view?.transform = CGAffineTransform(scaleX: 1,y: 1)
      }, completion: {
        result in
        
      })
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
