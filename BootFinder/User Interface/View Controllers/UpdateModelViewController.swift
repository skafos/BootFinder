//
//  UpdateModelViewController.swift
//  BootFinder
//
//  Created by Skafos.ai on 7/5/19.
//  Copyright © 2019 Skafos, LLC. All rights reserved.
//

import UIKit
import Skafos

class UpdateModelViewController: DismissingModalViewController {

  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var descriptionLabel: UILabel!
  @IBOutlet var activityView: UIActivityIndicatorView!
  @IBOutlet var okButton: UIButton!

  var bootFinder: BootFinder!

  // Content
  let downloadingTitle = NSLocalizedString("New Model Available!", comment: "Title of downloading modal while downloading")
  let downloadingDescription = NSLocalizedString("Downloading new model. May take a moment...", comment: "Description on downloading modal while downloading")
  let downloadedTitle = NSLocalizedString("Model Updated!", comment: "Title of downloading modal after download")
  let downloadedDescription = NSLocalizedString("Your app just got smarter. Go see the difference.", comment: "Description on downloading modal after download")
  let errorTitle = NSLocalizedString("Error", comment: "Title of downloading modal after error")
  let errorDescription = NSLocalizedString("We encountered an error downloading your model. Please try again later.", comment: "Description of downloading modal after error")

  override func viewDidLoad() {
    super.viewDidLoad()
    reloadModel()
  }

  func reloadModel() {
    activityView.startAnimating()
    activityView.isHidden = false
    okButton.isHidden = true
    titleLabel.text = downloadingTitle
    descriptionLabel.text = downloadingDescription

    bootFinder.reloadModel { _, error in
      DispatchQueue.main.async {
        let title: String
        let description: String
        if error != nil {
          console.error("Error downloading new model: \(String(describing: error))")
          title = self.errorTitle
          description = self.errorDescription
        } else {
          title = self.downloadedTitle
          description = self.downloadedDescription
        }
        self.titleLabel.text = title
        self.descriptionLabel.text = description
        UIView.animate(withDuration: 0.3) {
          self.activityView.stopAnimating()
          self.activityView.isHidden = true
          self.okButton.isHidden = false
        }
      }
    }
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}
