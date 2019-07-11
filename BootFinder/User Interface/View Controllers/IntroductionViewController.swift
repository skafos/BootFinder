//
//  IntroductionViewController.swift
//  BootFinder
//
//  Created by Skafos.ai on 7/5/19.
//  Copyright © 2019 Skafos, LLC. All rights reserved.
//

import UIKit

class IntroductionViewController: UIViewController {

  // MARK: Outlets

  @IBOutlet var icon: UIImageView!
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var descriptionLabel: UILabel!
  @IBOutlet var findBootsButton: UIButton!
  @IBOutlet var poweredByLabel: UILabel!

  @IBOutlet var iconVerticallyCenteredConstraint: NSLayoutConstraint!
  @IBOutlet var iconTopConstraint: NSLayoutConstraint!
  @IBOutlet var iconToTitleConstraint: NSLayoutConstraint!
  @IBOutlet var titleToDescriptionConstraint: NSLayoutConstraint!
  @IBOutlet var buttonToPoweredByConstraint: NSLayoutConstraint!
  @IBOutlet var poweredByToBottomConstraint: NSLayoutConstraint!

  override func viewDidLoad() {
    super.viewDidLoad()
    setupButton()
    setPoweredByLabel()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    playIntroduction()
  }

  // MARK: Setup

  func setupButton() {
    findBootsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
    findBootsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 208, bottom: 0, right: 0)
  }

  func setPoweredByLabel() {
    let attributes: [NSAttributedString.Key: Any] = [
      .font: UIFont(name: "Montserrat-Regular", size: 17.0)!,
      .foregroundColor: UIColor(white: 0.55, alpha: 1),
    ]
    let poweredBy = NSLocalizedString("Powered by ", comment: "Before the logo in the 'Powered by Skafos' label")
    let poweredByString = NSAttributedString(string: poweredBy, attributes: attributes)
    let skafos = NSLocalizedString(" Skafos", comment: "After the logo in the 'Powered by Skafos' label")
    let skafosString = NSAttributedString(string: skafos, attributes: attributes)

    let logo = UIImage(named: "skafos-logo")!
    let logoAttachment = NSTextAttachment()
    logoAttachment.image = logo
    logoAttachment.bounds = CGRect(origin: CGPoint(x: 0, y: -3), size: logo.size)
    let logoString = NSAttributedString(attachment: logoAttachment)

    let labelString = NSMutableAttributedString()
    labelString.append(poweredByString)
    labelString.append(logoString)
    labelString.append(skafosString)
    poweredByLabel.attributedText = labelString
  }

  // MARK: Introduction Animations

  var hasPlayedIntroduction = false

  func playIntroduction() {
    guard hasPlayedIntroduction == false else {
      return
    }
    hasPlayedIntroduction = true

    let animationElements = [
      AnimationElement(view: titleLabel, constraint: iconToTitleConstraint, delay: 0, float: 8),
      AnimationElement(view: descriptionLabel, constraint: titleToDescriptionConstraint, delay: 0.5, float: 16),
      AnimationElement(view: findBootsButton, constraint: buttonToPoweredByConstraint, delay: 0.25, float: 0),
      AnimationElement(view: poweredByLabel, constraint: poweredByToBottomConstraint, delay: 0.25, float: 0),
    ]
    let introAnimation = IntroductionAnimator(parent: view, elements: animationElements)

    centerIcon()
    introAnimation.setup();
    UIView.animate(withDuration: 1, animations: moveIconToTop)
    introAnimation.animate();
  }

  func centerIcon() { swapIcon(center: true) }
  func moveIconToTop() { swapIcon(center: false) }
  func swapIcon(center: Bool) {
    iconTopConstraint.isActive = !center
    iconVerticallyCenteredConstraint.isActive = center
    view.layoutIfNeeded()
  }
}

/// Helper class to encapsulate individual element animation metadata.
private class AnimationElement {
  let view: UIView
  let constraint: NSLayoutConstraint
  let constant: CGFloat
  let delay: TimeInterval
  let float: CGFloat

  init(view: UIView, constraint: NSLayoutConstraint, delay: TimeInterval, float: CGFloat) {
    self.view = view
    self.constraint = constraint
    self.constant = constraint.constant
    self.delay = delay
    self.float = float
  }

  func hide() {
    view.alpha = 0
    constraint.constant = constant + float
  }

  func show() {
    view.alpha = 1
    constraint.constant = constant
    view.superview?.layoutIfNeeded()
  }
}

/// Helper class to animate multiple AnimationElements according to their metadata.
private class IntroductionAnimator {
  let parent: UIView
  let elements: [AnimationElement]

  init(parent: UIView, elements: [AnimationElement]) {
    self.parent = parent
    self.elements = elements
  }

  func setup() {
    elements.forEach { $0.hide() }
    parent.layoutIfNeeded()
  }

  func animate() {
    elements.forEach { element in
      UIView.animate(
        withDuration: 1,
        delay: element.delay,
        options: .curveEaseInOut,
        animations: element.show,
        completion: nil
      )
    }
  }
}
