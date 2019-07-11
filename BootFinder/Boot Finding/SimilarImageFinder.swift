//
//  SimilarImageFinder.swift
//  BootFinder
//
//  Created by Skafos.ai on 7/5/19.
//  Copyright © 2019 Skafos, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreML
import Vision

/// Finds similar images via the ImageSimilarity model.
class SimilarImageFinder {
  let modelName = "ImageSimilarity"
  let similarImageFinder = ImageSimilarity()

  typealias Distance = Double
  typealias CompletionHandler = ([Distance]?, Error?) -> ()

  enum FindError: Error {
    case invalidImage
    case invalidResults
  }

  /// Takes an image and calculates the distances to the items in the dataset.
  func calculateSimilarities(image: UIImage, completion: @escaping CompletionHandler) {
    DispatchQueue.global(qos: .userInitiated).async {
      let orientation   = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))!
      guard let ciImage = CIImage(image: image) else {
        completion(nil, FindError.invalidImage)
        return
      }

      let model = try! VNCoreMLModel(for: self.similarImageFinder.model)
      let responseHandler = ResponseHandler(completion)
      let request = VNCoreMLRequest(model: model, completionHandler: responseHandler.handler)
      request.imageCropAndScaleOption = .centerCrop

      do {
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
        try handler.perform([request])
      } catch {
        responseHandler.expire()
        completion(nil, error)
      }
    }
  }

  /// Converts an array of distances into an array of indices into the dataset sorted by distance, least to greatest.
  static func similarImageIndices(distances: [Distance]) -> [Int] {
    return distances
      .enumerated()
      .map { (index: $0, distance: $1) }
      .sorted(by: { $0.distance < $1.distance })
      .map { $0.index }
  }

  /// Helper type to process the results of the model request.
  private class ResponseHandler {
    var completion: CompletionHandler?
    init(_ completion: @escaping CompletionHandler) {
      self.completion = completion
    }

    func expire() {
      completion = nil
    }

    func handler(request: VNRequest, error: Error?) {
      defer { expire() }
      guard error == nil else {
        completion?(nil, error)
        return
      }
      guard
        let results = request.results,
        let predictions = results as? [VNCoreMLFeatureValueObservation],
        let array = predictions.first?.featureValue.multiArrayValue
        else {
          completion?(nil, FindError.invalidResults)
          return
      }
      completion?(processArray(array), nil)
    }

    func processArray(_ array: MLMultiArray) -> [Double] {
      var distances: [Double] = []
      let count = array.count
      for i in 0..<count {
        distances.append(array[i].doubleValue)
      }
      return distances
    }
  }
}
