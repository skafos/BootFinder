//
//  Gallery.swift
//  BootFinder
//
//  Created by Skafos.ai on 7/5/19.
//  Copyright © 2019 Skafos, LLC. All rights reserved.
//

import UIKit

class Gallery: NSObject, UIScrollViewDelegate {
  static let ScrollViewTag = 1
  static let PageControlTag = 2

  let imageNames = [
    "testboot1",
    "testboot2",
    "testboot3",
    "testboot4",
  ]

  let images: [UIImage]
  let galleryView: UIView
  let scrollView: UIScrollView
  let pageControl: UIPageControl

  var currentPage: Int {
    let pageWidth = scrollView.contentSize.width / CGFloat(images.count)
    return Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
  }

  init?(galleryView: UIView) {
    guard
      let scrollView = galleryView.viewWithTag(Gallery.ScrollViewTag) as? UIScrollView,
      let pageControl = galleryView.viewWithTag(Gallery.PageControlTag) as? UIPageControl
    else {
      return nil
    }

    self.galleryView = galleryView
    self.scrollView = scrollView
    self.pageControl = pageControl
    images = imageNames.map({ name in UIImage(named: name)! })
    super.init()
    buildScrollView()
    pageControl.numberOfPages = images.count
    scrollView.delegate = self
  }

  func buildScrollView() {
    var constraints: [NSLayoutConstraint] = []

    var lastImageView: UIImageView?
    images.forEach { image in
      let imageView = UIImageView(image: image)
      imageView.translatesAutoresizingMaskIntoConstraints = false
      imageView.contentMode = .scaleAspectFit
      imageView.backgroundColor = .white
      imageView.clipsToBounds = true
      scrollView.addSubview(imageView)

      let leftConstraint: NSLayoutConstraint
      if let last = lastImageView {
        leftConstraint = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: last, attribute: .trailing, multiplier: 1, constant: 0)
      } else {
        leftConstraint = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1, constant: 0)
      }
      let widthConstraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: galleryView, attribute: .width, multiplier: 1, constant: 0)
      let heightConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: galleryView, attribute: .height, multiplier: 1, constant: 0)
      constraints += [leftConstraint, widthConstraint, heightConstraint]

      lastImageView = imageView
    }
    if let last = lastImageView {
      let trailingConstraint = NSLayoutConstraint(item: last, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1, constant: 0)
      constraints.append(trailingConstraint)
    }
    NSLayoutConstraint.activate(constraints)
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    pageControl.currentPage = currentPage
  }

  func currentImage() -> UIImage? {
    let page = currentPage
    guard page >= 0 && page < images.count else {
      return nil
    }
    return images[page]
  }
}
