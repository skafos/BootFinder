//
//  DismissingModalViewController.swift
//  BootFinder
//
//  Created by Skafos.ai on 7/5/19.
//  Copyright © 2019 Skafos, LLC. All rights reserved.
//

import UIKit

class DismissingModalViewController: UIViewController {
  var onDismiss: (() -> ())?

  @IBAction func dismiss(_ sender: Any) {
    super.dismiss(animated: true, completion: nil)
    onDismiss?()
  }
}
