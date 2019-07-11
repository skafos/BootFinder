//
//  Camera.swift
//  BootFinder
//
//  Created by Skafos.ai on 7/5/19.
//  Copyright © 2019 Skafos, LLC. All rights reserved.
//

import UIKit
import AVFoundation

class Camera: NSObject, AVCapturePhotoCaptureDelegate {
  static let ShutterViewTag = 1

  enum CaptureError: Error {
    case couldNotProcessImageData
  }

  static func build(previewView: CameraPreviewView, _ completion: @escaping (Camera?) -> ()) {
    let shutterView = prepareShutterView(previewView)
    DispatchQueue.global(qos: .userInitiated).async {
      let camera = Camera(previewView: previewView, shutterView: shutterView)
      DispatchQueue.main.async {
        camera?.start()
        completion(camera)
      }
    }
  }

  static func prepareShutterView(_ previewView: CameraPreviewView) -> UIView {
    let shutterView = previewView.subviews.first(where: { $0.tag == Camera.ShutterViewTag })!
    shutterView.alpha = 0
    shutterView.isHidden = false
    previewView.bringSubviewToFront(shutterView)
    return shutterView
  }

  let captureSession: AVCaptureSession
  let photoOutput: AVCapturePhotoOutput
  let previewView: CameraPreviewView
  let shutterView: UIView
  var photoCallback: ((UIImage?, Error?) -> ())?

  private init?(previewView: CameraPreviewView, shutterView: UIView) {
    captureSession = AVCaptureSession()
    photoOutput = AVCapturePhotoOutput()
    self.previewView = previewView
    self.shutterView = shutterView

    guard
      let captureDevice = AVCaptureDevice.default(for: .video),
      let input = try? AVCaptureDeviceInput(device: captureDevice),
      captureSession.canAddInput(input),
      captureSession.canAddOutput(photoOutput)
    else {
      return nil
    }

    captureSession.sessionPreset = .photo
    captureSession.addInput(input)
    captureSession.addOutput(photoOutput)
    captureSession.commitConfiguration()
  }

  private func start() {
    previewView.videoPreviewLayer.session = self.captureSession
    previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
    captureSession.startRunning()
  }

  func takePicture(completion: @escaping (UIImage?, Error?) -> ()) {
    photoCallback = completion
    let settings = AVCapturePhotoSettings()
    photoOutput.capturePhoto(with: settings, delegate: self)
  }

  func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
    animateShutter()
  }

  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    defer {
      photoCallback = nil
    }
    guard error == nil else {
      photoCallback?(nil, error)
      return
    }
    guard
      let data = photo.fileDataRepresentation(),
      let image = UIImage(data: data)
    else {
      photoCallback?(nil, CaptureError.couldNotProcessImageData)
      return
    }
    photoCallback?(image, nil)
  }

  private func animateShutter() {
    UIView.animate(withDuration: 0.1, animations: {
      self.shutterView.alpha = 1
    }) { _ in
      UIView.animate(withDuration: 0.2) {
        self.shutterView.alpha = 0
      }
    }
  }
}

class CameraPreviewView: UIView {
  override class var layerClass: AnyClass {
    return AVCaptureVideoPreviewLayer.self
  }

  var videoPreviewLayer: AVCaptureVideoPreviewLayer {
    return layer as! AVCaptureVideoPreviewLayer
  }
}
