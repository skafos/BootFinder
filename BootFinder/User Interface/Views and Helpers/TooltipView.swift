//
//  TooltipView.swift
//  BootFinder
//
//  Created by Skafos.ai on 7/5/19.
//  Copyright © 2019 Skafos, LLC. All rights reserved.
//

import UIKit

// Adapted from https://stackoverflow.com/questions/4442126/how-to-draw-a-speech-bubble-on-an-iphone
@IBDesignable class TooltipView: UIView {

  @IBInspectable var triangleWidth: CGFloat = 40
  @IBInspectable var triangleHeight: CGFloat = 20
  @IBInspectable var borderRadius: CGFloat = 4

  override func layoutSubviews() {
    super.layoutSubviews()
    setMask()
  }

  func setMask() {
    let size = self.bounds.size

    func point(x: CGFloat, y: CGFloat) -> CGPoint {
      return CGPoint(x: x, y: size.height - y)
    }

    let path = CGMutablePath()
    path.move(to: point(x: borderRadius, y: triangleHeight))
    path.addLine(to: point(x: round(size.width / 2.0 - triangleWidth / 2.0), y: triangleHeight))
    path.addLine(to: point(x: round(size.width / 2.0), y: 0))
    path.addLine(to: point(x: round(size.width / 2.0 + triangleWidth / 2.0), y: triangleHeight))
    path.addArc(tangent1End: point(x: size.width, y: triangleHeight), tangent2End: point(x: size.width, y: size.height), radius: borderRadius)
    path.addArc(tangent1End: point(x: size.width, y: size.height) , tangent2End: point(x: round(size.width / 2.0 + triangleWidth / 2.0), y: size.height) , radius: borderRadius)
    path.addArc(tangent1End: point(x: 0, y: size.height), tangent2End: point(x: 0, y: triangleHeight), radius: borderRadius)
    path.addArc(tangent1End: point(x: 0, y :triangleHeight), tangent2End: point(x: size.width ,y: triangleHeight), radius: borderRadius)
    path.closeSubpath()

    let maskLayer = CAShapeLayer()
    maskLayer.path = path
    layer.mask = maskLayer
  }
}
