//
//  PlayBtn.swift
//  AlphagoDeepMind
//
//  Created by mac88 on 2017. 1. 26..
//  Copyright © 2017년 mac88. All rights reserved.
//

import UIKit
import Spring

class VideoPlayButton : SpringButton {
  
  /* ------------------------------------------------------------------ */
  //  Property
  /* ------------------------------------------------------------------ */
  
  //  data
  /* ------------------------------------ */
  var videoPath : String?
  
  
  /* ------------------------------------------------------------------ */
  //  Function
  /* ------------------------------------------------------------------ */
  
  //  life cycle
  /* ------------------------------------ */
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    drawPlayBtn(frame: rect)
  }
  
  //  custom
  /* ------------------------------------ */
  func drawPlayBtn(frame: CGRect = CGRect(x: 0, y: 0, width: 89, height: 89)) {
    func fastFloor(_ x: CGFloat) -> CGFloat { return floor(x) }
    
    //// Bezier Drawing
    let bezierPath = UIBezierPath()
    bezierPath.move(to: CGPoint(x: frame.minX + 0.39326 * frame.width, y: frame.minY + 0.35955 * frame.height))
    bezierPath.addLine(to: CGPoint(x: frame.minX + 0.39326 * frame.width, y: frame.minY + 0.67416 * frame.height))
    bezierPath.addLine(to: CGPoint(x: frame.minX + 0.68539 * frame.width, y: frame.minY + 0.52111 * frame.height))
    bezierPath.addLine(to: CGPoint(x: frame.minX + 0.39326 * frame.width, y: frame.minY + 0.35955 * frame.height))
    bezierPath.close()
    UIColor.white.setFill()
    bezierPath.fill()
    UIColor.black.setStroke()
    bezierPath.lineWidth = 4
    bezierPath.lineJoinStyle = .round
    bezierPath.stroke()
    
    //// Oval Drawing
    let ovalPath = UIBezierPath(ovalIn: CGRect(x: frame.minX + fastFloor(frame.width * 0.07865 + 0.5), y: frame.minY + fastFloor(frame.height * 0.07865 + 0.5), width: fastFloor(frame.width * 0.92135 + 0.5) - fastFloor(frame.width * 0.07865 + 0.5), height: fastFloor(frame.height * 0.92135 + 0.5) - fastFloor(frame.height * 0.07865 + 0.5)))
    UIColor.black.setStroke()
    ovalPath.lineWidth = 6
    ovalPath.stroke()
  }
}
