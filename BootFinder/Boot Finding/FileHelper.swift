//
//  FileHelper.swift
//  BootFinder
//
//  Created by Skafos.ai on 7/10/19.
//  Copyright © 2019 Skafos, LLC. All rights reserved.
//

import Foundation

class FileHelper {
  let fileManager = FileManager.default
  let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

  func find(fileNamed name: String) -> URL? {
    guard let paths = fileManager.enumerator(atPath: documentsURL.path) else {
      return nil
    }
    for case let path as String in paths {
      let url = URL(fileURLWithPath: path)
      if url.lastPathComponent == name {
        return self.url(for: path)
      }
    }
    return nil
  }

  func url(for pathComponent: String) -> URL {
    return documentsURL.appendingPathComponent(pathComponent)
  }
}
