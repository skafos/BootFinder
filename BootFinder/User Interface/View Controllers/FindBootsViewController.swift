//
//  FindBootsViewController.swift
//  BootFinder
//
//  Created by Skafos.ai on 7/5/19.
//  Copyright © 2019 Skafos, LLC. All rights reserved.
//

import UIKit
import Skafos

class FindBootsViewController: UIViewController {
  enum Mode {
    case gallery
    case camera
  }

  enum State {
    case ready
    case findingBoots
  }

  @IBOutlet var cameraView: CameraPreviewView!
  @IBOutlet var cantAccessCameraView: UIStackView!
  @IBOutlet var galleryView: UIView!
  @IBOutlet var dimmingView: UIView!
  @IBOutlet var tooltip: TooltipView!
  
  @IBOutlet var galleryViewButton: UIButton!
  @IBOutlet var cameraViewButton: UIButton!
  @IBOutlet var findBootsButton: UIButton!
  @IBOutlet var checkForUpdatesButton: UIButton!
  @IBOutlet var versionLabel: UILabel!

  var camera: Camera?
  var gallery: Gallery?
  let bootFinder = BootFinder()

  var mode: Mode = .gallery {
    didSet {
      toggleModes(isCamera: mode == .camera)
      setNeedsStatusBarAppearanceUpdate()
    }
  }

  var state = State.ready

  override func viewDidLoad() {
    super.viewDidLoad()
    setupGallery()
    setupCamera()
    setupDimmingView()
    toggleCameraView(nil)

    NotificationCenter.default.addObserver(
      forName: Skafos.Notifications.assetUpdated,
      object: nil,
      queue: nil)
    { [weak self] notification in
      self?.updateVersionLabel(notification)
    }
  }

  func setupGallery() {
    gallery = Gallery(galleryView: galleryView)
  }

  @IBAction func setupCamera(_ sender: Any? = nil) {
    cantAccessCameraView.isHidden = true
    Camera.build(previewView: cameraView) { camera in
      guard let camera = camera else {
        self.cantAccessCameraView.isHidden = false
        return
      }
      self.camera = camera
    }
  }

  func setupDimmingView() {
    view.bringSubviewToFront(dimmingView)
    dimmingView.alpha = 0
  }

  @IBAction func findSimilarBoots(_ sender: Any) {
    guard state == .ready else {
      return
    }
    state = .findingBoots

    if !tooltip.isHidden {
      tooltip.isHidden = true
    }
    let findBoots: (UIImage?, Error?) -> () = { image, error in
      guard error == nil else {
        return self.presentError(error)
      }
      self.showBoots(similarTo: image!)
    }

    switch mode {
    case .camera:
      camera?.takePicture(completion: findBoots)
    case .gallery:
      findBoots(gallery?.currentImage(), nil)
    }
  }

  func showBoots(similarTo image: UIImage) {
    bootFinder.findBoots(similarTo: image) { indices, error in
      DispatchQueue.main.async {
        self.state = .ready
        guard
          error == nil,
          let indices = indices,
          let vc = ResultsDisplayViewController.build(bootFinder: self.bootFinder, indices: indices, onDismiss: self.undimOnModalDismissal)
        else {
          return self.presentError(error)
        }
        self.dimForModal()
        self.present(vc, animated: true, completion: nil)
      }
    }
  }

  func presentError(_ error: Error?) {
    console.error("Error: \(String(describing: error))")
    let message = NSLocalizedString("An error occurred, please try again.", comment: "Body of alert view")
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    self.present(alert, animated: true, completion: nil)
  }

  @IBAction func toggleGalleryView(_ sender: Any) {
    guard mode == .camera else {
      return
    }
    mode = .gallery
  }

  @IBAction func toggleCameraView(_ sender: Any?) {
    guard mode == .gallery else {
      return
    }
    mode = .camera
  }

  func toggleModes(isCamera: Bool) {
    galleryViewButton.isSelected = !isCamera
    cameraViewButton.isSelected = isCamera

    UIView.animate(withDuration: 0.3) {
      self.galleryView.alpha = isCamera ? 0 : 1
      self.cameraView.alpha = isCamera ? 1 : 0
    }
  }

  func updateVersionLabel(_ notification: Notification) {
    guard
      let version = notification.userInfo?["version"] as? String,
      version != ""
    else {
      return
    }
    let formatString = NSLocalizedString("Model v%@", comment: "Model version format string on bottom of Boot Finder")
    versionLabel.text = String(format: formatString, version)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? DismissingModalViewController {
      dimForModal()
      destination.onDismiss = self.undimOnModalDismissal
    }
    if let destination = segue.destination as? UpdateModelViewController {
      destination.bootFinder = bootFinder
    }
  }

  func dimForModal() {
    UIView.animate(withDuration: 0.3) {
      self.dimmingView.alpha = 0.8
    }
  }

  func undimOnModalDismissal() {
    UIView.animate(withDuration: 0.3) {
      self.dimmingView.alpha = 0.0
    }
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return mode == .camera ? .lightContent : .default
  }
}
