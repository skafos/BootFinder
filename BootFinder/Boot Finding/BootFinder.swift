//
//  BootFinder.swift
//  BootFinder
//
//  Created by Skafos.ai on 7/8/19.
//  Copyright © 2019 Skafos, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreML
import Skafos

/// Finds similar boots via the Skafos-managed ImageSimilarity model.
class BootFinder: SimilarImageFinder {
  enum LoadError: Error {
    case couldNotUpdateFromAsset
  }

  let modelFileName = "ImageSimilarity.mlmodel"
  let metadataFileName = "boots_meta_data.json"

  typealias BootsCompletionHandler = ([Int]?, Error?) -> ()

  let fileHelper = FileHelper()
  var bootsDB = BootsDB()

  override init() {
    super.init()
    reloadModel { asset, error in
      print("reloading model: \(asset)k")
    }
  }

  /// Updates with cached files from Skafos if present in the documents directory.
  func reloadFromCache() {
    DispatchQueue.global(qos: .userInteractive).async {
      if let cachedModelFile = self.fileHelper.find(fileNamed: self.modelFileName),
         let modelURL = try? MLModel.compileModel(at: cachedModelFile),
         let model = try? MLModel(contentsOf: modelURL),
         let cachedMetadata = self.fileHelper.find(fileNamed: self.metadataFileName),
         let bootsDB = BootsDB(metadataPath: cachedMetadata.path)
      {
        DispatchQueue.main.async {
          self.bootsDB = bootsDB
          self.similarImageFinder.model = model
        }
      }
    }
  }

  /// Reloads the model and metadata from Skafos.
  func reloadModel(completion: @escaping (Asset, Error?) -> ()) {
    Skafos.load(asset: self.modelName) { error, asset in
      guard error == nil else {
        return completion(asset, error)
      }
      if let model = asset.model,
         let metadataFile = asset.files.filter({$0.name == self.metadataFileName}).first,
         let bootsDB = BootsDB(metadataPath: metadataFile.path)
      {
        self.similarImageFinder.model = model
        self.bootsDB = bootsDB
        completion(asset, nil)
      } else {
        completion(asset, LoadError.couldNotUpdateFromAsset)
      }
    }
  }

  func findBoots(similarTo image: UIImage, completion: @escaping BootsCompletionHandler) {
    super.calculateSimilarities(image: image) { distances, error in
      guard error == nil else {
        completion(nil, error)
        return
      }
      completion(distances.flatMap(SimilarImageFinder.similarImageIndices), nil)
    }
  }

  func boot(at index: Int) -> Boot? {
    return bootsDB[index]
  }
}
